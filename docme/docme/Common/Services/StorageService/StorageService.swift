import Foundation
import SwiftData


protocol StorageService {
    associatedtype Entity: PersistentModel

    func fetchAll() async throws -> [Entity]
    func fetch(by id: UUID) async throws -> Entity?
    func insert(_ entity: Entity) async throws
    func delete(_ entity: Entity) async throws
    func update(_ entity: Entity) async throws
}

final class StorageServiceImpl<T: PersistentModel>: StorageService where T: UUIDModel {
    typealias Entity = T

    private(set) var context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchAll() async throws -> [T] {
        let descriptor = FetchDescriptor<T>()
        return try context.fetch(descriptor)
    }
    
    func fetch(by uuid: UUID) async throws -> T? {
        let descriptor = FetchDescriptor<T>(
            predicate: #Predicate { $0.uuid == uuid}
        )

        return try context.fetch(descriptor).first
    }
    
    func insert(_ entity: T) async throws {
        context.insert(entity)
        try context.save()
    }

    func delete(_ entity: T) async throws {
        context.delete(entity)
        try context.save()
    }

    func update(_ entity: T) async throws {
        try context.save()
    }
    
    func fetch(descriptor: FetchDescriptor<T>) async throws -> [T] {
        return try context.fetch(descriptor)
    }
    
    func fetchCount(descriptor: FetchDescriptor<T>) async throws -> Int {
        return try context.fetchCount(descriptor)
    }
}
