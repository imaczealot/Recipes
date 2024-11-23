//
//  RecipeTableViewCell.swift
//  Recipes
//
//  Created by Jeff Miller on 11/23/24.
//

import UIKit

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
//        backgroundColor = .white
    }
    
    
    func setRecipeData(_ recipe: Recipe) {
        title.text = recipe.name
        secondaryTitle.text = recipe.cuisine
        recipeImage.image = UIImage(named: recipe.name)
        DispatchQueue.global().async {
            if let url = URL(string: recipe.photoURLSmall),
               let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
//                    if let updateCell = tableView.cellForRow(at: indexPath) as? RecipeTableViewCell {
//                        updateCell.productImageView.image = image
//                    }
                    self.recipeImage.image = image
                }
            }
        }
    }
    
}
