//
//  RMService.swift
//  RickAndMorty
//
//  Created by Mallikharjun kakarla on 25/12/22.
//

import Foundation

/// Primary API Service object to get Rick And Morty data
final class RMService {
    /// Shared singleton Instance
    static let shared = RMService()
    
    /// Privatized constructor
    private init() {}
    
    enum RMServiceError:Error {
        case failedToCreateRequest
        case failedToGetData
    }
    
    /// Send Rick and Morty API call
    /// - Parameters:
    ///   - request: Request Instance
    ///   - completion: callback with data or error
    ///   - type: type of object we expect to get back
    public func execute<T:Codable>(_ request:RMRequest, expecting type:T.Type,
                                   completion:@escaping(Result<T,Error>)->Void) {
        
        guard let urlRequest = self.request(from: request) else {
            completion(.failure(RMServiceError.failedToCreateRequest))
            return
        }
        
        print("API call :\(request.url?.absoluteURL)")
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error ?? RMServiceError.failedToGetData))
                return
            }
            //Decode Response
            do {
                let result = try JSONDecoder().decode(type, from: data)
                completion(.success(result))
            }
            catch {
                completion(.failure(error))
            }
        }
        task.resume()
        
    }
    
    //MARK: Private
    
    private func request(from rmRequest:RMRequest) -> URLRequest? {
        guard let url = rmRequest.url else {
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = rmRequest.httpMethod
        return request
    }
}
