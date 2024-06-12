import Foundation

enum GandalfErrorCode: String {
    case DataKeyNotFound
    case InvalidPublicKey
    case InvalidService
    case InvalidRedirectURL
}

struct GandalfError: Error {
    let message: String
    let code: GandalfErrorCode
}

struct ConnectInput {
    var publicKey: String
    var redirectURL: String
    var services: [String: Any]
}

class Connect {
    var publicKey: String
    var redirectURL: String
    var data: [String: Any]
    var verificationComplete: Bool = false
    
    init(input: ConnectInput) {
        self.publicKey = input.publicKey
        self.redirectURL = input.redirectURL.hasSuffix("/") ? String(input.redirectURL.dropLast()) : input.redirectURL
        self.data = input.services
    }
    
    func generateURL() async throws -> String {
        try await allValidations(publicKey: publicKey, redirectURL: redirectURL, data: data)
        let data = try JSONSerialization.data(withJSONObject: self.data)
        let dataString = String(data: data, encoding: .utf8) ?? ""
        let appClipURL = encodeComponents(data: dataString, redirectUrl: redirectURL, publicKey: publicKey)
        return appClipURL
    }
    
    static func getSupportedServices() async throws -> [String] {
//        @todo: replace with network call
//        let services = try await getSupportedServices()
        let services: [String] = ["uber", "netflix"]
        return services
    }
    
    static func getDataKeyFromURL(redirectURL: String) throws -> String {
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
        urlComponents.queryItems = [
            URLQueryItem(name: "publicKey", value: publicKey),
            URLQueryItem(name: "redirectUrl", value: redirectUrl),
            URLQueryItem(name: "data", value: base64Data)
        ]
        
        return urlComponents.url!.absoluteString
    }
    
    private func allValidations(publicKey: String, redirectURL: String, data: [String: Any]) async throws {
        if !verificationComplete {
            try await Self.validatePublicKey(publicKey: publicKey)
            try Self.validateRedirectURL(url: redirectURL)
            let cleanServices = try await Self.validateInputData(input: data)
            self.data = cleanServices
        }
        verificationComplete = true
    }
    
    private static func validatePublicKey(publicKey: String) async throws {
//        @todo: replace with network call
//        let isValidPublicKey = try await verifyPublicKey(publicKey: publicKey)
        let isValidPublicKey = publicKey == "abc"
        if !isValidPublicKey {
            throw GandalfError(message: "Public key does not exist", code: .InvalidPublicKey)
        }
    }
    
    private static func validateInputData(input: [String: Any]) async throws -> [String: Any] {
        let services = try await getSupportedServices()
        var cleanServices = [String: Any]()
        var unsupportedServices = [String]()

        let keys = Array(input.keys)

        if keys.count > 1 {
            throw GandalfError(message: "Only one service is supported per Connect URL", code: .InvalidService)
        }

        for key in keys {
            if !services.contains(key.lowercased()) {
                unsupportedServices.append(key)
                continue
            }
            
            if let service = input[key] as? Bool, service == false {
                throw GandalfError(message: "At least one service has to be required", code: .InvalidService)
            } else if let service = input[key] as? [String: Any] {
                try Self.validateInputService(input: service)
                cleanServices[key.lowercased()] = input[key]
            }
        }

        if !unsupportedServices.isEmpty {
            throw GandalfError(message: "These services \(unsupportedServices.joined(separator: " ")) are unsupported", code: .InvalidService)
        }

        return cleanServices
    }
    
    private static func validateInputService(input: [String: Any]) throws {
        let activities = input["activities"] as? [Any]
        let traits = input["traits"] as? [Any]
        
        if (activities?.isEmpty ?? true) && (traits?.isEmpty ?? true) {
            throw GandalfError(message: "At least one trait or activity is required", code: .InvalidService)
        }
    }
    
    private static func validateRedirectURL(url: String) throws {
        guard URL(string: url) != nil else {
            throw GandalfError(message: "Invalid redirectURL", code: .InvalidRedirectURL)
        }
    }
}
