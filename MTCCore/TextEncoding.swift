//
//  TextEncoding.swift
//  MTCCore
//
//  Created by Akira Hayashi on 2016/04/19.
//
//  -----------------------------------------------------------------
//
//  Copyright (c) 2016 Akira Hayashi
//  This software is released under the MIT License,
//  see LICENSE.txt for license information
//
//  -----------------------------------------------------------------
//

import Foundation

public enum EncodingCode {
    case Unknown
    case ShiftJIS
    case JIS
    case EUCJP
    case UTF8
    case UTF16
    case UTF32
}

public enum ByteOrder {
    case Unknown
    case LE         // Little Endian
    case BE         // Big Endian
}

public enum CharMapping {
    case Mac
    case Windows
}

public struct TextEncodingInfo {
    var encodingCode: EncodingCode
    var byteOrder: ByteOrder
    var hasBOM: Bool
    var charMapping: CharMapping
    
    public init() {
        encodingCode = .Unknown
        byteOrder = .Unknown
        hasBOM = false
        charMapping = .Mac
    }
}

private struct DetectTextEncodingContext {
    var encodingInfo: TextEncodingInfo
    
    var eucFeatures: UInt
    var jisFeatures: UInt
    var utf8Features: UInt
    var isNeverUTF8: Bool
    
    var textBytes: UnsafePointer<UInt8>!
    var curBytes: UnsafePointer<UInt8>!
    var textLength: Int
    var textOffset: Int
    
    private init() {
        encodingInfo = TextEncodingInfo()
        eucFeatures = 0
        jisFeatures = 0
        utf8Features = 0
        isNeverUTF8 = false
        textLength = 0
        textOffset = 0
    }
}

public final class TextEncoding {
    public init() {
        
    }
    
    /// Detect the text encoding information of the text buffer
    /// \param textBuffer The text data buffer
    /// \param length The length of the text buffer in bytes
    /// \return The detected text encoding information
    public static func detectTextEncodingOfTextBuffer(textBuffer: UnsafePointer<Void>, length: Int) -> TextEncodingInfo {
        var context = DetectTextEncodingContext()
        context.textBytes = unsafeBitCast(textBuffer, UnsafePointer<UInt8>.self)
        context.curBytes = context.textBytes
        context.textLength = length
        
        if textBuffer == nil || length == 0 {
            return context.encodingInfo
        }
        
        if self.detectTextEncodingByBOMWithContext(&context)
        {
            // Detected by BOM
            return context.encodingInfo
        }
        
        var isDetected = false
        
        while context.textOffset < context.textLength {
            // Check possibility of UTF-8
            if !context.isNeverUTF8 {
                if self.checkUTF8FeaturesWithContext(&context) {
                    context.textOffset += 1
                    context.curBytes = context.curBytes.advancedBy(1)

                    continue
                }
            }
            
            // Check possibility of UTF-16 or UTF-32
            if self.checkUTFnFeaturesWithContext(&context) {
                isDetected = true
                break
            }
            
            // Check possibility of JIS
            if context.curBytes[0] == 0x1B && (context.textOffset + 2) < context.textLength {
                if context.curBytes[1] == 0x24 && (context.curBytes[2] == 0x42 || context.curBytes[2] == 0x40) {
                    context.encodingInfo.encodingCode = .JIS
                    isDetected = true
                    break
                } else if context.curBytes[1] == 0x28 && (context.curBytes[2] == 0x4A || context.curBytes[2] == 0x42) {
                    context.jisFeatures += 1
                    
                    context.textOffset += 1
                    context.curBytes = context.curBytes.advancedBy(1)

                    continue
                }
            }
            
            // Check possibility of EUC, Shift-JIS or UTF-8
            if (0x80 <= context.curBytes[0] && context.curBytes[0] <= 0x8D) ||
                (0x90 <= context.curBytes[0] && context.curBytes[0] <= 0x9F) {
                while context.textOffset < context.textLength {
                    if self.checkUTFnFeaturesWithContext(&context) {
                        isDetected = true
                        break
                    }
                    context.textOffset += 1
                    context.curBytes = context.curBytes.advancedBy(1)
                }
                
                if !isDetected {
                    // Shift-JIS or UTF-8
                    if context.utf8Features > 0 {
                        context.encodingInfo.encodingCode = .UTF8
                    } else {
                        context.encodingInfo.encodingCode = .ShiftJIS
                    }
                    isDetected = true
                }
                
                break
            } else if !self.isIncludedInASCII(context.curBytes[0]) && !self.isIncludedInJISX0201Roman(context.curBytes[0]) {
                // Check possibility of EUC-JP
                if context.curBytes[0] >= 0xA1 && context.curBytes[0] <= 0xFE {
                    // Check possibility of EUC-JP Kanji
                    // The first byte and second byte are both in [0xA1, 0xFE]
                    if context.textOffset + 1 < context.textLength && context.curBytes[1] >= 0xA1 && context.curBytes[1] <= 0xFE {
                        context.eucFeatures += 1
                    }
                } else {
                    context.eucFeatures += 1
                }
            }
            
            context.textOffset += 1
            context.curBytes = context.curBytes.advancedBy(1)
        }
        
        if !isDetected {
            if context.jisFeatures == 0 && context.eucFeatures == 0 {
                context.encodingInfo.encodingCode = .Unknown
            } else if context.utf8Features > context.jisFeatures && context.utf8Features > context.eucFeatures {
                context.encodingInfo.encodingCode = .UTF8
            } else if context.jisFeatures > 0 {
                context.encodingInfo.encodingCode = .JIS
            } else if context.eucFeatures == 0 {
                context.encodingInfo.encodingCode = .Unknown
            } else {
                context.encodingInfo.encodingCode = .EUCJP
            }
        }
        
        return context.encodingInfo
    }
    
    /// Detect the encoding code by BOM (Byte Order Mark)
    /// \param context 
    /// \return true if it is detected, otherwise false.
    private static func detectTextEncodingByBOMWithContext(inout context: DetectTextEncodingContext) -> Bool {
        var ret = false
        
        if context.textLength < 2 {
            return false
        }
        
        if context.textLength >= 3 && context.textBytes[0] == 0xEF && context.textBytes[1] == 0xBB && context.textBytes[2] == 0xBF {
            // UTF-8
            context.encodingInfo.encodingCode = .UTF8
            context.encodingInfo.hasBOM = true
            ret = true
        } else if context.textBytes[0] == 0xFE && context.textBytes[1] == 0xFF {
            // UTF-16 BE
            context.encodingInfo.encodingCode = .UTF16
            context.encodingInfo.byteOrder = .BE
            context.encodingInfo.hasBOM = true
            ret = true
        } else if context.textBytes[0] == 0xFF && context.textBytes[1] == 0xFE {
            context.encodingInfo.byteOrder = .LE
            context.encodingInfo.hasBOM = true
            ret = true
            
            if context.textLength >= 4 && context.textBytes[2] == 0x00 && context.textBytes[3] == 0x00 {
                // UTF-32 LE
                context.encodingInfo.encodingCode = .UTF32
            } else {
                // UTF-16 LE
                context.encodingInfo.encodingCode = .UTF16
            }
        } else if context.textLength >= 4 && context.textBytes[0] == 0x00 && context.textBytes[1] == 0x00 && context.textBytes[2] == 0xFE && context.textBytes[3] == 0xFF {
            // UTF-32 BE
            context.encodingInfo.encodingCode = .UTF32
            context.encodingInfo.byteOrder = .BE
            context.encodingInfo.hasBOM = true
            ret = true
        }
        
        return ret
    }
    
    /// Check the possibity of the UTF-8
    /// \param context
    /// \return true if it has possibility of the UTF-8, otherwise false
    private static func checkUTF8FeaturesWithContext(inout context: DetectTextEncodingContext) -> Bool {
        var ret = false
        
        if context.curBytes[0] == 0xFF || context.curBytes[1] == 0xFE {
            // If the text is UTF-8, 0xFE and 0xFF are never appeared in the octet
            context.isNeverUTF8 = true
            context.utf8Features = 0
        } else {
            var mask: uint8 = 128
            var numOfOctets = 0
            
            for _ in 0 ..< 6 {
                if (context.curBytes[0] & mask) != 0 {
                    numOfOctets += 1
                    mask >>= 1
                } else {
                    break
                }
            }
            
            if numOfOctets > 1 {
                var validOctets = 1
                
                for u in 1 ..< numOfOctets {
                    if (context.textOffset + u) >= context.textLength || (context.curBytes[u] & 128) == 0 || (context.curBytes[u] & 64) != 0 {
                        break
                    }
                    validOctets += 1
                }
                
                if validOctets != numOfOctets || (context.textOffset + numOfOctets) > context.textLength {
                    context.isNeverUTF8 = true
                    context.utf8Features = 0
                } else {
                    context.utf8Features += 1
                    ret = true
                }
            }
        }
        
        return ret
    }
    
    /// Check the possibility of the UTF-16 or UTF-32
    /// \param context
    /// \return true if it has possibility of the UTF-16 or UTF-32, otherwise false. Also retuns false if it is not cleared.
    private static func checkUTFnFeaturesWithContext(inout context: DetectTextEncodingContext) -> Bool {
        var ret = false
        
        var nullCount = 0
        if context.curBytes[0] != 0x00 {
            return false
        }
        
        var u = 0
        while (context.textOffset + u) < context.textLength {
            if context.curBytes[u] == 0x00 {
                nullCount += 1
            } else {
                break
            }
            u += 1
        }
        
        if nullCount > 1 {
            // It is UTF-32 because multiple NULL characters are appeared in succession
            context.encodingInfo.encodingCode = .UTF32
            
            if (context.textOffset % 4) == 0 {
                context.encodingInfo.byteOrder = .BE
            } else {
                context.encodingInfo.byteOrder = .LE
            }
            ret = true
        } else if nullCount == 1 {
            // It has possibility of the UTF-16 or UTF-32
            if (context.textOffset % 4) == 1 || (context.textOffset % 4) == 2 || (context.textLength % 4) != 0 {
                // UTF-16
                context.encodingInfo.encodingCode = .UTF16
                
                if (context.textOffset % 2) == 0 {
                    context.encodingInfo.byteOrder = .BE
                } else {
                    context.encodingInfo.byteOrder = .LE
                }
                ret = true
            } else if (context.textOffset + 2) < context.textLength && (context.textOffset + 3) < context.textLength {
                if context.curBytes[2] == 0x00 || context.curBytes[3] == 0x00 {
                    // UTF-16
                    context.encodingInfo.encodingCode = .UTF16
                    
                    if (context.textOffset % 2) == 0 {
                        context.encodingInfo.byteOrder = .BE
                    } else {
                        context.encodingInfo.byteOrder = .LE
                    }
                    ret = true
                }
            }
        }
        return ret
    }
    
    private static func isIncludedInASCII(c: UInt8) -> Bool {
        return (c <= 0x20 || c == 0x7F)
    }
    
    private static func isIncludedInJISX0201Roman(c: UInt8) -> Bool {
        return (0x21 <= c && c <= 0x7E)
    }
    
}

public extension NSString {
    
    /// Create an instance with the specified data and the encoding information.
    /// \param data                 The text data
    /// \param textEncodingInfo     The text encoding information
    /// \return Created instance or nil if it failed read the text.
    public convenience init?(data: NSData, textEncodingInfo info: TextEncodingInfo) {
        var encoding: NSStringEncoding = NSMacOSRomanStringEncoding
        
        var textBytes = data.bytes
        var textLength = data.length
        var isValid = true
        
        if info.encodingCode == .ShiftJIS {
            if info.charMapping == .Windows {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.DOSJapanese.rawValue))
            } else {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.MacJapanese.rawValue))
            }
        } else if info.encodingCode == .JIS {
            encoding = NSISO2022JPStringEncoding
        } else if info.encodingCode == .EUCJP {
            encoding = NSJapaneseEUCStringEncoding
        } else if info.encodingCode == .UTF8 {
            encoding = NSUTF8StringEncoding
            
            if info.hasBOM && textLength >= 3 {
                textBytes = textBytes.advancedBy(3)
                textLength -= 3
            }
        } else if info.encodingCode == .UTF16 {
            if info.hasBOM && textLength >= 2 {
                textBytes = textBytes.advancedBy(2)
                textLength -= 2
            }
            
            if info.byteOrder == .BE {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF16BE.rawValue)
            } else if info.byteOrder == .LE {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF16LE.rawValue)
            } else {
                isValid = false
            }
        } else if info.encodingCode == .UTF32 {
            if info.hasBOM && textLength >= 4 {
                textBytes = textBytes.advancedBy(4)
                textLength -= 4
            }
            
            if info.byteOrder == .BE {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF32BE.rawValue)
            } else if info.byteOrder == .LE {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF32LE.rawValue)
            } else {
                isValid = false
            }
        } else {
            encoding = NSMacOSRomanStringEncoding
        }
        
        if isValid {
            self.init(data: data, encoding: encoding)
        } else {
            return nil
        }
    }
    
    /// Create the text data with specified text encoding information.
    /// \param info     The text encoding information.
    /// \return         The encoded text data or nil if failed to create
    public func dataUsingTextEncodingInfo(info: TextEncodingInfo) -> NSData? {
        var data: NSData?
        
        if info.encodingCode == .ShiftJIS {
            var encoding: NSStringEncoding
            
            if info.charMapping == .Windows {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.DOSJapanese.rawValue))
            } else {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.MacJapanese.rawValue))
            }
            
            data = self.dataUsingEncoding(encoding, allowLossyConversion: false)
        } else if info.encodingCode == .JIS {
            data = self.dataUsingEncoding(NSISO2022JPStringEncoding, allowLossyConversion: false)
        } else if info.encodingCode == .EUCJP {
            data = self.dataUsingEncoding(NSJapaneseEUCStringEncoding, allowLossyConversion: false)
        } else if info.encodingCode == .UTF8 {
            data = self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            if data != nil && info.hasBOM {
                var utf8bom: [UInt8] = [ 0xEF, 0xBB, 0xBF ]
                let tempData = NSMutableData(bytes: &utf8bom, length: 3)
                tempData.appendData(data!)
                
                data = tempData
            }
        } else if info.encodingCode == .UTF16 && (info.byteOrder == .BE || info.byteOrder == .LE) {
            var encoding: NSStringEncoding
            
            if info.byteOrder == .BE {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF16BE.rawValue)
            } else {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF16LE.rawValue)
            }
            
            data = self.dataUsingEncoding(encoding, allowLossyConversion: false)
            
            if data != nil && info.hasBOM {
                var utf16bom: [UInt8]
                
                if info.byteOrder == .BE {
                    utf16bom = [0xFE, 0xFF]
                } else {
                    utf16bom = [0xFF, 0xFE]
                }
                
                let tempData = NSMutableData()
                tempData.appendBytes(&utf16bom, length: 2)
                tempData.appendData(data!)
                
                data = tempData
            }
        } else if info.encodingCode == .UTF32 && (info.byteOrder == .BE || info.byteOrder == .LE) {
            var encoding: NSStringEncoding
            
            if info.byteOrder == .BE {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF32BE.rawValue)
            } else {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF32LE.rawValue)
            }
            
            data = self.dataUsingEncoding(encoding, allowLossyConversion: false)
            
            if data != nil && info.hasBOM {
                var utf32bom: [UInt8]
                
                if info.byteOrder == .BE {
                    utf32bom = [0x00, 0x00, 0xFE, 0xFF]
                } else {
                    utf32bom = [0xFF, 0xFE, 0x00, 0x00]
                }
                
                let tempData = NSMutableData()
                tempData.appendBytes(&utf32bom, length: 4)
                tempData.appendData(data!)
                
                data = tempData
            }
        } else {
            data = self.dataUsingEncoding(NSMacOSRomanStringEncoding, allowLossyConversion: false)
        }
        return data
    }
}
