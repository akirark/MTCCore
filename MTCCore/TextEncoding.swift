//
//  TextEncoding.swift
//  MTCCore
//
//  Created by Akira Hayashi on 2016/04/19.
//
//  -----------------------------------------------------------------
//
//  Copyright (c) 2016 Akira Hayashi
//  This software is released under the Apache 2.0 License,
//  see LICENSE.txt for license information
//
//  -----------------------------------------------------------------
//

import Foundation

public final class TextEncoding {

    public struct EncodingInfo {
        public enum Encoding {
            case shiftjis
            case jis
            case eucjp
            case utf8
            case utf16
            case utf32
        }

        public enum ByteOrder {
            case littleEndian
            case bigEndian
        }

        public enum CharacterMapping {
            case mac
            case windows
        }

        var encoding: Encoding?
        var byteOrder: ByteOrder?
        var hasBOM: Bool
        var characterMapping: CharacterMapping

        public init() {
            hasBOM = false
            characterMapping = .mac
        }
    }

    private struct DetectEncodingContext {
        var encodingInfo: EncodingInfo

        var eucFeatures: UInt
        var jisFeatures: UInt
        var utf8Features: UInt
        var isNeverUTF8: Bool

        var textBytes: UnsafePointer<UInt8>!
        var curBytes: UnsafePointer<UInt8>!
        var textLength: Int
        var textOffset: Int

        public init() {
            encodingInfo = EncodingInfo()
            eucFeatures = 0
            jisFeatures = 0
            utf8Features = 0
            isNeverUTF8 = false
            textLength = 0
            textOffset = 0
        }

    }

    public init() {
        
    }

    /// Detect the text encoding information of the text data.
    /// @param textData The text data
    /// @return The detected text encoding information
    public static func encoding(of textData: Data) -> EncodingInfo {
        return textData.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) -> EncodingInfo in
            encoding(of: pointer, length: textData.count)
        }
    }
    
    /// Detect the text encoding information of the text buffer
    /// \param textBuffer The text data buffer
    /// \param length The length of the text buffer in bytes
    /// \return The detected text encoding information
    public static func encoding(of textBuffer: UnsafeRawPointer, length: Int) -> EncodingInfo {
        var context = DetectEncodingContext()
        context.textBytes = unsafeBitCast(textBuffer, to: UnsafePointer<UInt8>.self)
        context.curBytes = context.textBytes
        context.textLength = length
        
        if length == 0 {
            return context.encodingInfo
        }
        
        if self.detectTextEncodingByBOM(&context)
        {
            // Detected by BOM
            return context.encodingInfo
        }
        
        var isDetected = false
        
        while context.textOffset < context.textLength {
            // Check possibility of UTF-8
            if !context.isNeverUTF8 {
                if self.checkUTF8Features(&context) {
                    context.textOffset += 1
                    context.curBytes = context.curBytes.advanced(by: 1)
                    continue
                }
            }
            
            // Check possibility of UTF-16 or UTF-32
            if self.checkUTFnFeatures(&context) {
                isDetected = true
                break
            }
            
            // Check possibility of JIS
            if context.curBytes[0] == 0x1B && (context.textOffset + 2) < context.textLength {
                if context.curBytes[1] == 0x24 && (context.curBytes[2] == 0x42 || context.curBytes[2] == 0x40) {
                    context.encodingInfo.encoding = .jis
                    isDetected = true
                    break
                } else if context.curBytes[1] == 0x28 && (context.curBytes[2] == 0x4A || context.curBytes[2] == 0x42) {
                    context.jisFeatures += 1
                    
                    context.textOffset += 1
                    context.curBytes = context.curBytes.advanced(by: 1)

                    continue
                }
            }
            
            // Check possibility of EUC, Shift-JIS or UTF-8
            if (0x80 <= context.curBytes[0] && context.curBytes[0] <= 0x8D) ||
                (0x90 <= context.curBytes[0] && context.curBytes[0] <= 0x9F) {
                while context.textOffset < context.textLength {
                    if self.checkUTFnFeatures(&context) {
                        isDetected = true
                        break
                    }
                    context.textOffset += 1
                    context.curBytes = context.curBytes.advanced(by: 1)
                }
                
                if !isDetected {
                    // Shift-JIS or UTF-8
                    if context.utf8Features > 0 {
                        context.encodingInfo.encoding = .utf8
                    } else {
                        context.encodingInfo.encoding = .shiftjis
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
            context.curBytes = context.curBytes.advanced(by: 1)
        }
        
        if !isDetected {
            if context.jisFeatures == 0 && context.eucFeatures == 0 {
                context.encodingInfo.encoding = nil
            } else if context.utf8Features > context.jisFeatures && context.utf8Features > context.eucFeatures {
                context.encodingInfo.encoding = .utf8
            } else if context.jisFeatures > 0 {
                context.encodingInfo.encoding = .jis
            } else if context.eucFeatures == 0 {
                context.encodingInfo.encoding = nil
            } else {
                context.encodingInfo.encoding = .eucjp
            }
        }
        
        return context.encodingInfo
    }
    
    /// Detect the encoding code by BOM (Byte Order Mark)
    /// \param context 
    /// \return true if it is detected, otherwise false.
    //private static func detectTextEncodingByBOMWithContext(inout context: DetectTextEncodingContext) -> Bool {
    private static func detectTextEncodingByBOM(_ context: inout DetectEncodingContext) -> Bool {
        var isDetected = false
        
        if context.textLength < 2 {
            return false
        }
        
        if context.textLength >= 3 && context.textBytes[0] == 0xEF && context.textBytes[1] == 0xBB && context.textBytes[2] == 0xBF {
            // UTF-8
            context.encodingInfo.encoding = .utf8
            context.encodingInfo.hasBOM = true
            isDetected = true
        } else if context.textBytes[0] == 0xFE && context.textBytes[1] == 0xFF {
            // UTF-16 BE
            context.encodingInfo.encoding = .utf16
            context.encodingInfo.byteOrder = .bigEndian
            context.encodingInfo.hasBOM = true
            isDetected = true
        } else if context.textBytes[0] == 0xFF && context.textBytes[1] == 0xFE {
            context.encodingInfo.byteOrder = .littleEndian
            context.encodingInfo.hasBOM = true
            isDetected = true
            
            if context.textLength >= 4 && context.textBytes[2] == 0x00 && context.textBytes[3] == 0x00 {
                // UTF-32 LE
                context.encodingInfo.encoding = .utf32
            } else {
                // UTF-16 LE
                context.encodingInfo.encoding = .utf16
            }
        } else if context.textLength >= 4 && context.textBytes[0] == 0x00 && context.textBytes[1] == 0x00 && context.textBytes[2] == 0xFE && context.textBytes[3] == 0xFF {
            // UTF-32 BE
            context.encodingInfo.encoding = .utf32
            context.encodingInfo.byteOrder = .bigEndian
            context.encodingInfo.hasBOM = true
            isDetected = true
        }
        
        return isDetected
    }
    
    /// Check the possibity of the UTF-8
    /// \param context
    /// \return true if it has possibility of the UTF-8, otherwise false
    private static func checkUTF8Features(_ context: inout DetectEncodingContext) -> Bool {
        var isPossible = false
        
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
                    isPossible = true
                }
            }
        }
        
        return isPossible
    }
    
    /// Check the possibility of the UTF-16 or UTF-32
    /// \param context
    /// \return true if it has possibility of the UTF-16 or UTF-32, otherwise false. Also retuns false if it is not cleared.
    private static func checkUTFnFeatures(_ context: inout DetectEncodingContext) -> Bool {
        var isPossible = false
        
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
            context.encodingInfo.encoding = .utf32
            
            if (context.textOffset % 4) == 0 {
                context.encodingInfo.byteOrder = .bigEndian
            } else {
                context.encodingInfo.byteOrder = .littleEndian
            }
            isPossible = true
        } else if nullCount == 1 {
            // It has possibility of the UTF-16 or UTF-32
            if (context.textOffset % 4) == 1 || (context.textOffset % 4) == 2 || (context.textLength % 4) != 0 {
                // UTF-16
                context.encodingInfo.encoding = .utf16
                
                if (context.textOffset % 2) == 0 {
                    context.encodingInfo.byteOrder = .bigEndian
                } else {
                    context.encodingInfo.byteOrder = .littleEndian
                }
                isPossible = true
            } else if (context.textOffset + 2) < context.textLength && (context.textOffset + 3) < context.textLength {
                if context.curBytes[2] == 0x00 || context.curBytes[3] == 0x00 {
                    // UTF-16
                    context.encodingInfo.encoding = .utf16
                    
                    if (context.textOffset % 2) == 0 {
                        context.encodingInfo.byteOrder = .bigEndian
                    } else {
                        context.encodingInfo.byteOrder = .littleEndian
                    }
                    isPossible = true
                }
            }
        }
        return isPossible
    }
    
    public static func isIncludedInASCII(_ c: UInt8) -> Bool {
        return (c <= 0x20 || c == 0x7F)
    }
    
    public static func isIncludedInJISX0201Roman(_ c: UInt8) -> Bool {
        return (0x21 <= c && c <= 0x7E)
    }
    
    public static func isHankakuKatakana(_ c: UInt32) -> Bool {
        return (0xFF61 <= c && c <= 0xFF9F)
    }
    
    private static var hankakuToZenkakuMap: [UInt32: UInt32]!
    private static var hankakuToZenkakuDullnessMap: [UInt32: UInt32]!
    private static var hankakuToZenkakuSemiMap: [UInt32: UInt32]!
    
    private static func makeHankakuToZenkakuMap() -> [UInt32: UInt32] {
        let map: [UInt32: UInt32] = [
            0xFF61: 0x3002, //。
            0xFF62: 0x300C, //「
            0xFF63: 0x300D, //」
            0xFF64: 0x3001, //、
            0xFF65: 0x30FB, //・
            0xFF66: 0x30F2, //ヲ
            0xFF67: 0x30A1, //ァ
            0xFF68: 0x30A3, //ィ
            0xFF69: 0x30A5, //ゥ
            0xFF6A: 0x30A7, //ェ
            0xFF6B: 0x30A9, //ォ
            0xFF6C: 0x30E3, //ャ
            0xFF6D: 0x30E5, //ュ
            0xFF6E: 0x30E7, //ョ
            0xFF6F: 0x30C3, //ッ
            0xFF70: 0x30FC, //ー
            0xFF71: 0x30A2, //ア
            0xFF72: 0x30A4, //イ
            0xFF73: 0x30A6, //ウ
            0xFF74: 0x30A8, //エ
            0xFF75: 0x30AA, //オ
            0xFF76: 0x30AB, //カ
            0xFF77: 0x30AD, //キ
            0xFF78: 0x30AF, //ク
            0xFF79: 0x30B1, //ケ
            0xFF7A: 0x30B3, //コ
            0xFF7B: 0x30B5, //サ
            0xFF7C: 0x30B7, //シ
            0xFF7D: 0x30B9, //ス
            0xFF7E: 0x30BB, //セ
            0xFF7F: 0x30BD, //ソ
            
            0xFF80: 0x30BF, //タ
            
            0xFF81: 0x30C1, //チ
            0xFF82: 0x30C4, //ツ
            0xFF83: 0x30C6, //テ
            0xFF84: 0x30C8, //ト
            0xFF85: 0x30CA, //ナ
            0xFF86: 0x30CB, //ニ
            0xFF87: 0x30CC, //ヌ
            0xFF88: 0x30CD, //ネ
            0xFF89: 0x30CE, //ノ
            0xFF8A: 0x30CF, //ハ
            0xFF8B: 0x30D2, //ヒ
            0xFF8C: 0x30D5, //フ
            0xFF8D: 0x30D8, //ヘ
            0xFF8E: 0x30DB, //ホ
            0xFF8F: 0x30DE, //マ
            0xFF90: 0x30DF, //ミ
            0xFF91: 0x30E0, //ム
            0xFF92: 0x30E1, //メ
            0xFF93: 0x30E2, //モ
            0xFF94: 0x30E4, //ヤ
            0xFF95: 0x30E6, //ユ
            0xFF96: 0x30E8, //ヨ
            0xFF97: 0x30E9, //ラ
            0xFF98: 0x30EA, //リ
            0xFF99: 0x30EB, //ル
            0xFF9A: 0x30EC, //レ
            0xFF9B: 0x30ED, //ロ
            0xFF9C: 0x30EF, //ワ
            0xFF9D: 0x30F3, //ン
        ]
        return map
    }
    
    private static func makeHankakuToZenkakuDullnessMap() -> [UInt32: UInt32] {
        let map: [UInt32: UInt32] = [
            0xFF76: 0x30AC, //ガ
            0xFF77: 0x30AE, //ギ
            0xFF78: 0x30B0, //グ
            0xFF79: 0x30B2, //ゲ
            0xFF7A: 0x30B4, //ゴ
            0xFF7B: 0x30B6, //ザ
            
            0xFF7C: 0x30B8, //ジ
            
            0xFF7D: 0x30BA, //ズ
            0xFF7E: 0x30BC, //ゼ
            0xFF7F: 0x30BE, //ゾ
            0xFF80: 0x30C0, //ダ
            0xFF81: 0x30C2, //ヂ
            0xFF82: 0x30C5, //ヅ
            0xFF83: 0x30C7, //デ
            0xFF84: 0x30C9, //ド
            0xFF8A: 0x30D0, //バ
            0xFF8B: 0x30D3, //ビ
            0xFF8C: 0x30D6, //ブ
            0xFF8D: 0x30D9, //ベ
            0xFF8E: 0x30DC, //ボ
            0xFF73: 0x30F4 //ヴ
        ]
        return map
    }
    
    private static func makeHankakuToZenkakuFullSemiMap() -> [UInt32: UInt32] {
        let map: [UInt32: UInt32] = [
            0xFF8A: 0x30D1, //パ
            0xFF8B: 0x30D4, //ピ
            0xFF8C: 0x30D7, //プ
            0xFF8D: 0x30DA, //ペ
            0xFF8E: 0x30DD //ポ
        ]
        return map
    }
    
    /// Convert the hankaku katakana to the zenkaku katakana.
    /// If the specified character is not hanakaku katakana, returns it.
    public static func convertHankakuToZenkakuKatakanaCharacter(_ srcChar: UInt32, nextChar: UInt32, numOfCharsReplaced: inout Int?) -> UInt32 {
        var dstChar = srcChar
        
        if numOfCharsReplaced != nil {
            numOfCharsReplaced = 0
        }
        
        if isHankakuKatakana(srcChar) {
            if hankakuToZenkakuMap == nil {
                hankakuToZenkakuMap = makeHankakuToZenkakuMap()
            }
            if hankakuToZenkakuDullnessMap == nil {
                hankakuToZenkakuDullnessMap = makeHankakuToZenkakuDullnessMap()
            }
            if hankakuToZenkakuSemiMap == nil {
                hankakuToZenkakuSemiMap = makeHankakuToZenkakuFullSemiMap()
            }
            
            if nextChar == 0xFF9E || nextChar == 0xFF9F {
                // Check the character can lead the sonant mark or the p-sound sign in Japanese.
                if srcChar == 0xFF73
                    || (0xFF76 <= srcChar && srcChar <= 0xFF84)
                    || (0xFF8A <= srcChar && srcChar <= 0xFF8E) {
                    if nextChar == 0xFF9E {
                        if let c = hankakuToZenkakuDullnessMap[srcChar] {
                            dstChar = c
                            numOfCharsReplaced = 2
                        }
                    } else {
                        if let c = hankakuToZenkakuSemiMap[srcChar] {
                            dstChar = c
                            numOfCharsReplaced = 2
                        }
                    }
                }
            }
            
            if srcChar == dstChar {
                if let c = hankakuToZenkakuMap[srcChar] {
                    dstChar = c
                    numOfCharsReplaced = 1
                }
            }
        }
        
        return dstChar
    }
    
}

public extension String {
    
    /// Create an instance with the specified data and the encoding information.
    /// \param data                 The text data
    /// \param textEncodingInfo     The text encoding information
    /// \return Created instance or nil if it failed read the text.
    public init?(data: Data, textEncodingInfo info: TextEncoding.EncodingInfo) {
        var encoding = String.Encoding.macOSRoman.rawValue
        var isValid = true
        var textData = data

        if info.encoding == .shiftjis {
            if info.characterMapping == .windows {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.dosJapanese.rawValue))
            } else {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.macJapanese.rawValue))
            }
        } else if info.encoding == .jis {
            encoding = String.Encoding.iso2022JP.rawValue
        } else if info.encoding == .eucjp {
            encoding = String.Encoding.japaneseEUC.rawValue
        } else if info.encoding == .utf8 {
            encoding = String.Encoding.utf8.rawValue
        } else if info.encoding == .utf16 {
            if info.hasBOM && data.count >= 2 {
                textData = data.subdata(in: data.startIndex.advanced(by: 2) ..< data.endIndex.advanced(by: -2))
            }

            if info.byteOrder == .bigEndian {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF16BE.rawValue)
            } else if info.byteOrder == .littleEndian {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF16LE.rawValue)
            } else {
                isValid = false
            }
        } else if info.encoding == .utf32 {
            if info.hasBOM && data.count >= 4 {
                textData = data.subdata(in: data.startIndex.advanced(by: 4) ..< data.endIndex.advanced(by: -4))
            }

            if info.byteOrder == .bigEndian {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF32BE.rawValue)
            } else if info.byteOrder == .littleEndian {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF32LE.rawValue)
            } else {
                isValid = false
            }
        } else {
            encoding = String.Encoding.macOSRoman.rawValue
        }

        if isValid {
            self.init(data: textData, encoding: String.Encoding(rawValue: encoding))
        } else {
            return nil
        }
    }
    
    /// Create the text data with specified text encoding information.
    /// \param info     The text encoding information.
    /// \return         The encoded text data or nil if failed to create
    public func data(using info: TextEncoding.EncodingInfo) -> Data? {
        var data: Data?
        
        if info.encoding == .shiftjis {
            var encoding: UInt
            
            if info.characterMapping == .windows {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.dosJapanese.rawValue))
            } else {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.macJapanese.rawValue))
            }
            
            data = self.data(using: String.Encoding(rawValue: encoding), allowLossyConversion: false)
        } else if info.encoding == .jis {
            data = self.data(using: String.Encoding.iso2022JP, allowLossyConversion: false)
        } else if info.encoding == .eucjp {
            data = self.data(using: String.Encoding.japaneseEUC, allowLossyConversion: false)
        } else if info.encoding == .utf8 {
            data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
            
            if data != nil && info.hasBOM {
                let utf8bom: [UInt8] = [ 0xEF, 0xBB, 0xBF ]
                data!.insert(contentsOf: utf8bom, at: data!.startIndex)
            }
        } else if info.encoding == .utf16 && (info.byteOrder == .bigEndian || info.byteOrder == .littleEndian) {
            var encoding: UInt
            
            if info.byteOrder == .bigEndian {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF16BE.rawValue)
            } else {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF16LE.rawValue)
            }
            
            data = self.data(using: String.Encoding(rawValue: encoding), allowLossyConversion: false)
            
            if data != nil && info.hasBOM {
                var utf16bom: [UInt8]
                
                if info.byteOrder == .bigEndian {
                    utf16bom = [0xFE, 0xFF]
                } else {
                    utf16bom = [0xFF, 0xFE]
                }

                data!.insert(contentsOf: utf16bom, at: data!.startIndex)
            }
        } else if info.encoding == .utf32 && (info.byteOrder == .bigEndian || info.byteOrder == .littleEndian) {
            var encoding: UInt
            
            if info.byteOrder == .bigEndian {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF32BE.rawValue)
            } else {
                encoding = CFStringConvertEncodingToNSStringEncoding(CFStringBuiltInEncodings.UTF32LE.rawValue)
            }
            
            data = self.data(using: String.Encoding(rawValue: encoding), allowLossyConversion: false)
            
            if data != nil && info.hasBOM {
                var utf32bom: [UInt8]
                
                if info.byteOrder == .bigEndian {
                    utf32bom = [0x00, 0x00, 0xFE, 0xFF]
                } else {
                    utf32bom = [0xFF, 0xFE, 0x00, 0x00]
                }

                data!.insert(contentsOf: utf32bom, at: data!.startIndex)
            }
        } else {
            data = self.data(using: .macOSRoman, allowLossyConversion: false)
        }
        return data
    }
    
    /// Returns the string made by replacing the hankaku katakana to the zenkaku katakana.
    public var replacingHankakuKatakana: String {
        var replacedString = ""
        var curIndex = self.unicodeScalars.startIndex
        let endIndex = self.unicodeScalars.endIndex
        
        while curIndex != endIndex {
            let char = self.unicodeScalars[curIndex]
            
            if TextEncoding.isHankakuKatakana(char.value) {
                let nextIndex = self.unicodeScalars.index(after: curIndex)
                let next = (nextIndex != endIndex) ? self.unicodeScalars[nextIndex].value : 0

                var numOfChars: Int? = nil
                let char2 = TextEncoding.convertHankakuToZenkakuKatakanaCharacter(char.value, nextChar: next, numOfCharsReplaced: &numOfChars)
                
                if char2 != 0 {
                    replacedString.append(String(UnicodeScalar(char2)!))
                } else {
                    replacedString.append(String(char))
                }
            
                if numOfChars != nil {
                    curIndex = self.unicodeScalars.index(curIndex, offsetBy: numOfChars!)
                } else {
                    curIndex = self.unicodeScalars.index(after: curIndex)
                }
                
            } else {
                replacedString.append(String(char))
                curIndex = self.unicodeScalars.index(after: curIndex)
            }
        }
        
        return replacedString
    }
}
