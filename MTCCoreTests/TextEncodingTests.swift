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
    
    private func resourceFileWithName(_ fileName: String) -> String {
        let baseName = (fileName as NSString).deletingPathExtension
        let ext = (fileName as NSString).pathExtension
        let path = Bundle(for: type(of: self)).path(forResource: baseName, ofType: ext)
        XCTAssertNotNil(path, "Resource file is not found")
        return path!
    }
    
    private func dataWithFileName(_ fileName: String) -> Data {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: self.resourceFileWithName(fileName)))
            XCTAssertNotNil(data, "Couldn't read the resource file")
            return data
        } catch {
            fatalError("Failed read file")
        }
    }

    func testDetectUTF8() {
        let data = dataWithFileName("UTF8.txt")
        let encodingInfo = TextEncoding.encoding(of: data)

        XCTAssertEqual(encodingInfo.encoding, .utf8)
        XCTAssertEqual(encodingInfo.hasBOM, false)
        XCTAssertEqual(encodingInfo.byteOrder, nil)
    }

    func testDetectUTF8_BOM() {
        let data = dataWithFileName("UTF8_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)

        XCTAssertEqual(encodingInfo.encoding, .utf8)
        XCTAssertEqual(encodingInfo.hasBOM, true)
        XCTAssertEqual(encodingInfo.byteOrder, nil)
    }
    
    func testDetectUTF16LE() {
        let data = dataWithFileName("UTF16LE.txt")
        let encodingInfo = TextEncoding.encoding(of: data)

        XCTAssertEqual(encodingInfo.encoding, .utf16)
        XCTAssertEqual(encodingInfo.hasBOM, false)
        XCTAssertEqual(encodingInfo.byteOrder, .littleEndian)
    }

    func testDetectUTF16LE_BOM() {
        let data = dataWithFileName("UTF16LE_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)

        XCTAssertEqual(encodingInfo.encoding, .utf16)
        XCTAssertEqual(encodingInfo.hasBOM, true)
        XCTAssertEqual(encodingInfo.byteOrder, .littleEndian)
    }

    func testDetectUTF16BE() {
        let data = dataWithFileName("UTF16BE.txt")
        let encodingInfo = TextEncoding.encoding(of: data)

        XCTAssertEqual(encodingInfo.encoding, .utf16)
        XCTAssertEqual(encodingInfo.hasBOM, false)
        XCTAssertEqual(encodingInfo.byteOrder, .bigEndian)
    }
    
    func testDetectUTF16BE_BOM() {
        let data = dataWithFileName("UTF16BE_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)

        XCTAssertEqual(encodingInfo.encoding, .utf16)
        XCTAssertEqual(encodingInfo.hasBOM, true)
        XCTAssertEqual(encodingInfo.byteOrder, .bigEndian)
    }

    func testDetectUTF32LE() {
        let data = dataWithFileName("UTF32LE.txt")
        let encodingInfo = TextEncoding.encoding(of: data)

        XCTAssertEqual(encodingInfo.encoding, .utf32)
        XCTAssertEqual(encodingInfo.hasBOM, false)
        XCTAssertEqual(encodingInfo.byteOrder, .littleEndian)
    }
    
    func testDetectUTF32LE_BOM() {
        let data = dataWithFileName("UTF32LE_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        XCTAssertEqual(encodingInfo.encoding, .utf32)
        XCTAssertEqual(encodingInfo.hasBOM, true)
        XCTAssertEqual(encodingInfo.byteOrder, .littleEndian)
    }
    
    func testDetectUTF32BE() {
        let data = dataWithFileName("UTF32BE.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        XCTAssertEqual(encodingInfo.encoding, .utf32)
        XCTAssertEqual(encodingInfo.hasBOM, false)
        XCTAssertEqual(encodingInfo.byteOrder, .bigEndian)
    }
    
    func testDetectUTF32BE_BOM() {
        let data = dataWithFileName("UTF32BE_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        XCTAssertEqual(encodingInfo.encoding, .utf32)
        XCTAssertEqual(encodingInfo.hasBOM, true)
        XCTAssertEqual(encodingInfo.byteOrder, .bigEndian)
    }
    
    func testReadTextEUCJP() {
        let data = dataWithFileName("EUCJP.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }
    
    func testReadTextJIS() {
        let data = dataWithFileName("JIS.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextSJIS() {
        let data = dataWithFileName("SJIS.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextUTF8() {
        let data = dataWithFileName("UTF8.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }
    
    func testReadTextUTF8_BOM() {
        let data = dataWithFileName("UTF8_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextUTF16BE() {
        let data = dataWithFileName("UTF16BE.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextUTF16BE_BOM() {
        let data = dataWithFileName("UTF16BE_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextUTF16LE() {
        let data = dataWithFileName("UTF16LE.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextUTF16LE_BOM() {
        let data = dataWithFileName("UTF16LE_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testReadTextUTF32BE() {
        let data = dataWithFileName("UTF32BE.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }
    
    func testReadTextUTF32BE_BOM() {
        let data = dataWithFileName("UTF32BE_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }
    
    func testReadTextUTF32LE() {
        let data = dataWithFileName("UTF32LE.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }
    
    func testReadTextUTF32LE_BOM() {
        let data = dataWithFileName("UTF32LE_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str, "Failed read the text with the encoding info")
    }

    func testCreateTextEUCJP() {
        let data = dataWithFileName("EUCJP.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }

    func testCreateTextJIS() {
        let data = dataWithFileName("JIS.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }
    
    func testCreateTextSJIS() {
        let data = dataWithFileName("SJIS.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }

    func testCreateTextUTF8() {
        let data = dataWithFileName("UTF8.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }

    func testCreateTextUTF8_BOM() {
        let data = dataWithFileName("UTF8_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }

    func testCreateTextUTF16BE() {
        let data = dataWithFileName("UTF16BE.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }

    func testCreateTextUTF16BE_BOM() {
        let data = dataWithFileName("UTF16BE_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }

    func testCreateTextUTF16LE() {
        let data = dataWithFileName("UTF16LE.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }

    func testCreateTextUTF16LE_BOM() {
        let data = dataWithFileName("UTF16LE_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }

    func testCreateTextUTF32BE() {
        let data = dataWithFileName("UTF32BE.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }

    func testCreateTextUTF32BE_BOM() {
        let data = dataWithFileName("UTF32BE_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }

    func testCreateTextUTF32LE() {
        let data = dataWithFileName("UTF32LE.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }

    func testCreateTextUTF32LE_BOM() {
        let data = dataWithFileName("UTF32LE_BOM.txt")
        let encodingInfo = TextEncoding.encoding(of: data)
        let str = String(data: data, textEncodingInfo: encodingInfo)
        XCTAssertNotNil(str)
        
        let data2 = str!.data(using: encodingInfo)
        XCTAssertNotNil(data2)
        XCTAssertEqual(data2, data2)
    }
    
    func testReplaceHankakuKatakana() {
        let text1 = ""
        XCTAssertEqual(text1.replacingHankakuKatakana, text1)
        
        let text2 = "ABC"
        XCTAssertEqual(text2.replacingHankakuKatakana, text2)
        
        let text3 = "ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｵﾝ"
        let text3a = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワオン"
        XCTAssertEqual(text3.replacingHankakuKatakana, text3a)
        
        let text4 = "ｶﾞｷﾞｸﾞｹﾞｺﾞｻﾞｼﾞｽﾞｾﾞｿﾞﾀﾞﾁﾞﾂﾞﾃﾞﾄﾞﾊﾞﾋﾞﾌﾞﾍﾞﾎﾞﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ"
        let text4a = "ガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポ"
        XCTAssertEqual(text4.replacingHankakuKatakana, text4a)
        
        let text5 = "｡｢｣､･ｰｧｨｩｪｫｬｭｮｯ"
        let text5a = "。「」、・ーァィゥェォャュョッ"
        XCTAssertEqual(text5.replacingHankakuKatakana, text5a)
    }
}
