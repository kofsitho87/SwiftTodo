//
//  CheckBox.swift
//  Todo
//
//  Created by 송희웅 on 2017. 10. 19..
//  Copyright © 2017년 송희웅. All rights reserved.
//

import UIKit
import Cartography


protocol CheckboxDelegate {
    
    func onChange()
}

class CheckBox: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    let buttonImageView: UIImageView = {
        let v = UIImageView()
        v.image = #imageLiteral(resourceName: "icon-checkbox-off")
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        return v
    }()
    
    var state = false {
        didSet {
            buttonImageView.image = state ? #imageLiteral(resourceName: "icon-checkbox-on") : #imageLiteral(resourceName: "icon-checkbox-off")
        }
    }
    
    var onChange : ((_ state: Bool) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(buttonImageView)
        
        constrain(buttonImageView) { (iv) in
            iv.left == iv.superview!.left
            iv.right == iv.superview!.right
            iv.top == iv.superview!.top
            iv.bottom == iv.superview!.bottom
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.isUserInteractionEnabled = true
        addGestureRecognizer(tapGesture)
    }
    
    func tapped(){
        //state = !state
        
        if onChange != nil {
            onChange!(state)
        }
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
