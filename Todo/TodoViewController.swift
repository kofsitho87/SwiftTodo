import UIKit
import Cartography

class TodoViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addTodoTextField: UITextField!
    
    var todoGroup: TGroup! {
        didSet {
            navigationItem.title = todoGroup.title
            loadTodos()
        }
    }
    
    let service = ApiService.shared
    let cellId = "cellId"
    
    var todos = [Todo]() {
        didSet {
            self.unCTodos = self.todos.filter({ $0.completed == false })
            self.cTodos = self.todos.filter({ $0.completed == true })
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            print("change \(cTodos.count)")
        }
    }
    
    var unCTodos = [Todo]()
    var cTodos = [Todo]()
    
    let completeBarButtonItem: UIBarButtonItem = {
        let v = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(hideKeyboard))
        return v
    }()
    let editBarButtonItem: UIBarButtonItem = {
        let v = UIBarButtonItem(title: "편집하기", style: .done, target: self, action: nil)
        return v
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = editBarButtonItem
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        registerNotification()
    }
    
    func hideKeyboard(){
        view.endEditing(true)
    }
    
    func registerNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: .UIKeyboardWillShow, object: nil)
        
    }
    
    func handleKeyboard(notification: Notification){
        guard let userInfo = notification.userInfo else {return}
        guard let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue else { return }
        
        if notification.name == .UIKeyboardWillShow {
            
            navigationItem.rightBarButtonItem = completeBarButtonItem
            
        } else {
            
            navigationItem.rightBarButtonItem = editBarButtonItem
        }
    }
    
    func loadTodos(){
        
        service.getTodosFromGid(gid: todoGroup.id) { (success, todos) in
            if success {
                self.todos += todos!
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            //return todos.map({ $0.completed })
            return todos.filter({ $0.completed == false }).count
        }
        return todos.filter({ $0.completed == true }).count
        
        //return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TodoTableViewCell
        
        cell.checkBoxDelegate?.onChange = { [weak self] state in
            guard let strongSelf = self else {return}
            strongSelf.changeCompleteTodo(state: state, indexPath: indexPath)
        }
        
        if indexPath.section == 0 {
            let unCTodo = unCTodos[indexPath.row]
            cell.contentLabel.text = unCTodo.content
            
        }else {
            let cTodo = cTodos[indexPath.row]
            cell.contentLabel.text = cTodo.content
        }
        
        cell.checkBoxView.state = indexPath.section == 1
        
        return cell
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let text = textField.text else {return true}
        
        
        guard let gid = todoGroup.id else {return true}
        service.addTodo(gid: gid, content: text) { (success, todo) in
            if success {
                guard let t = todo else {return}
                self.addTodoTextField.text = nil
                self.todos.append(t)
                
//                DispatchQueue.main.async {
//                    self.tableView.beginUpdates()
//                    let unCompletedTodos = self.todos.filter({ $0.completed == false })
//                    let rowIndex = unCompletedTodos.count > 0 ? unCompletedTodos.count - 1 : 0
//                    
//                    let indexPath = IndexPath(row: rowIndex, section: 0)
//                    self.tableView.insertRows(at: [indexPath], with: .automatic)
//                    self.tableView.endUpdates()
//                }
            }
        }
        
        return true
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        //print(indexPath)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "삭제") { (action, indexPath) in

            let todo = indexPath.section == 0 ? self.unCTodos[indexPath.row] : self.cTodos[indexPath.row]
            
            self.service.deleteTodo(id: todo.id, completion: { (success) in
                if success {
                    guard let index = self.todos.index(of: todo) else {return}
                    
                    self.todos.remove(at: index)
//                    DispatchQueue.main.async {
//                        self.tableView.beginUpdates()
//                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
//                        self.tableView.endUpdates()
//                    }
                }
            })
        }
        
        return [deleteAction]
    }
    
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return section == 0 ? "" : "완료된 할일"
//    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil
        }
        
        if cTodos.count < 1 {
            return nil
        }
        
        let v = UIView()
        v.clipsToBounds = true
        
        let b = UIButton(type: .system)
        b.layer.cornerRadius = 6
        b.backgroundColor = .blue
        b.setTitleColor(UIColor.white, for: .normal)
        b.center = v.center
        b.setTitle("완료된 할일 숨기기", for: .normal)
        b.tag = 0
        b.addTarget(self, action: #selector(toggleShowCompletedTodos), for: .touchUpInside)
        
        v.addSubview(b)
        
        constrain(b) { (btn) in
            btn.center == btn.superview!.center
            btn.width == 140
            btn.height == 36
        }
        
        return v
    }
    
    var showCTodos = true
    func toggleShowCompletedTodos(_ button: UIButton){
        if button.tag == 0 {
            button.tag = 1
            //hide
            showCTodos = false
            button.setTitle("완료된 할일 보이기", for: .normal)
            
        }else {
            button.tag = 0
            //show
            showCTodos = true
            button.setTitle("완료된 할일 숨기기", for: .normal)
        }
        
        DispatchQueue.main.async {
            //self.tableView.reloadData()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        //let cTodos = todos.filter({$0.completed == true})
        //let height: CGFloat = section == 0 ? 0 : (cTodos.count > 0 ? 50 : 0)
        
        return section == 0 ? 0 : 50
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //default 60
        let defaultHeight: CGFloat = 60
        //return defaultHeight
        
        
        return indexPath.section == 0 ? defaultHeight : (showCTodos ? defaultHeight : 0)
    }
    
    
    func changeCompleteTodo(state: Bool, indexPath: IndexPath){
        let willState = !state
        
        let todo = indexPath.section == 0 ? unCTodos[indexPath.row] : cTodos[indexPath.row]
        
        let update: [String : Any] = ["completed" : willState]
        service.changeTodo(id: todo.id, update: update) { (success) in
            if success {
                todo.completed = willState
                if let index = self.todos.index(of: todo) {
                    self.todos[index] = todo
                }
            }
        }
    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        print(indexPath)
//        return true
//    }
    
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        return UITableViewCellEditingStyle.delete
//    }
}
