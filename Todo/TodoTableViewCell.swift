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
    var todoDelegate: TodoViewController!
    
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
        
        
        importantButton.addTarget(self, action: #selector(changeImportantAction(_:)), for: .touchUpInside)
    }
    
    func changeImportantAction(_ button: UIButton){
        button.isEnabled = false
        let tag = button.tag
        //button.tag = tag == 0 ? 1 : 0

        todoDelegate.changeImportantTodo(state: tag == 1, cell: self)
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
