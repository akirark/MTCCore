//
//  LineBreak.swift
//  MTCCore
//
//  Created by Akira Hayashi on 2016/04/17.
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

public enum LineBreakType {
    case Unknown
    case LF
    case CR
    case CRLF
    case LS
}

private let kLineBreakCharacterCR: Character = "\r"
private let kLineBreakCharacterLF: Character = "\n"
private let kLineBreakCharacterCRLF: Character = "\r\n"
private let kLineBreakCharacterLS: Character = "\u{2028}"

/// The LineBreak class detects and replaces line breaks
public final class LineBreak {
    
    public init() {
        
    }
    
    /// Detects the line break type of the text
    /// \param text The text to be checked
    /// \return Detected line break type
    public static func detectLineBreakInText(text: String) -> LineBreakType {
        var ret = LineBreakType.Unknown
        var prevCharacter: Character = "\0"
        
        for c in text.characters {
            switch c {
            case kLineBreakCharacterCR:
                ret = .CR
            case kLineBreakCharacterLF:
                ret = .LF
            case kLineBreakCharacterCRLF:
                ret = .CRLF
            case kLineBreakCharacterLS:
                ret = .LS
            default:
                break
            }
            
            if ret != .Unknown {
                break
            }
            
            prevCharacter = c
        }
        
        if ret == .Unknown && prevCharacter == kLineBreakCharacterCR {
            ret = .CR
        }
        
        return ret
    }
    
    /// Replaces line breaks
    /// \param text The text
    /// \param type The new line break type
    /// \return The new text
    public static func replaceLineBreaksInText(text: String, type: LineBreakType) throws -> String {
        var ret: String = ""
        
        let lbc: Character
        switch type {
        case .CR:
            lbc = kLineBreakCharacterCR
        case .LF:
            lbc = kLineBreakCharacterLF
        case .CRLF:
            lbc = kLineBreakCharacterCRLF
        case .LS:
            lbc = kLineBreakCharacterLS
        default:
            throw MTCError.InvalidLineBreakType
        }
        
        for c in text.characters {
            if c == kLineBreakCharacterCR ||
                c == kLineBreakCharacterLF ||
                c == kLineBreakCharacterCRLF ||
                c == kLineBreakCharacterLS {
                ret.append(lbc)
            } else {
                ret.append(c)
            }
        }
        
        return ret
    }
}
