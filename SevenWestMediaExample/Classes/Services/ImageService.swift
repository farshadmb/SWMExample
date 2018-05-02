//
//  ImageService.swift
//  SevenWestMediaExample
//
//  Created by Farshad Mousalou on 5/1/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import Foundation
import UIKit
import Security

/// <#Description#>
struct ImageServiceResponse<T> {
    
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

final class ImageProviderService {

    /// <#Description#>
    ///
    /// - badURL: <#badURL description#>
    /// - dataIsNilOrEmpty: <#dataIsNilOrEmpty description#>
    /// - notImageData: <#notImageData description#>
    enum ImageProviderServiceError : Error {
        case badURL
        case dataIsNilOrEmpty
        case notImageData
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - url: <#url description#>
    ///   - operationQueue: <#operationQueue description#>
    ///   - cache: <#cache description#>
    ///   - completion: <#completion description#>
    /// - Returns: <#return value description#>
    @discardableResult
    func load(url: URL, operationQueue: DispatchQueue? = nil,cache : Bool = true,_ completion: @escaping (ImageServiceResponse<UIImage>) -> ()) -> URLSessionTask? {
        let request = URLRequest(url: url)
        return self.load(request: request, operationQueue: operationQueue, cache: cache, completion)
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - request: <#request description#>
    ///   - operationQueue: <#operationQueue description#>
    ///   - cache: <#cache description#>
    ///   - completion: <#completion description#>
    /// - Returns: <#return value description#>
    @discardableResult
    func load(request: URLRequest, operationQueue: DispatchQueue? = nil, cache : Bool = true, _ completion: @escaping (ImageServiceResponse<UIImage>) -> ()) -> URLSessionTask? {
        
        var dataTask : URLSessionDataTask? = nil
        
        guard let url = request.url else {
            completion(.init(result: .failure(ImageProviderServiceError.badURL),
                             response: nil, request: request, data: nil))
            return nil
        }
        
        self.cacheImage(cacheImageName: self.cacheName(url: url)) { ( cacheResult ) in
            
            switch cacheResult {
                
            case .success(let image):
                
                completion(.init(result: .success(image),
                                 response: nil, request: request,
                                 data: nil))
                return
            default:
                break
            }
            
            dataTask = URLSession.shared.dataTask(with: request) {[weak dataTask] (data, response, error) in
                
                
                var result : DataServiceResult<UIImage>
                
                if let error = error {
                    result = .failure(error)
                }else if let data = data, data.isEmpty == false{
                    
                    if let image = UIImage(data: data, scale: UIScreen.main.scale) {
                        result = .success(image)
                        
                    }else{
                        result = .failure(ImageProviderServiceError.notImageData)
                        
                    }
                    
                }else{
                    result = .failure(ImageProviderServiceError.dataIsNilOrEmpty)
                }
                
                if case .success(_) = result, let data = data, cache {
                    
                    self.store(imageData: data, for: url, { ( storeResult ) in
                        
                    })
                }
                
                
                let dataResponse = ImageServiceResponse(result:result,
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
        }
         return dataTask
    }
    
}

/// Cache Helper
extension ImageProviderService {
    
    /// <#Description#>
    ///
    /// - success: <#success description#>
    /// - failure: <#failure description#>
    private enum ImageCacheResult <Value> {
        case success(Value)
        case failure(Error)
    }

    /// <#Description#>
    ///
    /// - notFoundCache: when image not found in cachePath
    /// - store: when error occured while store a image `Data` on disk
    /// - other: other occured error such as network
    enum ImageCacheError : Error {
        
        /// when image not found in cachePath
        case notFoundCache(name:String)
        
        /// when error occured while store a image `Data` on disk
        case store(failure : Error)
      
        ///other occured error such as network
        case other(Error)
    }
    
    /// <#Description#>
    ///
    /// - Parameter url: image `URL` object want to cache
    /// - Returns: unique cache Name for url parameter
    private func cacheName(url : URL) -> String {
        return url.absoluteString.data(using: .utf8)!.base64EncodedString()
    }
    
    /// Search image cache for entry url
    ///
    /// - Parameters:
    ///   - url: a url for searching cache
    ///   - completion: closure which contain `ImageCacheResult<UIImage>`, call when task is complete
    private func cacheImage(url : URL,completion : @escaping (ImageCacheResult<UIImage>) -> ()) {
        let cacheImageName = self.cacheName(url: url)
        self.cacheImage(cacheImageName: cacheImageName, completion: completion)
    }
    
    /// Search image cache for cacheImageName
    ///
    /// - Parameters:
    ///   - cacheImageName: a `String` value for searching cache
    ///   - completion: closure which contain `ImageCacheResult<UIImage>`, call when task is complete
    private func cacheImage(cacheImageName : String, completion : @escaping (ImageCacheResult<UIImage>) -> () ){
        
        let appCache = self.appCacheURL()
        
        DispatchQueue.global(qos: .utility).async {
            do {
                // get content of appCacheURL Directory
                let files = try FileManager.default.contentsOfDirectory(at: appCache,
                                                                    includingPropertiesForKeys: [.nameKey],
                                                                    options:[])
                // convert files array of `URL` to array of 'String'
                // then search array for cacheImageName
                // if have any result we passed the guard condition
                guard files.map({ $0.lastPathComponent }).contains(cacheImageName) else {
                    
                    // Otherwise called completion with failure contain ImageCacheError.notFoundCache with Named
                    DispatchQueue.main.async {
                        completion(.failure(ImageCacheError.notFoundCache(name: cacheImageName)))
                    }
                    
                    return
                }
                
                
                let imageURL = appCache.appendingPathComponent(cacheImageName)
                
                /// read image content to image object
                guard let cacheImage = UIImage(contentsOfFile:imageURL.path) else {
                    
                    // a data corrupted or is not image data
                    DispatchQueue.main.async {
                        completion(.failure(ImageCacheError.notFoundCache(name: cacheImageName)))
                    }
                    
                    return
                }
                
                
                DispatchQueue.main.async {
                    completion(.success(cacheImage))
                }
                
            }catch {
                
                DispatchQueue.main.async {
                    completion(.failure(ImageCacheError.other(error)))
                }
                
            }
        }
        
    }
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - imageData: <#imageData description#>
    ///   - url: <#url description#>
    ///   - completion: <#completion description#>
    private func store(imageData: Data ,for url: URL, _ completion : @escaping (ImageCacheResult<Bool>) -> ()) {
        
        let appCacheURL = self.appCacheURL()
        let imageName = self.cacheName(url: url)
        let imageNameURL = appCacheURL.appendingPathComponent(imageName)
        
        DispatchQueue.global(qos: .utility).async {
            
            do {
                
                try imageData.write(to: imageNameURL, options: [Data.WritingOptions.atomic])
                
                DispatchQueue.main.async {
                    completion(.success(true))
                }
                
                
            }catch {
                
                DispatchQueue.main.async {
                    completion(.failure(ImageCacheError.store(failure: error)))
                }
                
            }
            
        }
        
    }
    
    /// find and return `Caches` Director for application
    ///
    /// - Returns: a `URL` value contain Caches Directory
    private func appCacheURL () -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last!
    }
    
}



