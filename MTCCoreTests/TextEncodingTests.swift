//
//  TextEncodingTests.swift
//  MTCCore
//
//  Created by Akira Hayashi on 2016/04/21.
//  Copyright (c) 2016 Akira Hayashi
//

import XCTest
@testable import MTCCore

class TextEncodingTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    private func resourceFileWithName(fileName: String) -> String {
        let baseName = (fileName as NSString).stringByDeletingPathExtension
        let ext = (fileName as NSString).pathExtension
        let path = NSBundle(forClass: self.dynamicType).pathForResource(baseName, ofType: ext)
        XCTAssertNotNil(path, "Resource file is not found")
        return path!
    }
    
    private func dataWithFileName(fileName: String) -> NSData {
        let data = NSData(contentsOfFile: self.resourceFileWithName(fileName))
        XCTAssertNotNil(data, "Couldn't read the resource file")
        return data!
    }

    func testDetectUTF8() {
        let data = dataWithFileName("UTF8.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        XCTAssertEqual(encodingInfo.encodingCode, EncodingCode.UTF8)
        XCTAssertEqual(encodingInfo.hasBOM, false)
        XCTAssertEqual(encodingInfo.byteOrder, ByteOrder.Unknown)
    }

    func testDetectUTF8_BOM() {
        let data = dataWithFileName("UTF8_BOM.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        XCTAssertEqual(encodingInfo.encodingCode, EncodingCode.UTF8)
        XCTAssertEqual(encodingInfo.hasBOM, true)
        XCTAssertEqual(encodingInfo.byteOrder, ByteOrder.Unknown)
    }
    
    func testDetectUTF16LE() {
        let data = dataWithFileName("UTF16LE.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        XCTAssertEqual(encodingInfo.encodingCode, EncodingCode.UTF16)
        XCTAssertEqual(encodingInfo.hasBOM, false)
        XCTAssertEqual(encodingInfo.byteOrder, ByteOrder.LE)
    }

    func testDetectUTF16LE_BOM() {
        let data = dataWithFileName("UTF16LE_BOM.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        XCTAssertEqual(encodingInfo.encodingCode, EncodingCode.UTF16)
        XCTAssertEqual(encodingInfo.hasBOM, true)
        XCTAssertEqual(encodingInfo.byteOrder, ByteOrder.LE)
    }

    func testDetectUTF16BE() {
        let data = dataWithFileName("UTF16BE.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        XCTAssertEqual(encodingInfo.encodingCode, EncodingCode.UTF16)
        XCTAssertEqual(encodingInfo.hasBOM, false)
        XCTAssertEqual(encodingInfo.byteOrder, ByteOrder.BE)
    }
    
    func testDetectUTF16BE_BOM() {
        let data = dataWithFileName("UTF16BE_BOM.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        XCTAssertEqual(encodingInfo.encodingCode, EncodingCode.UTF16)
        XCTAssertEqual(encodingInfo.hasBOM, true)
        XCTAssertEqual(encodingInfo.byteOrder, ByteOrder.BE)
    }

    func testDetectUTF32LE() {
        let data = dataWithFileName("UTF32LE.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        XCTAssertEqual(encodingInfo.encodingCode, EncodingCode.UTF32)
        XCTAssertEqual(encodingInfo.hasBOM, false)
        XCTAssertEqual(encodingInfo.byteOrder, ByteOrder.LE)
    }
    
    func testDetectUTF32LE_BOM() {
        let data = dataWithFileName("UTF32LE_BOM.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        XCTAssertEqual(encodingInfo.encodingCode, EncodingCode.UTF32)
        XCTAssertEqual(encodingInfo.hasBOM, true)
        XCTAssertEqual(encodingInfo.byteOrder, ByteOrder.LE)
    }
    
    func testDetectUTF32BE() {
        let data = dataWithFileName("UTF32BE.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        XCTAssertEqual(encodingInfo.encodingCode, EncodingCode.UTF32)
        XCTAssertEqual(encodingInfo.hasBOM, false)
        XCTAssertEqual(encodingInfo.byteOrder, ByteOrder.BE)
    }
    
    func testDetectUTF32BE_BOM() {
        let data = dataWithFileName("UTF32BE_BOM.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        XCTAssertEqual(encodingInfo.encodingCode, EncodingCode.UTF32)
        XCTAssertEqual(encodingInfo.hasBOM, true)
        XCTAssertEqual(encodingInfo.byteOrder, ByteOrder.BE)
    }
    
    func testReadTextEUCJP() {
        let data = dataWithFileName("EUCJP.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }
    
    func testReadTextJIS() {
        let data = dataWithFileName("JIS.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextSJIS() {
        let data = dataWithFileName("SJIS.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextUTF8() {
        let data = dataWithFileName("UTF8.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }
    
    func testReadTextUTF8_BOM() {
        let data = dataWithFileName("UTF8_BOM.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextUTF16BE() {
        let data = dataWithFileName("UTF16BE.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextUTF16BE_BOM() {
        let data = dataWithFileName("UTF16BE_BOM.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextUTF16LE() {
        let data = dataWithFileName("UTF16LE.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextUTF16LE_BOM() {
        let data = dataWithFileName("UTF16LE_BOM.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextUTF32BE() {
        let data = dataWithFileName("UTF32BE.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }
    
    func testReadTextUTF32BE_BOM() {
        let data = dataWithFileName("UTF32BE_BOM.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }
    
    func testReadTextUTF32LE() {
        let data = dataWithFileName("UTF32LE.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }
    
    func testReadTextUTF32LE_BOM() {
        let data = dataWithFileName("UTF32LE_BOM.txt")
        let encodingInfo = TextEncoding.detectTextEncodingOfTextBuffer(data.bytes, length: data.length)
        
        let str = NSString(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

}
