import Foundation


protocol NetworkingService {
  func get<T: Decodable>(path: String, completion: @escaping (Result<T, Error>) async -> Void) async
  func post<T: Codable, U: Decodable>(path: String, requestObject: T, completion: @escaping (Result<U, Error>) async -> Void) async
  func delete<T: Codable, U: Decodable>(path: String, requestObject: T, completion: @escaping (Result<U, Error>) async -> Void) async
  func put<T: Codable, U: Decodable>(path: String, requestObject: T, completion: @escaping (Result<U, Error>) async -> Void) async
  func patch<T: Codable, U: Decodable>(path: String, requestObject: T, completion: @escaping (Result<U, Error>) async -> Void) async
}
