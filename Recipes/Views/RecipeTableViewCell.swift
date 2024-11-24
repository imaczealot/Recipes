//
//  RecipeTableViewCell.swift
//  Recipes
//
//  Created by Jeff Miller on 11/23/24.
//

import UIKit
import Kingfisher

class RecipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var secondaryTitle: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        title.text = nil
        secondaryTitle.text = nil
        recipeImage.image = UIImage(named: "Stringbutton_background_kickstarter_normal")
    }
    
    
    @MainActor
    func setRecipeData(_ recipe: Recipe) {
        title.text = recipe.name
        secondaryTitle.text = recipe.cuisine
        if let url = URL(string: recipe.photoURLSmall) {
            #if DEBUG
            // print location where the image is coming from
            let cache = ImageCache.default
            let cacheType = cache.imageCachedType(forKey: recipe.photoURLSmall)
            print("cacheType: \(cacheType)")
            #endif
            recipeImage.kf.setImage(
                with: url,
                placeholder: UIImage(named: "Stringbutton_background_kickstarter_normal"),
                options: [
                    .loadDiskFileSynchronously,
                    .cacheOriginalImage,
                    .transition(.fade(0.25))
                ],
                progressBlock: { receivedSize, totalSize in
                    print("Download Progress: \(receivedSize)/\(totalSize)")
                },
                completionHandler: { result in
                    print("Download Completed: \(result)")
                }
            )
        }
    }
    
}
