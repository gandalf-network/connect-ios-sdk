// @generated
// This file was automatically generated and should not be edited.

@_exported import ApolloAPI

public class GetSupportedServicesQuery: GraphQLQuery {
  public static let operationName: String = "GetSupportedServices"
  public static let operationDocument: ApolloAPI.OperationDocument = .init(
    definition: .init(
      #"query GetSupportedServices { __sourceType: __type(name: "Source") { __typename name enumValues(includeDeprecated: false) { __typename name } } __traitType: __type(name: "TraitLabel") { __typename name enumValues(includeDeprecated: false) { __typename name } } __activityType: __type(name: "ActivityType") { __typename name enumValues(includeDeprecated: false) { __typename name } } }"#
    ))

  public init() {}

  public struct Data: GandalfConnectAPI.SelectionSet {
    public let __data: DataDict
    public init(_dataDict: DataDict) { __data = _dataDict }

    public static var __parentType: ApolloAPI.ParentType { GandalfConnectAPI.Objects.Query }
    public static var __selections: [ApolloAPI.Selection] { [
      .field("__type", alias: "__sourceType", __SourceType?.self, arguments: ["name": "Source"]),
      .field("__type", alias: "__traitType", __TraitType?.self, arguments: ["name": "TraitLabel"]),
      .field("__type", alias: "__activityType", __ActivityType?.self, arguments: ["name": "ActivityType"]),
    ] }

    public var __sourceType: __SourceType? { __data["__sourceType"] }
    public var __traitType: __TraitType? { __data["__traitType"] }
    public var __activityType: __ActivityType? { __data["__activityType"] }

    /// __SourceType
    ///
    /// Parent Type: `__Type`
    public struct __SourceType: GandalfConnectAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GandalfConnectAPI.Objects.__Type }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("name", String?.self),
        .field("enumValues", [EnumValue]?.self, arguments: ["includeDeprecated": false]),
      ] }

      public var name: String? { __data["name"] }
      public var enumValues: [EnumValue]? { __data["enumValues"] }

      /// __SourceType.EnumValue
      ///
      /// Parent Type: `__EnumValue`
      public struct EnumValue: GandalfConnectAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GandalfConnectAPI.Objects.__EnumValue }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ] }

        public var name: String { __data["name"] }
      }
    }

    /// __TraitType
    ///
    /// Parent Type: `__Type`
    public struct __TraitType: GandalfConnectAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GandalfConnectAPI.Objects.__Type }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("name", String?.self),
        .field("enumValues", [EnumValue]?.self, arguments: ["includeDeprecated": false]),
      ] }

      public var name: String? { __data["name"] }
      public var enumValues: [EnumValue]? { __data["enumValues"] }

      /// __TraitType.EnumValue
      ///
      /// Parent Type: `__EnumValue`
      public struct EnumValue: GandalfConnectAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GandalfConnectAPI.Objects.__EnumValue }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ] }

        public var name: String { __data["name"] }
      }
    }

    /// __ActivityType
    ///
    /// Parent Type: `__Type`
    public struct __ActivityType: GandalfConnectAPI.SelectionSet {
      public let __data: DataDict
      public init(_dataDict: DataDict) { __data = _dataDict }

      public static var __parentType: ApolloAPI.ParentType { GandalfConnectAPI.Objects.__Type }
      public static var __selections: [ApolloAPI.Selection] { [
        .field("__typename", String.self),
        .field("name", String?.self),
        .field("enumValues", [EnumValue]?.self, arguments: ["includeDeprecated": false]),
      ] }

      public var name: String? { __data["name"] }
      public var enumValues: [EnumValue]? { __data["enumValues"] }

      /// __ActivityType.EnumValue
      ///
      /// Parent Type: `__EnumValue`
      public struct EnumValue: GandalfConnectAPI.SelectionSet {
        public let __data: DataDict
        public init(_dataDict: DataDict) { __data = _dataDict }

        public static var __parentType: ApolloAPI.ParentType { GandalfConnectAPI.Objects.__EnumValue }
        public static var __selections: [ApolloAPI.Selection] { [
          .field("__typename", String.self),
          .field("name", String.self),
        ] }

        public var name: String { __data["name"] }
      }
    }
  }
}
