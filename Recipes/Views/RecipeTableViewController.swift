//
//  RecipeTableViewController.swift
//  Recipes
//
//  Created by Jeff Miller on 11/23/24.
//

import UIKit
import DZNEmptyDataSet
import os



class RecipeTableViewController: UITableViewController, RecipeViewModelDelegate {
    

    // MARK: Properties
    var recipeViewModel: RecipeViewModel?
    let log = OSLog(subsystem: "Recipe", category: "RecipeTableViewController")
    var isShowingActivityView: Bool = false
    var emptyViewDataSet = EmptyViewDataSet()

    override func viewDidLoad() {
        super.viewDidLoad()
        recipeViewModel = RecipeViewModel(delegate: self)

        self.recipeViewModel?.fetchRecipeData(true)
        self.configureTableView()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = .white
        self.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)

    }

    func configureTableView() {
        emptyViewDataSet.delegate = recipeViewModel
        tableView.emptyDataSetSource = emptyViewDataSet
        tableView.emptyDataSetDelegate = emptyViewDataSet
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.register(UINib(nibName: "RecipeTableViewCell" , bundle: nil), forCellReuseIdentifier: "RecipeTableViewCell")

    }
    
    @objc func refresh(_ sender: AnyObject)  {
        self.recipeViewModel?.refreshRecipeData(true)
    }
    
    
    // MARK: RecipeViewModelDelegate
    func didUpdate(success: Bool, errorinfo: EmptyViewData?) {
        os_log(.debug, log: self.log, "didUpdate: ")
        Task { @MainActor in
            self.hideActivityIndicator()
            if !success, let errorinfo = errorinfo {
                emptyViewDataSet.errorData = errorinfo
            }
            tableView.reloadData()
            if let refreshControl = self.refreshControl, refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }

    // MARK: - Table view data source
      
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let recipeViewModel = self.recipeViewModel else {
            return 0
        }
        return recipeViewModel.numberOfRowsInSection(section)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        guard let recipeViewModel = self.recipeViewModel else {
            os_log(.error, log: self.log, "ERROR: RecipeTableViewController recipeViewModel invalid")
            return UITableViewCell()
        }
        var recipeTableViewCell = RecipeTableViewCell()

        if let data = recipeViewModel.cellDataForRowAtIndexPath(indexPath) {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell", for: indexPath) as? RecipeTableViewCell {
                recipeTableViewCell = cell
                recipeTableViewCell.setRecipeData(data)
            }
            return recipeTableViewCell
            
        } else {
            return UITableViewCell()
        }
    }
}

