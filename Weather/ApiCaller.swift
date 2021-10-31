//
//  ApiCaller.swift
//  ReceipeBrowser
//
//  Created by Hari Bista on 10/6/21.
//  Copyright © 2021 Hari Bista. All rights reserved.
//

import UIKit

enum NetworkError: Error {
    case failure(Error)
    case unknown
}

protocol ApiCallerProcol: AnyObject {
    associatedtype ResponseType: Decodable
    var baseUrl: String { get set }
    var queryItems: [URLQueryItem] { get set }
    func callApi(endPoint: String, completion: @escaping (Result<ResponseType,NetworkError>) -> Void)
}

extension ApiCallerProcol {
    func callApi(endPoint: String,
                 completion: @escaping (Result<ResponseType,NetworkError>) -> Void) {
        guard let url = URL(string: self.baseUrl + endPoint) else {
            completion(Result.failure(.unknown))
            return
        }

        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = self.queryItems
        
        guard let apiUrl = urlComponents?.url else {
            completion(Result.failure(.unknown))
            return
        }

        print("Loading Data from: \(apiUrl.absoluteString)")
        let urlRequest = URLRequest(url: apiUrl)

        let task = URLSession.shared.dataTask(with: urlRequest) { (data, respose, error) in
            do {
                if let data = data, error == nil {
                    let returnObj = try JSONDecoder().decode(ResponseType.self, from: data)
                    completion(Result.success(returnObj))
                } else if let error = error {
                    completion(Result.failure(.failure(error)))
                }
            } catch let error {
                print(error.localizedDescription)
                completion(Result.failure(.failure(error)))
            }
        }
        task.resume()
    }
}

class DefaultApiCaller<T: Decodable> : ApiCallerProcol {
    var queryItems: [URLQueryItem] = []
    typealias ResponseType = T
    var baseUrl = "https://api.openweathermap.org"
    var appid = "d01b2c5449aaa2687f90bc71e092aaea"
}
