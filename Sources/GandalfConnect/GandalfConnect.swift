import Foundation

public enum GandalfErrorCode: String {
    case DataKeyNotFound
    case InvalidPublicKey
    case InvalidService
    case InvalidRedirectURL
}

public struct GandalfError: Error {
    public let message: String
    public let code: GandalfErrorCode
}

public struct StylingOptions {
    public var primaryColor: String?
    public var backgroundColor: String?
    public var foregroundColor: String?
    public var accentColor: String?
}

public struct ConnectOptions {
    public var style: StylingOptions
}

public struct Service {
    public var traits: [String]?
    public var activities: [String]?
    public var required: Bool
    
    public init(traits: [String]? = nil, activities: [String]? = nil, required: Bool = true) {
        self.traits = traits
        self.activities = activities
        self.required = required
    }
}

public enum InputDataValue {
    case boolean(Bool)
    case service(Service)
}

public typealias InputData = [String: InputDataValue]

public struct ConnectInput {
    public var publicKey: String
    public var redirectURL: String
    public var services: InputData
    public var options: ConnectOptions? = nil
    
    public init(publicKey: String, redirectURL: String, services: InputData, options: ConnectOptions) {
        self.publicKey = publicKey
        self.redirectURL = redirectURL
        self.services = services
        self.options = options
    }
}

public class Connect {
    public var publicKey: String
    public var redirectURL: String
    public var data: InputData
    public var verificationComplete: Bool = false
    public var options: ConnectOptions? = nil
    
    public init(input: ConnectInput) {
        self.publicKey = input.publicKey
        self.redirectURL = input.redirectURL.hasSuffix("/") ? String(input.redirectURL.dropLast()) : input.redirectURL
        self.data = input.services
        self.options = input.options
    }
    
    public func generateURL() async throws -> String {
        let inputData = data
        try await allValidations(publicKey: publicKey, redirectURL: redirectURL, data: inputData)

        let inputDataDictionary = self.dataToDictionary(inputData)

        if let style = options?.style {
            inputDataDictionary.merge(self.styleToDictionary(style)) { (current, _) in current }
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: inputDataDictionary)
        let dataString = String(data: jsonData, encoding: .utf8) ?? ""
        print(jsonData)
        
        let appClipURL = encodeComponents(data: dataString, redirectUrl: redirectURL, publicKey: publicKey)
        return appClipURL
    }
    
    private func dataToDictionary(_ inputData: InputData) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        for (key, value) in inputData {
            switch value {
            case .boolean(let boolValue):
                dictionary[key] = boolValue
            case .service(let serviceValue):
                dictionary[key] = [
                    "traits": serviceValue.traits ?? [],
                    "activities": serviceValue.activities ?? [],
                    "required": serviceValue.required
                ]
            }
        }
        return dictionary
    }

    private func styleToDictionary(_ style: StylingOptions) -> [String: Any] {
        var dictionary: [String: Any] = [:]
        if let primaryColor = style.primaryColor {
            dictionary["primaryColor"] = primaryColor
        }
        if let backgroundColor = style.backgroundColor {
            dictionary["backgroundColor"] = backgroundColor
        }
        if let foregroundColor = style.foregroundColor {
            dictionary["foregroundColor"] = foregroundColor
        }
        if let accentColor = style.accentColor {
            dictionary["accentColor"] = accentColor
        }
        return dictionary
    }
    
    private static func getSupportedServicesAndTraits() async throws -> SupportedServicesAndTraits {
        return try await withCheckedThrowingContinuation { continuation in
            NetworkManager.shared.fetchSupportedServicesAndTraits { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    public static func getDataKeyFromURL(redirectURL: String) throws -> String {
        try validateRedirectURL(url: redirectURL)
        guard let urlComponents = URLComponents(string: redirectURL),
              let dataKey = urlComponents.queryItems?.first(where: { $0.name == "dataKey" })?.value else {
            throw GandalfError(message: "Datakey not found in the URL \(redirectURL)", code: .DataKeyNotFound)
        }
        return dataKey
    }
    
    private func encodeComponents(data: String, redirectUrl: String, publicKey: String) -> String {
        let baseURL = "https://appclip.apple.com/id?p=network.gandalf.connect.Clip"
        
        let base64Data = data.data(using: .utf8)?.base64EncodedString() ?? ""
        var urlComponents = URLComponents(string: baseURL)!
        
        var queryItems = urlComponents.queryItems ?? []
        queryItems.append(contentsOf: [
            URLQueryItem(name: "publicKey", value: publicKey),
            URLQueryItem(name: "redirectUrl", value: redirectUrl),
            URLQueryItem(name: "data", value: base64Data)
        ])
        urlComponents.queryItems = queryItems
        
        return urlComponents.url!.absoluteString
    }
    
    private func allValidations(publicKey: String, redirectURL: String, data: InputData) async throws {
        if !verificationComplete {
            try await Self.validatePublicKey(publicKey: publicKey)
            try Self.validateRedirectURL(url: redirectURL)
            let cleanServices = try await Self.validateInputData(input: data)
            self.data = cleanServices
            
            // Validate that at least one service has the required property set to true
            let hasRequiredService = cleanServices.values.contains { value in
                switch value {
                case .boolean(let isActive):
                    return isActive
                case .service(let serviceData):
                    return serviceData.required
                }
            }
            
            if !hasRequiredService {
                throw GandalfError(message: "At least one service must have the required property set to true", code: .InvalidService)
            }
        }
        verificationComplete = true
    }
    
    private static func validatePublicKey(publicKey: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            NetworkManager.shared.fetchAppByPublicKey(publicKey: publicKey) { result in
                switch result {
                case .success(let data):
                    if data.getAppByPublicKey.gandalfID.isEmpty {
                        continuation.resume(throwing: GandalfError(message: "Public key does not exist", code: .InvalidPublicKey))
                    } else {
                        continuation.resume()
                    }
                case .failure(let error):
                    if let gandalfError = error as? GandalfError {
                        continuation.resume(throwing: gandalfError)
                    } else {
                        continuation.resume(throwing: GandalfError(message: error.localizedDescription, code: .InvalidPublicKey))
                    }
                }
            }
        }
    }
    
    private static func validateInputData(input: InputData) async throws -> InputData {
        let supportedServicesAndTraits = try await getSupportedServicesAndTraits()
        var cleanServices: InputData = [:]
        var unsupportedServices: [String] = []
        
        let keys = input.keys.map { $0.lowercased() }
        
        if keys.count < 1 {
            throw GandalfError(
                message: "At least one service is needed.",
                code: .InvalidService
            )
        }
        
        for key in keys {
            guard supportedServicesAndTraits.services.contains(key) else {
                unsupportedServices.append(key)
                continue
            }
            
            if let service = input[key] {
                switch service {
                case .boolean(let isActive):
                    if !isActive {
                        throw GandalfError(
                            message: "At least one service has to be required",
                            code: .InvalidService
                        )
                    }
                    cleanServices[key] = service
                    
                case .service(let serviceData):
                    try validateInputService(input: serviceData, supportedServicesAndTraits: supportedServicesAndTraits)
                    cleanServices[key] = service
                }
            }
        }
        
        if !unsupportedServices.isEmpty {
            throw GandalfError(
                message: "These services [ \(unsupportedServices.joined(separator: ", ")) ] are unsupported",
                code: .InvalidService
            )
        }
        
        return cleanServices
    }
    
    private static func validateInputService(input: Service, supportedServicesAndTraits: SupportedServicesAndTraits) throws {
        if (input.activities?.count ?? 0) < 1 && (input.traits?.count ?? 0) < 1 {
            throw GandalfError(
                message: "At least one trait or activity is required",
                code: .InvalidService
            )
        }
        
        var unsupportedActivities: [String] = []
        var unsupportedTraits: [String] = []
        
        if let activities = input.activities {
            for key in activities {
                if !supportedServicesAndTraits.activities.contains(key.lowercased()) {
                    unsupportedActivities.append(key)
                }
            }
        }
        
        if let traits = input.traits {
            for key in traits {
                if !supportedServicesAndTraits.traits.contains(key.lowercased()) {
                    unsupportedTraits.append(key)
                }
            }
        }
        
        if !unsupportedActivities.isEmpty {
            throw GandalfError(
                message: "These activities [ \(unsupportedActivities.joined(separator: ", ")) ] are unsupported",
                code: .InvalidService
            )
        }
        
        if !unsupportedTraits.isEmpty {
            throw GandalfError(
                message: "These traits [ \(unsupportedTraits.joined(separator: ", ")) ] are unsupported",
                code: .InvalidService
            )
        }
    }
    
    private static func validateRedirectURL(url: String) throws {
        guard URL(string: url) != nil else {
            throw GandalfError(message: "Invalid redirectURL", code: .InvalidRedirectURL)
        }
    }
}
