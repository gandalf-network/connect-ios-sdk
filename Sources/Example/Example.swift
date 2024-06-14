import Foundation
import GandalfConnectIOS

@main
struct Example {
    static func main() async {
        await testConnect()
    }
}

func testConnect() async {
    let services: InputData = [
        "uber": .service(Service(traits: ["rating"], activities: ["trip"])),
    ]
    let input = ConnectInput(
        publicKey: "",
        redirectURL: "",
        services: services
    )
    
    let connect = Connect(input: input)
    
    do {
        let generatedURL = try await connect.generateURL()
        print("Generated URL: \(generatedURL)")
    } catch let error as GandalfError {
        print("GandalfError: \(error.message) with code: \(error.code.rawValue)")
    } catch {
        print("Unexpected error: \(error)")
    }
}
