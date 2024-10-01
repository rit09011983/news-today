//
//  CustomBookmarksTableViewCell.swift
//  NewsToday
//
//  Created by iRitesh on 28/09/24.
//

import UIKit

class CustomBookmarksTableViewCell: UITableViewCell {

    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        imgView.layer.cornerRadius = 20
        imgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
