import XCTest
@testable import GandalfConnectIOS

final class ConnectTests: XCTestCase {

    // Constants for test values
    let publicKey = "abc"
    let invalidPublicKey = "invalidPublicKey"
    let redirectURL = "https://example.com"
    let invalidRedirectURL = "invalid-url"
    let services: [String: Any] = ["uber": ["traits": ["rating"], "activities": ["trip"]]]
    let invalidServices: [String: Any] = ["facebook": ["traits": ["plan"], "activities": ["watch"]]]
    let noRequiredServices: [String: Any] = ["netflix": ["traits": [], "activities": []]]
    let multipleServices: [String: Any] = [
        "uber": ["traits": ["rating"], "activities": ["trip"]],
        "netflix": ["traits": ["plan"], "activities": ["watch"]],
        "instacart": ["activities": ["shop"]]
    ]

    func testInitialization() {
        let input = ConnectInput(publicKey: publicKey, redirectURL: redirectURL, services: services)
        let connect = Connect(input: input)
        
        XCTAssertEqual(connect.publicKey, publicKey)
        XCTAssertEqual(connect.redirectURL, "https://example.com")
        XCTAssertEqual(connect.data["uber"] as? [String: [String]], services["uber"] as? [String: [String]])
    }

    func testGenerateURL() async throws {
        let input = ConnectInput(publicKey: publicKey, redirectURL: redirectURL, services: services)
        let connect = Connect(input: input)
        
        let generatedURL = try await connect.generateURL()
        XCTAssertTrue(generatedURL.contains(publicKey))
        XCTAssertTrue(generatedURL.contains(redirectURL))
    }

    func testGenerateURLWithInvalidPublicKey() async {
        let input = ConnectInput(publicKey: invalidPublicKey, redirectURL: redirectURL, services: services)
        let connect = Connect(input: input)
        
        do {
            _ = try await connect.generateURL()
            XCTFail("Expected to throw, but did not throw")
        } catch let error as GandalfError {
            XCTAssertEqual(error.code, .InvalidPublicKey)
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }

    func testGenerateURLWithUnsupportedService() async {
        let input = ConnectInput(publicKey: publicKey, redirectURL: redirectURL, services: invalidServices)
        let connect = Connect(input: input)
        
        do {
            _ = try await connect.generateURL()
            XCTFail("Expected to throw, but did not throw")
        } catch let error as GandalfError {
            XCTAssertEqual(error.code, .InvalidService)
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }

    func testGenerateURLWithNoRequiredTraitOrActivity() async {
        let input = ConnectInput(publicKey: publicKey, redirectURL: redirectURL, services: noRequiredServices)
        let connect = Connect(input: input)
        
        do {
            _ = try await connect.generateURL()
            XCTFail("Expected to throw, but did not throw")
        } catch let error as GandalfError {
            XCTAssertEqual(error.code, .InvalidService)
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }

    func testGenerateURLWithMultipleServices() async {
        let input = ConnectInput(publicKey: publicKey, redirectURL: redirectURL, services: multipleServices)
        let connect = Connect(input: input)
        
        do {
            _ = try await connect.generateURL()
            XCTFail("Expected to throw, but did not throw")
        } catch let error as GandalfError {
            XCTAssertEqual(error.code, .InvalidService)
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }

    func testGetDataKeyFromURL() {
        let url = "https://example.com?dataKey=testDataKey"
        do {
            let dataKey = try Connect.getDataKeyFromURL(redirectURL: url)
            XCTAssertEqual(dataKey, "testDataKey")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testGetDataKeyFromURLWithoutDataKey() {
        let url = "https://example.com"
        do {
            _ = try Connect.getDataKeyFromURL(redirectURL: url)
            XCTFail("Expected to throw, but did not throw")
        } catch let error as GandalfError {
            XCTAssertEqual(error.code, .DataKeyNotFound)
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }
}
