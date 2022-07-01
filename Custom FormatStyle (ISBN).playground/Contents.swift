import Foundation
import PlaygroundSupport
import SwiftUI
import XCTest

let isbn = ISBN(
    prefix: "978",
    registrationGroup: "17",
    registrant: "85889",
    publication: "01",
    checkDigit: "1"
)

// MARK: FormatStyle

isbn.formatted() // "978-17-85889-01-1"
isbn.formatted(.isbn()) // "978-17-85889-01-1"
isbn.formatted(.isbn(standard: .isbn13, separator: .hyphen)) // "978-17-85889-01-1"
isbn.formatted(.isbn(standard: .isbn13, separator: .space)) // "978 17 85889 01 1"
isbn.formatted(.isbn(standard: .isbn13, separator: .none)) // "9781785889011"

isbn.formatted(.isbn(standard: .isbn10, separator: .hyphen)) // "17-85889-01-1"
isbn.formatted(.isbn(standard: .isbn10, separator: .space)) // "17 85889 01 1"
isbn.formatted(.isbn(standard: .isbn10, separator: .none)) // "1785889011"

isbn.formatted(.isbn13.separator(.none)) // "9781785889011"
isbn.formatted(.isbn13.separator(.hyphen)) // "978-17-85889-01-1"
isbn.formatted(.isbn13.separator(.space)) // "978 17 85889 01 1"

isbn.formatted(.isbn10.separator(.none)) // "1785889011"
isbn.formatted(.isbn10.separator(.hyphen)) // "17-85889-01-1"
isbn.formatted(.isbn10.separator(.space)) // "17 85889 01 1"

ISBN.FormatStyle().format(isbn) // "978-17-85889-01-1"
ISBN.FormatStyle(.isbn13, separator: .hyphen).format(isbn) // "978-17-85889-01-1"
ISBN.FormatStyle(.isbn13, separator: .space).format(isbn) // "978 17 85889 01 1"
ISBN.FormatStyle(.isbn13, separator: .none).format(isbn) // "9781785889011"
ISBN.FormatStyle(.isbn10, separator: .hyphen).format(isbn) // "17-85889-01-1"
ISBN.FormatStyle(.isbn10, separator: .space).format(isbn) // "17 85889 01 1"
ISBN.FormatStyle(.isbn10, separator: .none).format(isbn) // "1785889011"
ISBN.FormatStyle().separator(.hyphen) // "978-17-85889-01-1"
ISBN.FormatStyle().separator(.space) // "978 17 85889 01 1"
ISBN.FormatStyle().separator(.none) // "9781785889011"
ISBN.FormatStyle().standard(.isbn10).separator(.hyphen) // "17-85889-01-1"
ISBN.FormatStyle().standard(.isbn10).separator(.space) // "17 85889 01 1"
ISBN.FormatStyle().standard(.isbn10).separator(.none) // "1785889011"

// MARK: AttributedString Example

struct AttributedStringExample: View {

    let exampleISBN = ISBN(
        prefix: "978",
        registrationGroup: "17",
        registrant: "85889",
        publication: "01",
        checkDigit: "1"
    )

    var attributedString: AttributedString {
        var attributedISBN = exampleISBN.formatted(.isbn13.attributed)
        for run in attributedISBN.runs {
            if let isbnRun = run.isbnPart {
                switch isbnRun {
                case .prefix:
                    attributedISBN[run.range].foregroundColor = .magenta
                case .registrationGroup:
                    attributedISBN[run.range].foregroundColor = .blue
                case .registrant:
                    attributedISBN[run.range].foregroundColor = .green
                case .publication:
                    attributedISBN[run.range].foregroundColor = .purple
                case .checkDigit:
                    attributedISBN[run.range].foregroundColor = .orange
                case .separator:
                    attributedISBN[run.range].foregroundColor = .red
                }
            }
        }
        return attributedISBN
    }

    var body: some View {
        Text(attributedString)
            .padding(20)
    }
}

let attributedStringExampleView = AttributedStringExample()
PlaygroundPage.current.setLiveView(attributedStringExampleView)

// MARK: ParseableFormatStyle Examples

try? ISBN("978-17-85889-01-1") // ISBN: 978-17-85889-01-1
try? ISBN("978 17 85889 01 1") // ISBN: 978-17-85889-01-1
try? ISBN(" 978-17-85889-01-1 ") // ISBN: 978-17-85889-01-1
try? ISBN("978 17-85889-01-1") // ISBN: 978-17-85889-01-1
try? ISBN("978-1-84356-028-9") // ISBN: 978-1-84356-028-9
try? ISBN("978-0-684-84328-5") // ISBN: 978-0-684-84328-5
try? ISBN("978-0-8044-2957-3") // ISBN: 978-0-8044-2957-3
try? ISBN("978-0-85131-041-1") // ISBN: 978-0-85131-041-1
try? ISBN("978-0-943396-04-0") // ISBN: 978-0-943396-04-0
try? ISBN("978-0-9752298-0-4") // ISBN: 978-0-9752298-0-4

// MARK: - Unit Testing

final class ISBNTests: XCTestCase {

    let isbn = ISBN(
        prefix: "978",
        registrationGroup: "17",
        registrant: "85889",
        publication: "01",
        checkDigit: "1"
    )

    func testISBN13Output() throws {
        let expectedHyphen = "978-17-85889-01-1"
        let expectedSpace = "978 17 85889 01 1"
        let expectedNone = "9781785889011"

        XCTAssertEqual(isbn.formatted(), expectedHyphen)
        XCTAssertEqual(isbn.formatted(.isbn13), expectedHyphen)
        XCTAssertEqual(isbn.formatted(.isbn13.separator(.hyphen)), expectedHyphen)
        XCTAssertEqual(isbn.formatted(.isbn13.separator(.space)), expectedSpace)
        XCTAssertEqual(isbn.formatted(.isbn13.separator(.none)), expectedNone)

        XCTAssertEqual(ISBN.FormatStyle().format(isbn), expectedHyphen)
        XCTAssertEqual(ISBN.FormatStyle(.isbn13, separator: .hyphen).format(isbn), expectedHyphen)
        XCTAssertEqual(ISBN.FormatStyle(.isbn13, separator: .space).format(isbn), expectedSpace)
        XCTAssertEqual(ISBN.FormatStyle(.isbn13, separator: .none).format(isbn), expectedNone)
    }

    func testISBN10Output() throws {
        let expectedHyphen = "17-85889-01-1"
        let expectedSpace = "17 85889 01 1"
        let expectedNone = "1785889011"

        XCTAssertEqual(isbn.formatted(.isbn10), expectedHyphen)
        XCTAssertEqual(isbn.formatted(.isbn10.separator(.hyphen)), expectedHyphen)
        XCTAssertEqual(isbn.formatted(.isbn10.separator(.space)), expectedSpace)
        XCTAssertEqual(isbn.formatted(.isbn10.separator(.none)), expectedNone)

        XCTAssertEqual(ISBN.FormatStyle(.isbn10, separator: .hyphen).format(isbn), expectedHyphen)
        XCTAssertEqual(ISBN.FormatStyle(.isbn10, separator: .space).format(isbn), expectedSpace)
        XCTAssertEqual(ISBN.FormatStyle(.isbn10, separator: .none).format(isbn), expectedNone)
    }

    func testISBNParsing() throws {
        XCTAssertNoThrow(try ISBN("978-17-85889-01-1"))
        XCTAssertNoThrow(try ISBN("978 17 85889 01 1"))
        XCTAssertNoThrow(try ISBN(" 978-17-85889-01-1 "))
        XCTAssertNoThrow(try ISBN("978 17-85889-01-1"))
        XCTAssertNoThrow(try ISBN("978-1-84356-028-9"))
        XCTAssertNoThrow(try ISBN("978-0-684-84328-5"))
        XCTAssertNoThrow(try ISBN("978-0-8044-2957-3"))
        XCTAssertNoThrow(try ISBN("978-0-85131-041-1"))
        XCTAssertNoThrow(try ISBN("978-0-943396-04-0"))
        XCTAssertNoThrow(try ISBN("978-0-9752298-0-4"))

        XCTAssertNoThrow(try ISBN("17-85889-01-1"))
        XCTAssertNoThrow(try ISBN("17 85889 01 1"))

        XCTAssertThrowsError(try ISBN("9780975229804"))
        XCTAssertThrowsError(try ISBN("0"))
        XCTAssertThrowsError(try ISBN("98 17 85889 01 1"))
    }
}

// MARK: An observer to show failures in-line in the playground.

class TestObserver: NSObject, XCTestObservation {
    func testCase(
        _ testCase: XCTestCase,
        didFailWithDescription description: String,
        inFile filePath: String?,
        atLine lineNumber: Int
    ) {
        assertionFailure(description, line: UInt(lineNumber))
    }
}

// Run the tests inside of the playground.
let testObserver = TestObserver()
XCTestObservationCenter.shared.addTestObserver(testObserver)
ISBNTests.defaultTestSuite.run()
