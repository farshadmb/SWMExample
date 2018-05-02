//
//  ServerDataViewModel.swift
//  SevenWestMediaExample
//
//  Created by Farshad Mousalou on 5/1/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import Foundation

/// <#Description#>
class ServerDataViewModel {
    
    /// <#Description#>
    fileprivate(set) var data : ServerDataModel? {
        didSet{

            guard let data = data else {
                return
            }
            
            update(from: data)
        }
    }
    
    /// <#Description#>
    var title : Observable<String?>
    
    /// <#Description#>
    var rows : Observable<[ServerRowViewModel]>
    
    /// <#Description#>
    var isLoading : Observable<Bool> = Observable<Bool>(false)
    
    /// <#Description#>
    private var dataService = DataService()
    
    /// <#Description#>
    init(){
        self.title = Observable<String?>(nil)
        self.rows = Observable<[ServerRowViewModel]>([])
    }
    
    /// <#Description#>
    ///
    /// - Parameter model: <#model description#>
    convenience init(withData model : ServerDataModel ) {
        self.init()
        self.data = model
        update(from: model)
    }
    
    /// a Quick access to rows object at index
    ///
    /// - Parameter index: Integer value indicator of object index in rows
    subscript (at index : Int) -> ServerRowViewModel {
        return self.rows.value[index]
    }
    
    /// <#Description#>
    ///
    /// - Parameter index: <#index description#>
    subscript (safe index: Int) -> ServerRowViewModel? {
       
        guard self.rows.value.startIndex >= index && self.rows.value.endIndex <= index else {
            return nil
        }
        
        return self[at:index]
        
    }
    
    
    
    
    /// load and assing Data from Data Service Layer
    ///
    /// - Parameter completion: completion is a closure. call after finished wheter is successfull or have error
    func loadData(_ completion : @escaping (Bool,Error?) -> ()) {
        let url = URL(string:"https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json")!
        isLoading.value = true
        dataService.load(url: url, operationQueue: DispatchQueue.global(qos: .background)) {[unowned self] ( response ) in
            
            switch response.result {
            case .success(let data):
                
                do {
                    // try to decode from data to ServiceDataModel object
                    let decoder = JSONDecoder()
                    let data = try decoder.decode(ServerDataModel.self, from: data)
                    
                    // when decoding is successful we need to call completion on main-thread
                    // according to work with UI
                    DispatchQueue.main.async {[unowned self] in
                        
                        self.isLoading.value = false
                        completion(true,nil)
                        self.data = data
                        
                    }
                    
                }catch {
                    // catch any error on decoding process
                    DispatchQueue.main.async {
                        self.isLoading.value = false
                        completion(false,error)
                    }
                    
                }
                
            case .failure(let error):
                // fallback error to completion when error appeared
                DispatchQueue.main.async {
                    self.isLoading.value = false
                    completion(false, error)
                }
            }
            
        }
    }
    

    /// update variable from model
    ///
    /// - Parameter model: model is `ServerDataModel` object
    fileprivate func update(from model: ServerDataModel) {
        self.title.value = model.title
        
        // map and conver model.rows to array of `ServerRowViewModel`
        let rowsModel = model.rows.map({ ServerRowViewModel(withRow: $0)})
        self.rows.value = rowsModel
    }
    
    
    
}
