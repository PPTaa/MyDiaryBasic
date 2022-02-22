//
//  StarCell.swift
//  MyDiaryBasic
//
//  Created by leejungchul on 2021/12/15.
//

import UIKit

class StarCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 3
        self.contentView.layer.borderWidth = 1
        self.contentView.layer.borderColor = UIColor.blue.cgColor
    }
}
