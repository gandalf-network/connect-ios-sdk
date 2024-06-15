import Foundation
import Apollo
import GandalfConnectAPI

struct SupportedServicesAndTraits {
    var services: [String]
    var traits: [String]
    var activities: [String]
}

class NetworkManager {
    static let shared = NetworkManager()
    private(set) lazy var apollo = ApolloClient(url: URL(string: "https://sauron.gandalf.network/public/gql")!)
    
    func fetchSupportedServicesAndTraits(completion: @escaping (SupportedServicesAndTraits) -> Void) {
        apollo.fetch(query: GetSupportedServicesQuery()) { result in
            var res = SupportedServicesAndTraits(services: [], traits: [], activities: [])
            
            switch result {
            case .success(let graphQLResult):
                if let enumValues = graphQLResult.data?.__sourceType?.enumValues {
                    res.services = enumValues.compactMap { $0.name.lowercased() }
                }
                if let enumValues = graphQLResult.data?.__traitType?.enumValues {
                    res.traits = enumValues.compactMap { $0.name.lowercased() }
                }
                if let enumValues = graphQLResult.data?.__activityType?.enumValues {
                    res.activities = enumValues.compactMap { $0.name.lowercased() }
                }
                completion(res)
            case .failure(let error):
                print("Error fetching data: \(error)")
                completion(res)
            }
        }
    }
    
    func fetchAppByPublicKey(publicKey: String, completion: @escaping (Result<GetAppByPublicKeyQuery.Data, Error>) -> Void) {
        apollo.fetch(query: GetAppByPublicKeyQuery(publicKey: publicKey)) { result in
            switch result {
            case .success(let graphQLResult):
                if let data = graphQLResult.data {
                    completion(.success(data))
                } else if let errors = graphQLResult.errors {
                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: errors.map { $0.localizedDescription }.joined(separator: "\n")])
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
