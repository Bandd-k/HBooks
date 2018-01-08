//
//  BookTableViewCell.swift
//  HBooks
//
//  Created by Denis Karpenko on 05.01.2018.
//  Copyright © 2018 Denis Karpenko. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorsLabel: UILabel!
    @IBOutlet weak var annotationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        coverImage.layer.cornerRadius = 4
        coverImage.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        coverImage.image = nil
        titleLabel.text = ""
        authorsLabel.text = ""
        annotationLabel.text = ""
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
