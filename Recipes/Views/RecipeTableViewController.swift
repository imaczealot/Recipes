//
//  RecipeTableViewController.swift
//  Recipes
//
//  Created by Jeff Miller on 11/23/24.
//

import UIKit
import DZNEmptyDataSet
import os


protocol RecipeViewModelDelegate: ActivityViewType {
    
    func didUpdate(success: Bool)
}

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
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecipeTableViewCell")

    }
    
    @objc func refresh(_ sender: AnyObject)  {
        self.recipeViewModel?.refreshRecipeData(true)
    }
    
    func handleRefresh(_ sender: AnyObject?) {
        self.recipeViewModel?.refreshRecipeData(false)
    }
    
    // MARK: RecipeViewModelDelegate
    func didUpdate(success: Bool) {
        os_log(.info, log: self.log, "didUpdate: ")
        self.hideActivityIndicator()
        if success {
            Task { @MainActor in
                tableView.reloadData()
                if let refreshControl = self.refreshControl, refreshControl.isRefreshing {
                    refreshControl.endRefreshing()
                }
            }
        } else {
            // show alert
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
            print("ERROR: RecipeTableViewController recipeViewModel invalid")
            return UITableViewCell()
        }
        
        if let data = recipeViewModel.cellDataForRowAtIndexPath(indexPath) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecipeTableViewCell", for: indexPath)
            var config = cell.defaultContentConfiguration()
            config.text = data.name
            config.textProperties.font = UIFont.systemFont(ofSize: 14)
            config.secondaryText = data.cuisine
            config.secondaryTextProperties.font = UIFont.systemFont(ofSize: 12)
            cell.contentConfiguration = config
            return cell
            
        } else {
            return UITableViewCell()
        }
    }
}

