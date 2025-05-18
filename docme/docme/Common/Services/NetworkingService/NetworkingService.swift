import Foundation


protocol NetworkingService {
  func get<T: Response>(path: String, completion: @escaping (Result<T, Error>) -> Void) async
  func post<T: Request, U: Response>(path: String, requestObject: T, completion: @escaping (Result<U, Error>) -> Void) async
  func delete<T: Request, U: Response>(path: String, requestObject: T, completion: @escaping (Result<U, Error>) -> Void) async
  func put<T: Request, U: Response>(path: String, requestObject: T, completion: @escaping (Result<U, Error>) -> Void) async
  func patch<T: Request, U: Response>(path: String, requestObject: T, completion: @escaping (Result<U, Error>) -> Void) async
}
