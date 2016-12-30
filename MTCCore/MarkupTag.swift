//
// MarkupTag.swift
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

import Foundation

public class MarkupTag {
    public var name = String()
    public var attributes = [String: String]()
    public var attributesOrder = [String]()
    public var isCloseFormat = false
    public var suffix: String = String()

    public var tagString: String {
        if name.isEmpty {
            return ""
        }

        var tagString = String()
        tagString.append("<")
        tagString.append(self.name)

        if self.attributes.count > 0 && self.attributes.count == self.attributesOrder.count {
            // Append attributes
            for attr in self.attributesOrder {
                if let attrValue = self.attributes[attr] {
                    tagString.append(" \(attr)=\"\(attrValue)\"")
                }

            }
        }

        if self.isCloseFormat {
            tagString.append(" /")
        }

        if !self.suffix.isEmpty {
            tagString.append(self.suffix)
        }

        tagString.append(">")
        return tagString
    }
}
