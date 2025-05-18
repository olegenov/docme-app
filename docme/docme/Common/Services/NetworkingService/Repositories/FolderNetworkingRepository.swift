import Foundation


final class FolderNetworkingRepository {
    private let networkingService: NetworkingService
    
    init(service: NetworkingService) {
        self.networkingService = service
    }
    
    func fetchAll() async throws -> [FolderNetworking] {
        return [
            
        ]
    }
    
    func update(_ folder: FolderNetworking) async throws {
        return
    }
    
    func create(_ folder: FolderNetworking) async throws {
        return
    }
    
    func delete(uuid: UUID) async throws {
        return
    }
}
