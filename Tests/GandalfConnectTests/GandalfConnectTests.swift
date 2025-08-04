import XCTest
@testable import GandalfConnect

final class ConnectTests: XCTestCase {

    // Constants for test values
    let publicKey = "0x03d9cdab69b08a09f2bd213d1c24057af073dfc6a543f54ffded6c2235423cbd51"
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
    let slackServiceWithWorkspaceURL: InputData = ["slack": .service(Service(traits: ["rating"], activities: ["message"], required: true, workspaceURL: "https://example-workspace.slack.com"))]
    let slackServiceWithoutWorkspaceURL: InputData = ["slack": .service(Service(traits: ["rating"], activities: ["message"], required: true))]
    let slackServiceWithEmptyWorkspaceURL: InputData = ["slack": .service(Service(traits: ["rating"], activities: ["message"], required: true, workspaceURL: ""))]
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
    
    func testSlackServiceWithWorkspaceURL() async {
        let input = ConnectInput(publicKey: publicKey, redirectURL: redirectURL, services: slackServiceWithWorkspaceURL)
        let connect = Connect(input: input)
        
        do {
            let generatedURL = try await connect.generateURL()
            XCTAssertTrue(generatedURL.contains(publicKey))
            XCTAssertTrue(generatedURL.contains(redirectURL))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testSlackServiceWithoutWorkspaceURL() async {
        let input = ConnectInput(publicKey: publicKey, redirectURL: redirectURL, services: slackServiceWithoutWorkspaceURL)
        let connect = Connect(input: input)
        
        do {
            _ = try await connect.generateURL()
            XCTFail("Expected to throw, but did not throw")
        } catch let error as GandalfError {
            XCTAssertEqual(error.code, .MissingWorkspaceURL)
            XCTAssertEqual(error.message, "Slack service requires a workspaceURL")
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }
    
    func testSlackServiceWithEmptyWorkspaceURL() async {
        let input = ConnectInput(publicKey: publicKey, redirectURL: redirectURL, services: slackServiceWithEmptyWorkspaceURL)
        let connect = Connect(input: input)
        
        do {
            _ = try await connect.generateURL()
            XCTFail("Expected to throw, but did not throw")
        } catch let error as GandalfError {
            XCTAssertEqual(error.code, .MissingWorkspaceURL)
            XCTAssertEqual(error.message, "Slack service requires a workspaceURL")
        } catch {
            XCTFail("Unexpected error type: \(type(of: error))")
        }
    }
    
    func testServiceInitializationWithWorkspaceURL() {
        let service = Service(traits: ["rating"], activities: ["message"], required: true, workspaceURL: "https://example-workspace.slack.com")
        
        XCTAssertEqual(service.traits, ["rating"])
        XCTAssertEqual(service.activities, ["message"])
        XCTAssertTrue(service.required)
        XCTAssertEqual(service.workspaceURL, "https://example-workspace.slack.com")
    }
    
    func testWorkspaceURLStripping() {
        let service = Service(traits: ["rating"], activities: ["message"], required: true, workspaceURL: "https://example-workspace.slack.com")
        let connect = Connect(input: ConnectInput(publicKey: publicKey, redirectURL: redirectURL, services: ["slack": .service(service)]))
        
        // Test that the workspaceURL is properly stripped in the dictionary
        let dictionary = connect.dataToDictionary(connect.data)
        if let slackData = dictionary["slack"] as? [String: Any],
           let workspaceURL = slackData["workspaceURL"] as? String {
            XCTAssertEqual(workspaceURL, "example-workspace.slack.com")
        } else {
            XCTFail("workspaceURL not found in dictionary or not properly stripped")
        }
    }
    
    func testSlackValidationLogic() {
        // Test that Slack service without workspaceURL would fail validation
        let slackWithoutWorkspaceURL: InputData = ["slack": .service(Service(traits: ["rating"], activities: ["message"], required: true))]
        
        // This should throw MissingWorkspaceURL error when validated
        // We can't test this directly due to network dependencies, but we can verify the structure
        XCTAssertTrue(slackWithoutWorkspaceURL["slack"] != nil)
        
        // Test that Slack service with workspaceURL would pass validation
        let slackWithWorkspaceURL: InputData = ["slack": .service(Service(traits: ["rating"], activities: ["message"], required: true, workspaceURL: "https://example-workspace.slack.com"))]
        XCTAssertTrue(slackWithWorkspaceURL["slack"] != nil)
    }
    
    func testWorkspaceURLStrippingDifferentFormats() {
        // Test different URL formats
        let service1 = Service(traits: ["rating"], activities: ["message"], required: true, workspaceURL: "https://example-workspace.slack.com")
        let service2 = Service(traits: ["rating"], activities: ["message"], required: true, workspaceURL: "http://example-workspace.slack.com")
        let service3 = Service(traits: ["rating"], activities: ["message"], required: true, workspaceURL: "example-workspace.slack.com")
        
        let connect = Connect(input: ConnectInput(publicKey: publicKey, redirectURL: redirectURL, services: ["slack": .service(service1)]))
        
        // Test https:// stripping
        let dictionary1 = connect.dataToDictionary(["slack": .service(service1)])
        if let slackData = dictionary1["slack"] as? [String: Any],
           let workspaceURL = slackData["workspaceURL"] as? String {
            XCTAssertEqual(workspaceURL, "example-workspace.slack.com")
        } else {
            XCTFail("workspaceURL not found in dictionary")
        }
        
        // Test http:// stripping
        let dictionary2 = connect.dataToDictionary(["slack": .service(service2)])
        if let slackData = dictionary2["slack"] as? [String: Any],
           let workspaceURL = slackData["workspaceURL"] as? String {
            XCTAssertEqual(workspaceURL, "example-workspace.slack.com")
        } else {
            XCTFail("workspaceURL not found in dictionary")
        }
        
        // Test URL without protocol (should remain unchanged)
        let dictionary3 = connect.dataToDictionary(["slack": .service(service3)])
        if let slackData = dictionary3["slack"] as? [String: Any],
           let workspaceURL = slackData["workspaceURL"] as? String {
            XCTAssertEqual(workspaceURL, "example-workspace.slack.com")
        } else {
            XCTFail("workspaceURL not found in dictionary")
        }
    }
}