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
        XCTAssertEqual(LineBreak.detectLineBreakInText(text), LineBreakType.Unknown, "No line break")
    }
    
    func testDetectLF() {
        let text = "ABC\nDEF"
        XCTAssertEqual(LineBreak.detectLineBreakInText(text), LineBreakType.LF, "LF")
    }
    
    func testDetectCR() {
        let text = "ABC\rDEF"
        XCTAssertEqual(LineBreak.detectLineBreakInText(text), LineBreakType.CR, "CR")
    }
    
    func testDetectCRLF() {
        let text = "ABC\r\nDEF"
        XCTAssertEqual(LineBreak.detectLineBreakInText(text), LineBreakType.CRLF, "CR+LF")
    }
    
    func testDetectLS() {
        let text = "ABC\u{2028}DEF"
        XCTAssertEqual(LineBreak.detectLineBreakInText(text), LineBreakType.LS, "LS")
    }

    func testDetectLF2() {
        let text = "ABC\n"
        XCTAssertEqual(LineBreak.detectLineBreakInText(text), LineBreakType.LF, "LF")
    }
    
    func testDetectCR2() {
        let text = "ABC\r"
        XCTAssertEqual(LineBreak.detectLineBreakInText(text), LineBreakType.CR, "CR")
    }
    
    func testDetectCRLF2() {
        let text = "ABC\r\n"
        XCTAssertEqual(LineBreak.detectLineBreakInText(text), LineBreakType.CRLF, "CR+LF")
    }
    
    func testDetectLS2() {
        let text = "ABC\u{2028}"
        XCTAssertEqual(LineBreak.detectLineBreakInText(text), LineBreakType.LS, "LS")
    }
    
    func testReplaceWithCR() {
        let text = "A\rB\nC\r\nD\u{2028}E"
        XCTAssertEqual(try! LineBreak.replaceLineBreaksInText(text, type: .CR), "A\rB\rC\rD\rE")
    }
    
    func testReplaceWithLF() {
        let text = "A\rB\nC\r\nD\u{2028}E"
        XCTAssertEqual(try! LineBreak.replaceLineBreaksInText(text, type: .LF), "A\nB\nC\nD\nE")
    }
    
    func testReplaceWithCRLF() {
        let text = "A\rB\nC\r\nD\u{2028}E"
        XCTAssertEqual(try! LineBreak.replaceLineBreaksInText(text, type: .CRLF), "A\r\nB\r\nC\r\nD\r\nE")
    }
    
    func testReplaceWithLS() {
        let text = "A\rB\nC\r\nD\u{2028}E"
        XCTAssertEqual(try! LineBreak.replaceLineBreaksInText(text, type: .LS), "A\u{2028}B\u{2028}C\u{2028}D\u{2028}E")
    }
    
}
