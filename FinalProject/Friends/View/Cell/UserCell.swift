//
//  TableViewCell.swift
//  vkAPI
//
//  Created by sergey on 24.02.2018.
//  Copyright © 2018 sergey. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var userName: UILabel!
    var onReuse: ()->Void = {}
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
    }
    
    func updateCellImage(_ image: UIImage?) {
        img.image = image
        img.roundImage()
    }
    
    func updateCellText(_ text: String?) {
        userName.text = text
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
