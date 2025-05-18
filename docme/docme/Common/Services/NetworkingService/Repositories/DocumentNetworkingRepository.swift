import Foundation

final class DocumentNetworkingRepository {
    private let networkingService: NetworkingService
    
    init(service: NetworkingService) {
        self.networkingService = service
    }
    
    func fetchAll() async throws -> [DocumentNetworking] {
        return [
            
        ]
    }
    
    func update(_ doc: DocumentNetworking) async throws {
        return
    }
    
    func create(_ doc: DocumentNetworking) async throws {
        return
    }
    
    func delete(uuid: UUID) async throws {
        return
    }
}
