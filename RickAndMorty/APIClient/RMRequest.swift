//
//  RMRequest.swift
//  RickAndMorty
//
//  Created by Mallikharjun kakarla on 25/12/22.
//

import Foundation

/// Object that represents a single API call
final class RMRequest {
    
    //Base url
     // https://rickandmortyapi.com/api/character/2
    //End point
    //path components
    //query parameters
    
    /// API constants
    private struct Constants {
        static let baseUrl = "https://rickandmortyapi.com/api"
    }
    
    /// Desired Endpoint
   private let endPoint:RMEndpoint
    
    /// pathcomponents for API,if any
    private let pathComponents:Set<String>
    
    /// query parameters for API, if any
   private let queryParameters:[URLQueryItem]
    
    /// Constructed url for the api request in string format
    private var urlString:String{
        var string = Constants.baseUrl
        string += "/"
        string += endPoint.rawValue
        
        if !pathComponents.isEmpty {
            pathComponents.forEach({
                string += "/\($0)"
            })
        }
        
        if !queryParameters.isEmpty{
            string += "?"
            let argumentString = queryParameters.compactMap({
                guard let value = $0.value else {return nil}
                return "\($0.name)=\(value)"
            }).joined(separator: "&")
            
            string += argumentString
        }
        
        return string
    }
    
    /// Computed and constructed API url
    public var url:URL?{
        return URL(string: urlString)
    }
    
    /// Desired httpMethod
    public let httpMethod = "GET"
    
    //MARK: public
    /// Construct Request
    /// - Parameters:
    ///   - endPoint: Target Endpoint
    ///   - pathComponents: collection of path components
    ///   - queryParameters: collection of query parameters
   public init(endPoint: RMEndpoint, pathComponents: Set<String> = [], queryParameters: [URLQueryItem] = [] ) {
        self.endPoint = endPoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
    
}
