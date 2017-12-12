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

/// The LineBreak class detects and replaces line breaks
public final class LineBreak {

    /// Line break types
    public enum `Type`: Character {
        case lf = "\n"
        case cr = "\r"
        case crlf = "\r\n"
        case ls = "\u{2028}"
    }

    public init() {
        
    }
    
    /// Detects the line break type of the text
    /// \param text The text to be checked
    /// \return Detected line break type
    public static func lineBreakType(inText text: String) -> Type? {

        for c in text {
            if let type = Type(rawValue: c) {
                return type
            }
        }

        return nil
    }

    /// Replaces line breaks
    /// \param text The text
    /// \param type The new line break type
    /// \return The new text
    public static func replaceLineBreaks(inText text: String, to type: Type) -> String {
        let lbc = type.rawValue
        var replacedText = ""

        for c in text {
            if let _ = Type(rawValue: c) {
                replacedText.append(lbc)
            } else {
                replacedText.append(c)
            }
        }
        
        return replacedText
    }
}
