import Foundation

/// Represents a 13 digit International Standard Book Number.
public struct ISBN: Codable, Sendable, Equatable, Hashable {
    public let prefix: String
    public let registrationGroup: String
    public let registrant: String
    public let publication: String
    public let checkDigit: String

    /// Initializes a new ISBN struct
    /// - Parameters:
    ///   - prefix: The prefix to the registration group
    ///   - registrationGroup: The registration group (as numbers)
    ///   - registrant: The registrant (as number)
    ///   - publication: The publication (as numbers)
    ///   - checkDigit: The check digit used in validation
    public init(
        prefix: String,
        registrationGroup: String,
        registrant: String,
        publication: String,
        checkDigit: String
    ) {
        self.prefix = prefix
        self.registrationGroup = registrationGroup
        self.registrant = registrant
        self.publication = publication
        self.checkDigit = checkDigit
    }
}
