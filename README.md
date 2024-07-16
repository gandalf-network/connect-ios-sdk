# connect-ios-sdk

`connect-ios-sdk` is a Swift library that makes it easier to generate valid [Connect](https://docs.gandalf.network/concepts/connect) URLs that lets your users to link their accounts to Gandalf.

## Features

- Generate valid Connect URLs
- Parameter validation

## Getting Started

This section provides a quick overview of how to integrate the library into your project.

### Prerequisites

- Swift >= v5.3
- Xcode >= 12.0
- Git

## Installation

### Using Swift Package Manager in Xcode

1. Open your project in Xcode.
2. Go to `File` > `Add Packages...`.
3. Enter the repository URL: `https://github.com/gandalf-network/connect-ios-sdk.git`.
4. Choose the version rule (e.g., "Up to Next Major") and click `Add Package`.
5. Select the GandalfConnect package for your target.

### Using Package.swift

To integrate GandalfConnect into your project, add it to your `Package.swift` file:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YourProjectName",
    dependencies: [
        .package(url: "https://github.com/gandalf-network/connect-ios-sdk.git", .upToNextMajor(from: "1.0.0"))
    ],
    targets: [
        .target(
            name: "YourTargetName",
            dependencies: ["GandalfConnect"]
        )
    ]
)
```

Then, run `swift package update` to fetch the dependency.

## Usage

### Importing the Library

In your Swift file where you want to use GandalfConnect, import the library:

```swift
import GandalfConnect
```

### Initialization

Create an instance of `ConnectInput` with the necessary details:

```swift
<!-- styling parameters to modify the Connect UI -->
let style = StylingOptions(
    primaryColor: "#7949D1", 
    backgroundColor: "#fff", 
    foregroundColor: "#562BA6", 
    accentColor: "#F4F0FB",
)
let options = ConnectOptions(style: style)

<!-- One service -->
let services: InputData = [
    "uber": .service(Service(traits: ["rating"], activities: ["trip"]))
]

<!-- Multiple services -->
let services: InputData = [
    "uber": .service(Service(traits: ["rating"], activities: ["trip"],  required: false)),
    "netflix": .service(Service(activities: ["watch"])),
]

<!-- Timeframe -->
let amazonTimeframe = Timeframe(endDate: "12/31/2023") // Date format: "MM/dd/yyyy"
let services: InputData = [
    "amazon": .service(Service(activities: ["shop"], timeframe: amazonTimeframe)),
]

let input = ConnectInput(
    publicKey: "yourPublicKey",
    redirectURL: "https://example.com",
    services: services,
    // Optional styling parameter to modify the Connect UI
    options: options
)
```

**Note:** The `timeframe` prop is currently only supported on the `amazon` service. It allows you to get amazon orders within a particular timeframe. The duration of the timeframe should not be more than two years from the current date

Initialize the `Connect` class:

```swift
let connect = Connect(input: input)
```

### Generating URL

To generate a URL, call the `generateURL` method:

```swift
do {
    let generatedURL = try await connect.generateURL()
    print("Generated URL: \(generatedURL)")
} catch {
    print("Error generating URL: \(error)")
}
```

### Validations

The `generateURL` method performs several validations:

- **Public Key Validation**: Ensures the public key is valid.
- **Redirect URL Validation**: Checks if the redirect URL is properly formatted.
- **Input Data Validation**: Verifies that the input data conforms to the expected structure and contains supported services and traits/activities.

### Getting Data Key from URL

To extract the data key from a URL:

```swift
do {
    let dataKey = try Connect.getDataKeyFromURL(redirectURL: "https://example.com?dataKey=testDataKey")
    print("Data Key: \(dataKey)")
} catch {
    print("Error extracting data key: \(error)")
}
```

### Error Handling

The library uses the `GandalfError` struct to represent errors, which includes a message and an error code (`GandalfErrorCode`).

Example of handling specific errors:

```swift
do {
    let generatedURL = try await connect.generateURL()
    print("Generated URL: \(generatedURL)")
} catch let error as GandalfError {
    switch error.code {
    case .InvalidPublicKey:
        print("Invalid Public Key: \(error.message)")
    case .InvalidRedirectURL:
        print("Invalid Redirect URL: \(error.message)")
    case .InvalidService:
        print("Invalid Service: \(error.message)")
    case .DataKeyNotFound:
        print("Data Key Not Found: \(error.message)")
    }
} catch {
    print("Unexpected error: \(error)")
}
```

## Contributing

We would love you to contribute to `connect-ios-sdk`, pull requests are welcome! Please see the [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## License

The scripts and documentation in this project are released under the [MIT License](LICENSE.md)
