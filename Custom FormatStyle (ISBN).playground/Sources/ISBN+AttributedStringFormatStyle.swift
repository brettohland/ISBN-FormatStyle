import Foundation

// We need to create a new AttributedScope to contain our new attributes.
public extension AttributeScopes {

    /// Represents the parts of an ISBN which we will be adding attributes to.
    enum ISBNPart: Hashable {
        case prefix
        case registrationGroup
        case registrant
        case publication
        case checkDigit
        case separator
    }

    // Define our new AttributeScope
    struct ISBNAttributes: AttributeScope {
        // Our property value to access it.
        public let isbnPart: ISBNAttributeKey
    }

    // We follow the AttributeStringKey protocol to define our new attribute.
    enum ISBNAttributeKey: AttributedStringKey {
        public typealias Value = ISBNPart
        public static let name = "isbnPart"
    }

    // This extends AttributeScope to allow us to access our new ISBNPart type quickly.
    var isbnPart: ISBNPart.Type { ISBNPart.self }
}

// We extend AttributeDynamicLookup to know about our custom type.
public extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(dynamicMember keyPath: KeyPath<AttributeScopes.ISBNAttributes, T>) -> T {
        self[T.self]
    }
}

// MARK: - AttributedString output FormatStyle

public extension ISBN {

    /// An ISBN FormatStyle for outputting AttributedString values.
    struct AttributedStringFormatStyle: Codable, Foundation.FormatStyle {

        private let standard: ISBN.FormatStyle.Standard
        private let separator: ISBN.FormatStyle.Separator

        /// Initialize an ISBN FormatStyle with the given Standard
        /// - Parameter standard: Standard (required)
        public init(standard: ISBN.FormatStyle.Standard, separator: ISBN.FormatStyle.Separator) {
            self.standard = standard
            self.separator = separator
        }

        // The format method required by the FormatStyle protocol.
        public func format(_ value: ISBN) -> AttributedString {

            // Creates AttributedString representations of each part of the ISBN
            var prefix = AttributedString(value.prefix)
            var group = AttributedString(value.registrationGroup)
            var registrant = AttributedString(value.registrant)
            var publication = AttributedString(value.publication)
            var checkDigit = AttributedString(value.checkDigit)

            // Assigns our custom attribute scope attribute to each part.
            prefix.isbnPart = .prefix
            group.isbnPart = .registrationGroup
            registrant.isbnPart = .registrant
            publication.isbnPart = .publication
            checkDigit.isbnPart = .checkDigit

            // Collect all parts in an array to allow for simple AttributedString concatenation using reduce
            let parts = [
                prefix,
                group,
                registrant,
                publication,
                checkDigit,
            ]

            // Create the final AttributedString by using the reduce method. We define the
            switch standard {
            case .isbn13 where separator == .none:
                // Merge all parts into one string.
                return parts.reduce(AttributedString(), +)
            case .isbn13:
                // Define the delimiter
                var separator = AttributedString(separator.rawValue)
                separator.isbnPart = .separator
                // Starting with the .prefix, use reduce to build the final AttributedString.
                return parts.dropFirst().reduce(prefix) { $0 + separator + $1 }
            case .isbn10 where separator == .none:
                // Drop the prefix, merge all parts.
                return parts.dropFirst().reduce(group, +)
            case .isbn10:
                // Define the delimiter
                var separator = AttributedString(separator.rawValue)
                separator.isbnPart = .separator
                // Drop the first two elements (prefix and group), then build the final AttributedString
                return parts.dropFirst(2).reduce(group) { $0 + separator + $1 }
            }
        }
    }
}

// MARK: AttributedStringFormatStyle convenience accessors

// Add our new attributed method chain to our format style.
public extension ISBN.FormatStyle {
    var attributed: ISBN.AttributedStringFormatStyle {
        .init(standard: standard, separator: separator)
    }
}
