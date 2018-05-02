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
    
    subscript (at index : Int) -> ServerRowViewModel {
        return self.rows.value[index]
    }
    
    subscript (safe index: Int) -> ServerRowViewModel? {
       
        guard self.rows.value.startIndex >= index && self.rows.value.endIndex <= index else {
            return nil
        }
        
        return self[at:index]
        
    }
    
    
    
    
    /// <#Description#>
    ///
    /// - Parameter completion: <#completion description#>
    func loadData(_ completion : @escaping (Bool,Error?) -> ()) {
        let url = URL(string:"https://dl.dropboxusercontent.com/s/2iodh4vg0eortkl/facts.json")!
        isLoading.value = true
        dataService.load(url: url, operationQueue: DispatchQueue.global(qos: .background)) {[unowned self] ( response ) in
            
            switch response.result {
            case .success(let data):
                
                do {
                 
                    let decoder = JSONDecoder()
                    let data = try decoder.decode(ServerDataModel.self, from: data)
                    
                    DispatchQueue.main.async {[unowned self] in
                    
                        self.isLoading.value = false
                        completion(true,nil)
                        self.data = data
                        
                    }
                    
                }catch {
                    
                    DispatchQueue.main.async {
                        self.isLoading.value = false
                        completion(false,error)
                    }
                    
                }
                
            case .failure(let error):
                
                DispatchQueue.main.async {
                    self.isLoading.value = false
                    completion(false, error)
                }
            }
            
        }
    }
    

    /// <#Description#>
    ///
    /// - Parameter model: <#model description#>
    fileprivate func update(from model: ServerDataModel) {
        self.title.value = model.title
        let rowsModel = model.rows.map({ ServerRowViewModel(withRow: $0)})
        self.rows.value = rowsModel
    }
    
    
    
}
