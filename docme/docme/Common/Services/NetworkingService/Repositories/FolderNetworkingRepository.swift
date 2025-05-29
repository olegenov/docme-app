import Foundation


final class FolderNetworkingRepository {
    private let service: NetworkingService

    init(service: NetworkingService) {
        self.service = service
    }

    func fetchChanges(completion: @escaping (Result<[FolderNetworking], Error>) -> Void) async {
        await service.get(path: "/folders/changes", completion: completion)
    }

    func create(folder: FolderNetworking, completion: @escaping (Result<FolderNetworking, Error>) -> Void) async {
        await service.post(path: "/folders", requestObject: folder, completion: completion)
    }

    func update(folder: FolderNetworking, completion: @escaping (Result<FolderNetworking, Error>) -> Void) async {
        await service.patch(path: "/folders/\(folder.uuid)", requestObject: folder, completion: completion)
    }

    func delete(folder: FolderNetworking, completion: @escaping (Result<FolderNetworking, Error>) -> Void) async {
        await service.delete(path: "/folders/\(folder.uuid)", requestObject: folder, completion: completion)
    }
}
