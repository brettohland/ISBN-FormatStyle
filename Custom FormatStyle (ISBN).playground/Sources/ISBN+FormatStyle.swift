import Foundation

public extension ISBN {

    struct FormatStyle: Codable, Equatable, Hashable {

        /// Defines which ISBN standard to output
        public enum Standard: Codable, Equatable, Hashable {
            /// ISBN-13
            case isbn13
            /// ISBN-10
            case isbn10
        }

        public enum Separator: String, Codable, Equatable, Hashable {
            case hyphen = "-"
            case space = " "
            case none = ""
        }

        let standard: Standard
        let separator: Separator

        /// Initialize an ISBN FormatStyle with the given Standard
        /// - Parameter standard: Standard, defaults to .isbn13(.hyphen)
        public init(_ standard: Standard = .isbn13, separator: Separator = .hyphen) {
            self.standard = standard
            self.separator = separator
        }

        // MARK: Customization Method Chaining

        public func standard(_ standard: Standard) -> Self {
            .init(standard, separator: separator)
        }

        /// Returns a new instance of `self` with the standard property set.
        /// - Parameter standard: The standard to use on the final output
        /// - Returns: A copy of `self` with the standard set
        public func separator(_ separator: Separator) -> Self {
            .init(standard, separator: separator)
        }
    }
}

extension ISBN.FormatStyle: Foundation.FormatStyle {
    /// Returns a textual representation of the `ISBN` value passed in.
    /// - Parameter value: A `ISBN` value
    /// - Returns: The textual representation of the value, using the style's `standard`.
    public func format(_ value: ISBN) -> String {
        let parts = [
            value.prefix,
            value.registrationGroup,
            value.registrant,
            value.publication,
            value.checkDigit,
        ]
        switch standard {
        case .isbn13:
            return parts.joined(separator: separator.rawValue)
        case .isbn10:
            // ISBN-10 is missing the "prefix" portion of the number.
            return parts.dropFirst().joined(separator: separator.rawValue)
        }
    }
}

// MARK: Convenience methods to access the formatted value

public extension ISBN {

    /// Converts `self` to its textual representation.
    /// - Returns: String
    func formatted() -> String {
        Self.FormatStyle().format(self)
    }

    /// Converts `self` to another representation.
    /// - Parameter style: The format for formatting `self`
    /// - Returns: A representations of `self` using the given `style`. The type of the return is determined by the FormatStyle.FormatOutput
    func formatted<F: Foundation.FormatStyle>(_ style: F) -> F.FormatOutput where F.FormatInput == ISBN {
        style.format(self)
    }
}

// MARK: Convenience FormatStyle extensions to ease access

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
public extension FormatStyle where Self == ISBN.FormatStyle {

    static var isbn13: Self { .init(.isbn13, separator: .hyphen) }
    static var isbn10: Self { .init(.isbn10, separator: .hyphen) }

    static func isbn(
        standard: ISBN.FormatStyle.Standard = .isbn13,
        separator: ISBN.FormatStyle.Separator = .hyphen
    ) -> Self {
        .init(standard, separator: separator)
    }
}

// MARK: - Debug Methods on ISBN

extension ISBN: CustomDebugStringConvertible {
    public var debugDescription: String {
        "ISBN: \(formatted())"
    }
}
