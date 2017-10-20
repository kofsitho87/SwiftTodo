//
//  CreateGroupViewController.swift
//  Todo
//
//  Created by 송희웅 on 2017. 10. 20..
//  Copyright © 2017년 송희웅. All rights reserved.
//

import UIKit

class CreateGroupViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!

    let rightBarItem: UIBarButtonItem = {
        let i = UIBarButtonItem(title: "만들기", style: .done, target: self, action: #selector(createGroup))
        i.isEnabled = false
        return i
    }()
    
    let apiService = ApiService.shared
    
    var delegate: MainViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "그룹생성하기"
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        navigationItem.rightBarButtonItem = rightBarItem
        
        
        textField.addTarget(self, action: #selector(changeTextAction), for: .editingChanged)
    }
    
    func hideKeyboard(){
        view.endEditing(true)
    }
    
    func createGroup(){
        guard let title = textField.text else {return}
        
        apiService.createGroup(title: title) { (success, id) in
            if success {
                guard let id = id else {
                    self.showAlert("실패")
                    return
                }
                self.delegate.createTodoGroup(id: id, title)
                
                self.textField.text = nil
                self.showAlert("성공")
            }else{
                self.showAlert("실패")
            }
        }
    }
    
    func showAlert(_ title: String){
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: nil)
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    
    func changeTextAction(_ textField: UITextField){

        rightBarItem.isEnabled = (textField.text?.characters.count)! > 0
    }
    
}
