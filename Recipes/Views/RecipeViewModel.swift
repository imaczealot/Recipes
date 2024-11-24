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
}

protocol RecipeViewModelDelegate: ActivityViewType {
    
    func didUpdate(success: Bool, errorinfo: EmptyViewData?)
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
    

    fileprivate func processingResponse(_ data: Data, _ errorInfo: EmptyViewData) {
        let title = NSLocalizedString("Could not load recipes", comment: "Could not load recipes")
        let description = NSLocalizedString("Unable to read data from server", comment: "Unable to read data from server")
        let buttonText = NSLocalizedString("Try Again", comment: "Try Again")
        let errorInfo = EmptyViewData(title: title, description: description, buttonText: buttonText, action: { () in
            self.fetchRecipeData(true)})

        do {
            let recipeData:Recipes = try JSONDecoder().decode(Recipes.self, from: data)
            os_log(.info, log: self.log, "processingResponse: decode success")
            self.recipeList.append(contentsOf: recipeData.recipes)
            self.pendingFetch = false
            self.delegate?.didUpdate(success: true, errorinfo: nil)
        } catch {
            os_log(.error, log: self.log, "processingResponse: decode error: \(error.localizedDescription)")
            self.pendingFetch = false
            self.delegate?.didUpdate(success: false, errorinfo: errorInfo)
        }
    }
    
    func fetchRecipeData(_ refresh: Bool) {
        if pendingFetch == true {
            return
        }
        pendingFetch = true
        
        if !refresh {
            // Show progess spinner unless the refresh spinner is being displayed.
            delegate?.showActivityIndicator()
        }

        Task(priority: .userInitiated) {
            
            let urlString = "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
            guard let url = URL(string: urlString) else { return }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.allHTTPHeaderFields = [
                "Content-Type": "application/json"
            ]
            
            let title = NSLocalizedString("Could not load recipes", comment: "Could not load recipes")
            let buttonText = NSLocalizedString("Try Again", comment: "Try Again")
            let errorInfo = EmptyViewData(title: title, buttonText: buttonText, action: { () in
                self.fetchRecipeData(refresh)})
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse else {throw NetworkError.GeneralError}
                if httpResponse.statusCode == 200 {
                    // TODO: move to a processing data func
                    if refresh == true {
                        // When the tableview performs a refresh we want to clear out all data
                        // Clear existing data only if we get a response.
                        self.recipeList.removeAll()
                    }
                    processingResponse(data, errorInfo)
                } else {
                    // throw to outer catch block
                    throw NetworkError.GeneralError
                }
            } catch let error {
                os_log(.error, log: self.log, "fetchRecipeData: HTTP Request Failed \(error.localizedDescription)")
                self.delegate?.hideActivityIndicator()
                print("Error: fetchRecipeData: error: \(error)")
                self.pendingFetch = false
                self.delegate?.didUpdate(success: false, errorinfo: errorInfo)
                throw error
            }
        }
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        if pendingFetch == true {
            return 0
        } else {
            return recipeList.count
        }
    }
    
    func cellDataForRowAtIndexPath(_ indexPath: IndexPath) -> (Recipe?) {
        let row = indexPath.row
        if row < recipeList.count {
            return recipeList[row]
        }
        else {
            os_log(.error, log: self.log, "Error: cellDataForRowAtIndexPath index out of bounds: \(indexPath)")
            return nil
        }
    }

}

extension RecipeViewModel: EmptyViewDelegate {

    func emptyViewData() -> EmptyViewData? {
        let title = NSLocalizedString("No Recipes Available", comment: "No Recipes Found Title")
        let description = NSLocalizedString("An error has occurred retreiving recipes.", comment: "An error has occurred retreiving recipes.")
        var data = EmptyViewData()
        data.title = title
        data.description = description
        return data
    }

}
