//
//  TodoListTableViewCell.swift
//  Todo
//
//  Created by 송희웅 on 2017. 10. 18..
//  Copyright © 2017년 송희웅. All rights reserved.
//

import UIKit

class TodoListTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var todoCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
