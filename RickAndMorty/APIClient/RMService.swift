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
    
    /// Send Rick and Morty API call
    /// - Parameters:
    ///   - request: Request Instance
    ///   - completion: callback with data or error
    ///   - type: type of object we expect to get back
    public func execute<T:Codable>(_ request:RMRequest, expecting type:T.Type,
                                   completion:@escaping(Result<T,Error>)->Void) {
        
    }
}
