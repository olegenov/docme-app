import Foundation

final class DocumentNetworkingRepository {
    private let service: NetworkingService

    init(service: NetworkingService) {
        self.service = service
    }

    func fetchAll(completion: @escaping (Result<[DocumentNetworking], Error>) async -> Void) async {
        await service.get(path: "/documents", completion: completion)
    }

    func fetchChanges(completion: @escaping (Result<[DocumentNetworking], Error>) async -> Void) async {
        await service.get(path: "/documents/changes", completion: completion)
    }

    func create(document: DocumentNetworking, completion: @escaping (Result<DocumentNetworking, Error>) async -> Void) async {
        await service.post(path: "/documents", requestObject: document, completion: completion)
    }

    func update(document: DocumentNetworking, completion: @escaping (Result<DocumentNetworking, Error>) async -> Void) async {
        await service.patch(path: "/documents/\(document.uuid)", requestObject: document, completion: completion)
    }

    func delete(document: DocumentNetworking, completion: @escaping (Result<DocumentNetworking, Error>) async -> Void) async {
        await service.delete(path: "/documents/\(document.uuid)", requestObject: document, completion: completion)
    }
}
