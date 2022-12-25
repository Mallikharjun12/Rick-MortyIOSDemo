//
//  RMEndpoint.swift
//  RickAndMorty
//
//  Created by Mallikharjun kakarla on 25/12/22.
//

import Foundation

/// Represents unique API Endpoint
@frozen enum RMEndpoint:String {
    /// Endpoint to get character info
    case character // "character"
    
    /// Endpoint to get location info
    case location
    
    /// Endpoint to get episode info
    case episode
    
}
