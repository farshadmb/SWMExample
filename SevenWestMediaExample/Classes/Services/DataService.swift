//
//  DataService.swift
//  SevenWestMediaExample
//
//  Created by Farshad Mousalou on 5/1/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import Foundation

/// <#Description#>
///
/// - success: <#success description#>
/// - failure: <#failure description#>
enum DataServiceResult<T> {
    case success(T)
    case failure(Error)
}

/// <#Description#>
struct DataServiceResponse<T> {
    
    /// <#Description#>
    var result : DataServiceResult<T>
    
    /// <#Description#>
    let response : URLResponse?
    
    /// <#Description#>
    let request : URLRequest
    
    /// <#Description#>
    let data : Data?
    
    
    /// <#Description#>
    var httpResponse : HTTPURLResponse? {
        return response as? HTTPURLResponse
    }
    
    /// <#Description#>
    var error : Error? {
        
        if case .failure(let error) = result {
            return error
        }
        
        return nil
    }
    
}

/// <#Description#>
class DataService {
    
    /// <#Description#>
    ///
    /// - dataIsNilOrEmpty: <#dataIsNilOrEmpty description#>
    enum DataServicError : Error {
        case dataIsNilOrEmpty
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - operationQueue: <#operationQueue description#>
    ///   - completion: <#completion description#>
    /// - Returns: <#return value description#>
    @discardableResult
    func load(url: URL,
                 operationQueue : DispatchQueue? =  nil,
                 _ completion :@escaping (DataServiceResponse<Data>)->()) -> URLSessionTask? {
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 60.0)
        return self.load(request: request, operationQueue: operationQueue, completion)
        
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - operationQueue: <#operationQueue description#>
    ///   - completion: <#completion description#>
    /// - Returns: <#return value description#>
    @discardableResult
    func load(request: URLRequest,
                 operationQueue : DispatchQueue? =  nil,
                 _ completion :@escaping  (DataServiceResponse<Data>)->()) -> URLSessionTask? {
        
        var dataTask : URLSessionDataTask? = nil
        
        dataTask = URLSession.shared.dataTask(with: request) {[weak dataTask,unowned self] (data, response, error) in
            
            
            var result : DataServiceResult<Data>
            
            if let error = error {
                result = .failure(error)
            }else if let data = data, data.isEmpty == false {
                
                
                /// <#Description#>
                ///
                /// - Parameters:
                ///   - data: <#data description#>
                ///   - response: <#response description#>
                /// - Returns: <#return value description#>
                func convertToUTF8(data: Data,response : URLResponse?) -> Data {
                    
                    var convertedData = data
                    
                    var convertedEncoding : String.Encoding? = nil
                    
                    if let encodingName = response?.textEncodingName as CFString!, convertedEncoding == nil {
                        convertedEncoding = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(
                            CFStringConvertIANACharSetNameToEncoding(encodingName))
                        )
                    }
                    
                    let actualEncoding = convertedEncoding ?? String.Encoding.isoLatin1
                    
                    let responseString = String(data: convertedData, encoding: actualEncoding)
                    
                    convertedData = responseString!.data(using: .utf8)!
                    return convertedData
                }
                
                
                let validData = convertToUTF8(data:data,response : response)
                
                result = .success(validData)
                
            }else {
                result = .failure(DataServicError.dataIsNilOrEmpty)
            }
            
            let dataResponse = DataServiceResponse(result:result,
                                             response: response,
                                             request: dataTask?.currentRequest ?? request,
                                             data: data)
            
            if  let operationQueue = operationQueue {
                
                operationQueue.async {
                    completion(dataResponse)
                }
                return
            }
            
            DispatchQueue.main.async {
                completion(dataResponse)
            }
            
            
        }
        
        dataTask?.resume()
        
        return dataTask
        
    }
    
    
}
