//
//  TodoTableViewCell.swift
//  Todo
//
//  Created by 송희웅 on 2017. 10. 19..
//  Copyright © 2017년 송희웅. All rights reserved.
//

import UIKit
import Cartography

class TodoTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var importantButton: UIButton!
    @IBOutlet weak var contentLabelLeftAnchor: NSLayoutConstraint!
    
    var checkBoxDelegate: CheckBox? = nil
    
    lazy var  checkBoxView: CheckBox = {
        let v = CheckBox()
        self.checkBoxDelegate = v
        return v
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 0.7
        
        addCheckBox()
    }
    
    func addCheckBox(){
        
        addSubview(checkBoxView)
        
        constrain(checkBoxView) { (v1) in
            v1.width == 30
            v1.height == 30
            v1.left == v1.superview!.left + 15
            v1.centerY == v1.superview!.centerY
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
