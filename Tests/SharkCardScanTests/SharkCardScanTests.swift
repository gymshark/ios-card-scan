import XCTest
@testable import SharkCardScan

private let jan2020 = 12 * 20
private let dec2020 = 12 * 20 + 11
private let feb2025 = 12 * 25 + 1

class CardScannerTests: XCTestCase {

    func testExtractNumber_valid_numberWithConsecutiveWhitespaceRemoved() {
        XCTAssertEqual(CardScanner.extractNumber("4532238327419367", current: ""), "4532238327419367") // Visa
        XCTAssertEqual(CardScanner.extractNumber("4532 2383 2741 9367", current: ""), "4532 2383 2741 9367")
        XCTAssertEqual(CardScanner.extractNumber("4532  2383  2741  9367", current: ""), "4532 2383 2741 9367")
        XCTAssertEqual(CardScanner.extractNumber("5270675188326095", current: ""), "5270675188326095") // Mastercard
        XCTAssertEqual(CardScanner.extractNumber("676111875722041", current: ""), "676111875722041") // Mastercard (Maestro)
        XCTAssertEqual(CardScanner.extractNumber("378830083510812", current: ""), "378830083510812") // AMEX
        XCTAssertEqual(CardScanner.extractNumber("4984  4263  2665  6373 277", current: ""), "4984 4263 2665 6373 277") // 19 - max digits
        XCTAssertEqual(CardScanner.extractNumber("4532238327413", current: ""), "4532238327413") // 13 - min digits
    }
    
    func testExtractNumber_hasNonNumberSpaceCharacters_nil() {
        XCTAssertNil(CardScanner.extractNumber("C4532238327419367", current: ""))
        XCTAssertNil(CardScanner.extractNumber("453ZZ2238327419367", current: ""))
        XCTAssertNil(CardScanner.extractNumber("453223832-7419367", current: ""))
    }
    
    func testExtractNumber_invalidChecksum_nil() {
        XCTAssertNil(CardScanner.extractNumber("4532238327419362", current: ""))
    }
    
    func testExtractExpiry_valid_months() {
        XCTAssertEqual(CardScanner.extractExpiryInMonthsSince2000("01/20", now: jan2020), jan2020)
        XCTAssertEqual(CardScanner.extractExpiryInMonthsSince2000("12/20", now: jan2020), dec2020)
    }
    
    func testExtractExpiry_pastDate_nil() {
        XCTAssertNil(CardScanner.extractExpiryInMonthsSince2000("12/19", now: jan2020))
    }
    
    func testExtractExpiry_over5YearInTheFuture_nil() {
        XCTAssertNil(CardScanner.extractExpiryInMonthsSince2000("02/25", now: jan2020))
    }
    
    func testExtractExpiry_hasTextBefore_months() {
        XCTAssertEqual(CardScanner.extractExpiryInMonthsSince2000("12/18-12/20", now: jan2020), dec2020)
        XCTAssertEqual(CardScanner.extractExpiryInMonthsSince2000("EXP 12/20", now: jan2020), dec2020)
    }
    
    func testExtractExpiry_hasTextAfter_months() {
        XCTAssertNil(CardScanner.extractExpiryInMonthsSince2000("12/20-12/18", now: jan2020))
        XCTAssertNil(CardScanner.extractExpiryInMonthsSince2000("12/200", now: jan2020))
        XCTAssertNil(CardScanner.extractExpiryInMonthsSince2000("12/20 ", now: jan2020))
    }
    
    func testFormatMonthsSince2000() {
        XCTAssertEqual(CardScanner.format(monthsSince2000: jan2020), "01/20")
    }
    
    static var allTests = [
        ("testFormatMonthsSince2000", testFormatMonthsSince2000),
        ("testExtractExpiry_pastDate_nil", testExtractExpiry_pastDate_nil),
        ("testExtractExpiry_over5YearInTheFuture_nil", testExtractExpiry_over5YearInTheFuture_nil),
        ("testExtractExpiry_hasTextBefore_months", testExtractExpiry_hasTextBefore_months),
        ("testExtractExpiry_hasTextAfter_months", testExtractExpiry_hasTextAfter_months),
        
        ("testExtractExpiry_valid_months", testExtractExpiry_valid_months),
        ("testExtractNumber_invalidChecksum_nil", testExtractNumber_invalidChecksum_nil),
        ("testExtractNumber_hasNonNumberSpaceCharacters_nil", testExtractNumber_hasNonNumberSpaceCharacters_nil),
    ]
}
