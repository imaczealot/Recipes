//
//  RecipeViewModel.swift
//  Recipes
//
//  Created by Jeff Miller on 11/23/24.
//

import Foundation
import os

public enum NetworkError: Error {
    case GeneralError
    case NotSupported
    case networkFailure(Error)
}


class RecipeViewModel {
    
    var recipeList: [Recipe] = []
    weak var delegate: RecipeViewModelDelegate?
    var pendingFetch: Bool = false
    let log = OSLog(subsystem: "Recipe", category: "RecipeViewModel")

    // MARK: Initializers
    init(delegate: RecipeViewModelDelegate?) {
        self.delegate = delegate
    }

    func refreshRecipeData (_ refresh:Bool) {
        recipeList.removeAll()
        fetchRecipeData(refresh)
    }
    

    func fetchRecipeData(_ refresh:Bool) {
        if pendingFetch == true {
            return
        }
        pendingFetch = true
        
        // When the tableview performs a refresh we want to clear out all data
        if !refresh {
            // Show progess spinner unless the refresh spinner is being displayed.
            delegate?.showActivityIndicator()
        }

        Task(priority: .userInitiated) {
            
            let urlString = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
            guard let url = URL(string: urlString) else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.timeoutInterval = 2
            request.allHTTPHeaderFields = [
                "Content-Type": "application/json"
            ]
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {throw NetworkError.GeneralError}
                if httpResponse.statusCode == 200 {
                    // TODO: move to a processing data func
                    if refresh == true {
                        // Clear existing data only if we get a response.
                        self.recipeList.removeAll()
                    }

                    let recipeData:Recipes = try JSONDecoder().decode(Recipes.self, from: data)
                    print(recipeData)
                    //                    os_log(.info, log: self.log, "fetchRecipeData: decode success \(recipeData)")
                    os_log(.info, log: self.log, "fetchRecipeData: decode success")
                    self.recipeList.append(contentsOf: recipeData.recipes)
                    self.pendingFetch = false
                    self.delegate?.didUpdate(success: true)
                    
                } else {
                    throw NetworkError.GeneralError
                }
            } catch let error {
                os_log(.info, log: self.log, "fetchRecipeData: HTTP Request Failed \(error.localizedDescription)")
                self.delegate?.hideActivityIndicator()
                print("Error: getAlertsReceivedAPI: error: \(error)")
                self.pendingFetch = false
                self.delegate?.didUpdate(success: false)
                throw error
            }
        }
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        if pendingFetch == true {
            return 0
        } else {
            //TODO: handle error case where pendingFetch has completed but there is no data
            return recipeList.count
        }
    }
    
    func cellDataForRowAtIndexPath(_ indexPath: IndexPath) -> (Recipe?) {
        let row = indexPath.row
        if row < recipeList.count {
            return recipeList[row]
        }
        else {
            print("Error: AlertSentSummaryModel index out of bounds: \(indexPath)")
            return nil
        }
    }

}

extension RecipeViewModel: EmptyViewDelegate {

    func emptyViewData() -> EmptyViewData? {
        let title = NSLocalizedString("No Recipes Available", comment: "No Recipes Found Title")
        let description = NSLocalizedString("An error has occurred retreiving recipes.", comment: "An error has occurred retreiving recipes.")
        let data = EmptyViewData()
        data.title = title
        data.description = description
        return data
    }

}
