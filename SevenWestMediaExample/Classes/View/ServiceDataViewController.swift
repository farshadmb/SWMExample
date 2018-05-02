//
//  ServiceDataViewController.swift
//  SevenWestMediaExample
//
//  Created by Farshad Mousalou on 5/2/18.
//  Copyright © 2018 Farshad Mousalou. All rights reserved.
//

import UIKit

private let cellId = "cellId"

class ServiceDataViewController: UITableViewController {
    
    var activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    var viewModal : ServerDataViewModel? = ServerDataViewModel() {
        didSet{
            bindViewModal()
        }
    }
    
    var disposal : Disposal = []
    
    deinit {
        disposal.removeAll()
    }
    
    private var refreshControll : UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            self.navigationItem.largeTitleDisplayMode = .automatic
             self.navigationController?.navigationBar.prefersLargeTitles = true
        }
       
        self.title = "Loading ..."
        
        setupTableView()
        setupLoadingView()
        
        
        if viewModal == nil {
            viewModal = .init()
        }
        
        bindViewModal()
        loadData()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    //MARK: - ViewModel Methods
    
    func bindViewModal(){
        
        guard let viewModal = viewModal else {
            return
        }
        
        viewModal.isLoading.observe({[unowned self] in self.handleLoadingView($0); _ = $1 }).add(to: &disposal)
        viewModal.title.observe({[unowned self] in self.title = $0; _ = $1 }).add(to: &disposal)
        viewModal.rows.observe({[unowned self] (_,_) in self.reloadData() }).add(to: &disposal)
        
    }
    
    /// <#Description#>
    func loadData() {
        
        viewModal?.loadData {[weak self] (result, error) in
            
            guard let s = self else { return }
            
            guard let error = error else {
                return
            }
            
            s.handleFetch(error:error) { retry in
                
                if retry {
                    s.loadData()
                }
                
            }
        }
    }
    
    /// <#Description#>
    func reloadData(){
        self.tableView.reloadData()
    }
    
    @objc
    func refreshData(_ sender : UIRefreshControl? = nil ){
        
        self.loadData()
        
    }
    
    //MARK: - Loading View Methods
    
    /// <#Description#>
    fileprivate func setupLoadingView() {
        
        self.view.addSubview(activityIndicatorView)
        
        self.view.bringSubview(toFront: activityIndicatorView)
        
        activityIndicatorView.hidesWhenStopped = true
        
        activityIndicatorView.alignToSuperviewAxis(.vertical).isActive = true
        activityIndicatorView.alignToSuperviewAxis(.horizontal).isActive = true
        activityIndicatorView.set(.width, to: 50.0)
        activityIndicatorView.set(.height, to: 50.0)
        
    }
    
    /// <#Description#>
    ///
    /// - Parameter isLoading: <#isLoading description#>
    func handleLoadingView(_ isLoading : Bool ) {
       
        guard viewModal?.rows.value.count == 0 else {
            
            refreshControll.endRefreshing()
            
            return
        }
        
        if isLoading {
            
            self.activityIndicatorView.startAnimating()
        }else {
            self.activityIndicatorView.stopAnimating()
        }
        
//        self.tableView.isHidden = isLoading
        
    }
    
    //MARK: - Error Handler
    
    /// <#Description#>
    ///
    /// - Parameters:
    ///   - error: <#error description#>
    ///   - completion: <#completion description#>
    func handleFetch(error:Error,completion:@escaping (Bool) -> () ){
        
        let alertView = UIAlertController(title: NSLocalizedString("Error", comment: ""),
                                         message: error.localizedDescription, preferredStyle: .alert)
        
        alertView.addAction(UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .cancel, handler: { (cancelAction) in
            completion(false)
        }))
        
        alertView.addAction(UIAlertAction(title: NSLocalizedString("retry ", comment: ""), style: .default, handler: { (retryAction) in
            completion(true)
        }))
        
        self.present(alertView, animated: true, completion: nil)
        
    }
    
    // MARK: - tableView
    private func setupTableView() {
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 85.0
        self.tableView.register(ServiceRowViewCell.self, forCellReuseIdentifier:cellId)
        
        refreshControll = UIRefreshControl()
        refreshControll.addTarget(self, action: #selector(refreshData(_:)), for: UIControlEvents.valueChanged)
        refreshControll.tintColor = UIColor.blue
        
        if #available(iOS 10, *){
            self.tableView.refreshControl = refreshControll
        }else{
            self.tableView.addSubview(refreshControll)
        }
        
        self.tableView.tableFooterView = UIView(frame:.zero)
    }
    
    // MARK: - TableViewController  Override Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModal?.rows.value.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:cellId, for: indexPath) as! ServiceRowViewCell
        
        guard let rowViewModel = viewModal?[at:indexPath.row] else {
            return cell
        }
        
        cell.config(viewModal:rowViewModel)
        
        cell.selectionStyle = .none
        
        return cell
        
    }
    
}
