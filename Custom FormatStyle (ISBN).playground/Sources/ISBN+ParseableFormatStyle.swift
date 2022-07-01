import Foundation

// MARK: Add Validation to ISBN

public extension ISBN {

    // Define our validation errors
    enum ValidationError: Error {
        case emptyInput
        case noGroupsPresent
        case invalidStringLength
        case invalidCharacters
        case checksumFailed
    }

    // Define our valid character set. We avoid using CharacterSet.decimalDigit since that includes
    // all unicode characters which represents digits. ISBN values only use the Arabic numerals,
    // hyphens, or spaces.
    static let validCharacterSet = CharacterSet(charactersIn: "0123456789").union(validSeparatorsSet)

    // Define our valid separators.
    static let validSeparatorsSet = CharacterSet(charactersIn: "- ")

    // Define the "Bookland" prefix (https://en.wikipedia.org/wiki/Bookland) to convert ISBN-10 values to ISBN-13
    static let booklandPrefix = "978"

    /// Returns a validated, 13 digit ISBN string.
    /// https://en.wikipedia.org/wiki/ISBN#ISBN-13_check_digit_calculation
    /// - Parameter value: A string representation of an ISBN
    /// - Returns: String, the valid String that passed the check.
    static func validate(_ candidate: String?) throws -> String {

        // Unwrap the value passed in.
        guard let candidate = candidate else { throw ValidationError.emptyInput }

        // Validate that we have spacers present, otherwise we're not going to be able to parse out
        // any ISBN values
        guard candidate.rangeOfCharacter(from: Self.validSeparatorsSet) != nil else {
            throw ValidationError.noGroupsPresent
        }

        // Trim any leading and trailing whitespace and newlines.
        // Newlines will fail on the next check.
        let trimmedString = candidate.trimmingCharacters(in: .whitespaces)

        // Check for the existence of any invalid characters.
        // We invert validCharacterSet to represent every other character in unicode than what is valid.
        // If rangeOfCharacter returns a value, we know that those characters exist (and therefore fails)
        guard trimmedString.rangeOfCharacter(from: Self.validCharacterSet.inverted) == nil else {
            // So we throw the appropriate error
            throw ValidationError.invalidCharacters
        }

        // Convert any ISBN-10 values into ISBN13 values by adding
        // the "Bookland" prefix (https://en.wikipedia.org/wiki/Bookland)
        let isbn13String = trimmedString.count == 10 ? Self.booklandPrefix + trimmedString : trimmedString

        // Run the ISBN 13 checksum calculation
        // https://en.wikipedia.org/wiki/ISBN#ISBN-13_check_digit_calculation
        // Use the reduce method to run the checksum, starting with 0
        // We enumerate the string because we need the position (it's offset) for each character, as
        // well as the number itself.

        // Start by removing all of the hyphens
        let isbnString = isbn13String.components(separatedBy: .decimalDigits.inverted).joined()

        // Verify that we have either 10 or 13 characters at this point.
        guard [10, 13].contains(isbnString.count) else {
            throw ValidationError.invalidStringLength
        }

        // First, we take the sum of the number. Multiplying each digit by either 1 or 3.
        let sum = isbnString.enumerated().reduce(0) { partialResult, character in

            // Safely convert the character into an integer.
            guard let number = character.element.wholeNumberValue else {
                return partialResult
            }
            // We alternate multiplying each character by 1 or 3
            let multiplier = character.offset % 2 == 0 ? 1 : 3
            // We then multiply the number by the multiplier, and add it to the previous result
            return partialResult + (number * multiplier)
        }
        // We then  make sure that the number is cleanly divisible by 10 by using the modulo function.
        guard sum % 10 == 0 else {
            throw ValidationError.checksumFailed
        }

        // Success. Return the original ISBN-10 or ISBN-13 string
        return trimmedString
    }
}

public extension ISBN.FormatStyle {

    enum DecodingError: Error {
        case invalidInput
    }

    struct ParseStrategy: Foundation.ParseStrategy {

        public init() {}

        public func parse(_ value: String) throws -> ISBN {
            // Trim the input string any leading or trailing whitespaces
            let trimmedValue = value.trimmingCharacters(in: .whitespaces)

            // Attempt to validate our trimmed string
            let validISBN = try ISBN.validate(trimmedValue)

            // Create an array of strings based on the separator used.
            let components = validISBN.components(separatedBy: ISBN.validSeparatorsSet)

            // Having 4 components means that we were given an ISBN-10 number.
            // Therefore we need to convert it.
            let finalComponents = components.count == 4 ? [ISBN.booklandPrefix] + components : components

            // Since we're going to use subscripts to access each value in the array, it's a good
            // idea to verify that all values are present to avoid crashing.
            guard finalComponents.count == 5 else {
                throw DecodingError.invalidInput
            }

            // Build the final ISBN from the component parts.
            return ISBN(
                prefix: finalComponents[0],
                registrationGroup: finalComponents[1],
                registrant: finalComponents[2],
                publication: finalComponents[3],
                checkDigit: finalComponents[4]
            )
        }
    }
}

// MARK: ParseableFormatStyle conformance on ISBN.FormatStyle

extension ISBN.FormatStyle: ParseableFormatStyle {
    public var parseStrategy: ISBN.FormatStyle.ParseStrategy {
        .init()
    }
}

// MARK: Convenience members on ISBN to simplify access to the ParseStrategy

public extension ISBN {

    init(_ string: String) throws {
        self = try ISBN.FormatStyle().parseStrategy.parse(string)
    }

    init<T, Value>(_ value: Value, standard: T) throws where T: ParseStrategy, Value: StringProtocol, T.ParseInput == String, T.ParseOutput == ISBN {
        self = try standard.parse(value.description)
    }
}

// MARK: Extend ParseableFormatStyle to simplify access to the format style

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension ParseableFormatStyle where Self == ISBN.FormatStyle {
    static var isbn: Self { .init() }
}
