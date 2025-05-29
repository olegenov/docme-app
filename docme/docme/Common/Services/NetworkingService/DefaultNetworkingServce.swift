import Foundation


class DefaultNetworkingService: NetworkingService {
    enum Errors: Error {
        case invalidToken
    }
    
    private let urlSession: URLSession
    private let baseURL: URL
    
    init(urlSession: URLSession = .shared, baseURL: URL) {
        self.urlSession = urlSession
        self.baseURL = baseURL
    }
    
    func get<T: Decodable>(
        path: String,
        completion: @escaping (Result<T, Error>) async -> Void
    ) async {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        await performRequest(request, completion: completion)
    }
    
    func post<T: Codable, U: Decodable> (
        path: String,
        requestObject: T,
        completion: @escaping (Result<U, Error>) async -> Void
    ) async {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONEncoder().encode(requestObject)
        } catch {
            if let error = error as? URLError {
                AppLogger.shared.error(error.localizedDescription)
            }
            
            await completion(.failure(error))
        }
        
        await performRequest(request, completion: completion)
    }
    
    func postIgnoringToken<T: Codable, U: Decodable> (
        path: String,
        requestObject: T,
        completion: @escaping (Result<U, Error>) async -> Void
    ) async {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        do {
            request.httpBody = try JSONEncoder().encode(requestObject)
        } catch {
            if let error = error as? URLError {
                AppLogger.shared.error(error.localizedDescription)
            }
            
            await completion(.failure(error))
        }
        
        await performRequest(request, completion: completion, ignoreToken: true)
    }
    
    func delete<T: Codable, U: Decodable>(
        path: String,
        requestObject: T,
        completion: @escaping (Result<U, Error>) async -> Void
    ) async {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        
        await performRequest(request, completion: completion)
    }
    
    func put<T: Codable, U: Decodable>(
        path: String,
        requestObject: T,
        completion: @escaping (Result<U, Error>) async -> Void
    ) async {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(requestObject)
        } catch {
            if let error = error as? URLError {
                AppLogger.shared.error(error.localizedDescription)
            }
            
            await completion(.failure(error))
        }
        
        await performRequest(request, completion: completion)
    }
    
    func patch<T: Codable, U: Decodable>(
        path: String,
        requestObject: T,
        completion: @escaping (Result<U, Error>) async -> Void
    ) async {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        
        request.httpMethod = "PATCH"
        
        do {
            request.httpBody = try JSONEncoder().encode(requestObject)
        } catch {
            if let error = error as? URLError {
                AppLogger.shared.error(error.localizedDescription)
            }
            
            await completion(.failure(error))
        }
        
        await performRequest(request, completion: completion)
    }
    
    private func performRequest<T: Decodable>(
        _ request: URLRequest,
        completion: @escaping (Result<T, Error>) async -> Void,
        ignoreToken: Bool = false
    ) async {
        var requestToPerform = request
        
        if !ignoreToken {
            guard let token = TokenManager.shared.retrieve() else {
              await completion(.failure(Errors.invalidToken))
              return
            }
        
            requestToPerform.setValue(
              "Bearer \(token)",
              forHTTPHeaderField: "Authorization"
            )
        }
        
        do {
            let (data, _) = try await urlSession.dataTask(for: requestToPerform)
            let decodedData = try JSONDecoder().decode(T.self, from: data)
            
            await completion(.success(decodedData))
        } catch {
            if let error = error as? URLError {
                AppLogger.shared.error(error.localizedDescription)
            }
            await completion(.failure(error))
        }
    }
}

private extension URLSession {
    func dataTask(for urlRequest: URLRequest) async throws -> (Data, URLResponse) {
        try await withCheckedThrowingContinuation { continuation in
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let error = error as? NSError {
                    if error.code == NSURLErrorCancelled {
                        continuation.resume(throwing: CancellationError())
                    } else {
                        continuation.resume(throwing: error)
                    }
                } else if let data = data, let response = response {
                    continuation.resume(returning: (data, response))
                } else {
                    continuation.resume(throwing: URLError(.badServerResponse))
                }
            }
            
            task.resume()
            
            if Task.isCancelled {
                task.cancel()
            }
        }
    }
}
