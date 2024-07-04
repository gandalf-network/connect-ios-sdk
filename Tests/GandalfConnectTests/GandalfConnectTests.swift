import XCTest
@testable import GandalfConnect

final class ConnectTests: XCTestCase {

    // Constants for test values
    let publicKey = "0x02073d3b9daf439c19a267dcfc19bc1ac1aea5066d8c754554b046476099b6fa22"
    let invalidPublicKey = "invalidPublicKey"
    let redirectURL = "https://example.com"
    let invalidRedirectURL = "invalid-url"
    
    // Define services in terms of InputData
    let services: InputData = ["uber": .service(Service(traits: ["rating"], activities: ["trip"], required: true))]
    let invalidServices: InputData = ["facebook": .service(Service(traits: ["plan"], activities: ["watch"], required: true))]
    let noRequiredServices: InputData = ["netflix": .service(Service(traits: [], activities: [], required: false))]
    let multipleServices: InputData = [
        "uber": .service(Service(traits: ["rating"], activities: ["trip"], required: true)),
        "netflix": .service(Service(traits: ["plan"], activities: ["watch"], required: false)),
        "instacart": .service(Service(traits: [], activities: ["shop"], required: false))
    ]
    let styling = StylingOptions(primaryColor: "#7949D1", backgroundColor: "#fff000", foregroundColor: "#562BA6", accentColor: "#F4F0FB")

    func testInitialization() {
        let input = ConnectInput(publicKey: publicKey, redirectURL: redirectURL, services: services)
        let connect = Connect(input: input)
        
        XCTAssertEqual(connect.publicKey, publicKey)
        XCTAssertEqual(connect.redirectURL, "https://example.com")
        if case .service(let service) = connect.data["uber"], let expectedService = services["uber"], case .service(let expectedServiceData) = expectedService {
            XCTAssertEqual(service.traits, expectedServiceData.traits)
            XCTAssertEqual(service.activities, expectedServiceData.activities)
        } else {
            XCTFail("Service data does not match expected values.")
        }
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

    func testGenerateURLWithNoRequiredService() async {
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
            let generatedURL = try await connect.generateURL()
            XCTAssertTrue(generatedURL.contains(publicKey))
            XCTAssertTrue(generatedURL.contains(redirectURL))
        } catch let error as GandalfError {
            XCTAssertEqual(error.code, .InvalidService)
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }

    func testGenerateURLWithStylingOptions() async {
        let connectOptions = ConnectOptions(style: styling)
        let input = ConnectInput(publicKey: publicKey, redirectURL: redirectURL, services: multipleServices, options: connectOptions)
        let connect = Connect(input: input)
        
        do {
            let generatedURL = try await connect.generateURL()
            XCTAssertTrue(generatedURL.contains(publicKey))
            XCTAssertTrue(generatedURL.contains(redirectURL))
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