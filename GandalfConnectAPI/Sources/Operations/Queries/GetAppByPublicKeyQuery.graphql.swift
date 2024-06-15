// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetAppByPublicKeyQuery: GraphQLQuery {
  public static let operationName: String = "GetAppByPublicKey"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetAppByPublicKey($publicKey: String!) { getAppByPublicKey(publicKey: $publicKey) { __typename appName gandalfID } }"#
    ))

  public var publicKey: String

  public init(publicKey: String) {
    self.publicKey = publicKey
  }

  public var __variables: Variables? { ["publicKey": publicKey] }

  public struct Data: GandalfConnectAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GandalfConnectAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("getAppByPublicKey", GetAppByPublicKey.self, arguments: ["publicKey": .variable("publicKey")]),
    ] }

    /// Retrieves an application by its public key.
    ///
    /// Returns: An Application object that includes detailed information about the requested application.
    public var getAppByPublicKey: GetAppByPublicKey { __data["getAppByPublicKey"] }

    /// GetAppByPublicKey
    ///
    /// Parent Type: `Application`
    public struct GetAppByPublicKey: GandalfConnectAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GandalfConnectAPI.Objects.Application }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("appName", String.self),
        .field("gandalfID", GandalfConnectAPI.Int64.self),
      ] }

      /// The human-readable name of the application.
      public var appName: String { __data["appName"] }
      /// A unique identifier assigned to the application upon registration.
      public var gandalfID: GandalfConnectAPI.Int64 { __data["gandalfID"] }
    }
  }
}
