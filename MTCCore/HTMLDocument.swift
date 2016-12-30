//
//  HTMLDocument.swift
//  MTCCore
//
// Created by Akira Hayashi on 2016/12/30.
//
//  -----------------------------------------------------------------
//
//  Copyright (c) 2016 Akira Hayashi
//  This software is released under the Apache 2.0 License,
//  see LICENSE.txt for license information
//
//  -----------------------------------------------------------------
//
//

import Foundation

public class HTMLDocument {

    /// HTML Source Text
    public var htmlText = String()

    /// Find the next markup tag
    ///
    /// @param offset The start offset
    /// @return Returns founded markup tag, otherwise nil.
    public func nextMarkupTag(from offset: String.Index) -> MarkupTag? {
        return nil
    }

    /// Find the next markup tag
    ///
    /// @param offset The start offset
    /// @param name The tag name
    /// @return Returns founded markup tag, otherwise nil.
    public func nextMarkupTag(from offset: String.Index, name: String) -> MarkupTag? {
        return nil
    }

    /// Replace the markup tag
    ///
    /// @param offset The start offset of the markup tag will be replaced
    /// @param length The length of the markup tag
    /// @param markupTag The new markup tag
    /// @return Returns true if it is succeeded.
    public func replaceMarkupTag(at offset: String.Index, length: Int, with markupTag: MarkupTag) -> Bool {
        return false
    }

    /// Insert the markup tag
    ///
    /// @param markupTag The markup tag will be inserted
    /// @param offset The insert offset
    public func insertMarkupTag(_ markupTag: MarkupTag, at offset: String.Index) {

    }

    /// Returns the text of the markup tag
    /// @return The founded text.
    public func markupTagString(from offset: String.Index) -> String {

    }
}

public extension HTMLDocument {
    public var encodingSpecifier: MarkupTag? {
        get {
            return nil
        }
    }
}

public extension HTMLDocument {
    public var XMLProcInstTag: MarkupTag? {
        get {
            return nil
        }
    }
}
