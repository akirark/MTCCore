//
//  LineBreakTests.swift
//  MTCCore
//
//  Created by Akira Hayashi on 2016/04/18.
//  Copyright (c) 2016 Akira Hayashi
//

import XCTest
@testable import MTCCore

class LineBreakTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testDetectUnknown() {
        let text = "ABCDEFG"
        XCTAssertEqual(LineBreak.lineBreakType(inText: text), nil, "No line break")
    }
    
    func testDetectLF() {
        let text = "ABC\nDEF"
        XCTAssertEqual(LineBreak.lineBreakType(inText: text), .lf, "LF")
    }
    
    func testDetectCR() {
        let text = "ABC\rDEF"
        XCTAssertEqual(LineBreak.lineBreakType(inText: text), .cr, "CR")
    }
    
    func testDetectCRLF() {
        let text = "ABC\r\nDEF"
        XCTAssertEqual(LineBreak.lineBreakType(inText: text), .crlf, "CR+LF")
    }
    
    func testDetectLS() {
        let text = "ABC\u{2028}DEF"
        XCTAssertEqual(LineBreak.lineBreakType(inText: text), .ls, "LS")
    }

    func testDetectLF2() {
        let text = "ABC\n"
        XCTAssertEqual(LineBreak.lineBreakType(inText: text), .lf, "LF")
    }
    
    func testDetectCR2() {
        let text = "ABC\r"
        XCTAssertEqual(LineBreak.lineBreakType(inText: text), .cr, "CR")
    }
    
    func testDetectCRLF2() {
        let text = "ABC\r\n"
        XCTAssertEqual(LineBreak.lineBreakType(inText: text), .crlf, "CR+LF")
    }
    
    func testDetectLS2() {
        let text = "ABC\u{2028}"
        XCTAssertEqual(LineBreak.lineBreakType(inText: text), .ls, "LS")
    }
    
    func testReplaceWithCR() {
        let text = "A\rB\nC\r\nD\u{2028}E"
        XCTAssertEqual(LineBreak.replaceLineBreaks(inText: text, to: .cr), "A\rB\rC\rD\rE")
    }
    
    func testReplaceWithLF() {
        let text = "A\rB\nC\r\nD\u{2028}E"
        XCTAssertEqual(LineBreak.replaceLineBreaks(inText: text, to: .lf), "A\nB\nC\nD\nE")
    }
    
    func testReplaceWithCRLF() {
        let text = "A\rB\nC\r\nD\u{2028}E"
        XCTAssertEqual(LineBreak.replaceLineBreaks(inText: text, to: .crlf), "A\r\nB\r\nC\r\nD\r\nE")
    }
    
    func testReplaceWithLS() {
        let text = "A\rB\nC\r\nD\u{2028}E"
        XCTAssertEqual(LineBreak.replaceLineBreaks(inText: text, to: .ls), "A\u{2028}B\u{2028}C\u{2028}D\u{2028}E")
    }
    
}
