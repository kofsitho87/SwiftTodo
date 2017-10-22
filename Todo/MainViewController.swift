
import UIKit
import Cartography


enum StateTodoGroup {
    case add
    case delete
    
    case update
}

protocol TodoDelegate {
    
    func createTodoGroup(id: Int, _ title: String)
    
    func updateTodoGroupCount(tgroup: TGroup, state: StateTodoGroup)
}

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, TodoDelegate {

    @IBOutlet weak var allTodosView: UIView!
    @IBOutlet weak var starTodosView: UIView!
    @IBOutlet var addGroupView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var allTodoCountLabel: UILabel!
    @IBOutlet weak var startCountLabel: UILabel!
    
    let cellId = "cellId"
    var todoGroups = [TGroup]()
    
    
    let apiService = ApiService.shared
    
    let profileImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.layer.cornerRadius = 20
        v.image = #imageLiteral(resourceName: "cat-profile")
        return v
    }()
    
    let userNameLabel: UILabel = {
        let v = UILabel()
        v.font = UIFont.systemFont(ofSize: 15)
        v.text = "SongHeeWung"
        return v
    }()
    
    lazy var refrshCtrl: UIRefreshControl = {
        let c = UIRefreshControl()
        c.attributedTitle = NSAttributedString(string: "당겨서 새로고침")
        c.addTarget(self, action: #selector(self.refreshAction), for: UIControlEvents.valueChanged)
        return c
    }()
    
    var isRequsting = false
    var effect: UIVisualEffect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTitleView()
        setupView()
        
        let searchBarItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(loadTodos))
        let addBarItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(moveAddGroup))
        navigationItem.rightBarButtonItems = [searchBarItem, addBarItem]
        
        tableView.refreshControl = refrshCtrl
        
        
        loadTodos()
    }
    
    func setupView(){
        allTodosView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(moveToTodo))
        allTodosView.addGestureRecognizer(tapGesture)
    }
    
    func moveToTodo(){
        //let currentTG = todoGroups[indexPath.row]
        let vc = UIStoryboard(name: "Todo", bundle: nil).instantiateInitialViewController() as! TodoViewController
        
        //vc.todoGroup = currentTG
        //vc.delegate = self
        
        //navigationController?.pushViewController(vc, animated: true)
    }
    
    func moveAddGroup(){
        let vc = UIStoryboard(name: "CreateGroup", bundle: nil).instantiateInitialViewController() as! CreateGroupViewController
        
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func animateIn(){
        //view.bringSubview(toFront: visualEffectView)
        view.addSubview(addGroupView)
        
        addGroupView.center = view.center
        addGroupView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        addGroupView.alpha = 0
        
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { 
            //self.visualEffectView.effect = self.effect
            self.addGroupView.alpha = 1
            self.addGroupView.transform = CGAffineTransform.identity
        }, completion: nil)
    }

    func refreshAction(_ ctrl: UIRefreshControl){
        ctrl.beginRefreshing()
        loadTodos()
    }
    
    func loadTodos(){
        guard !isRequsting else {
            self.refrshCtrl.endRefreshing()
            return
        }
        
        print("connecting")
        isRequsting = true
        apiService.getGroups { (success, groups, data) in
            if success, let g = groups, let data = data {
                self.todoGroups = g
                DispatchQueue.main.async {
                    self.allTodoCountLabel.text = "\(String(describing: data["totalTodos"]!))"
                    self.startCountLabel.text = "\(String(describing: data["importantTodos"]!))"
                    self.tableView.reloadData()
                }
            }
            print("finishing")
            self.isRequsting = false
            self.refrshCtrl.endRefreshing()
        }
    }

    func setTitleView(){
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 200, height: 42)
        //titleView.backgroundColor = .red
        
        titleView.addSubview(profileImageView)
        titleView.addSubview(userNameLabel)
        //navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleView)
        
        constrain(titleView, profileImageView, userNameLabel) { (tv, iv, name) in
            iv.left == tv.left
            iv.centerY == tv.centerY
            iv.width == 40
            iv.height == 40
            
            name.left == iv.right + 5
            name.right == tv.right
            name.centerY == tv.centerY
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoGroups.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TodoListTableViewCell
        
        let currentTG = todoGroups[indexPath.row]
        
        cell.titleLabel.text = currentTG.title
        cell.todoCountLabel.text = "\(currentTG.count!)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currentTG = todoGroups[indexPath.row]
        let vc = UIStoryboard(name: "Todo", bundle: nil).instantiateInitialViewController() as! TodoViewController
        
        vc.todoGroup = currentTG
        vc.delegate = self
        
        navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func createTodoGroupAction(_ button: UIButton){
        //button.isEnabled = false
        
        animateIn()
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAcation = UITableViewRowAction(style: .destructive, title: "삭제") { (action, indexPath) in

            guard let id = self.todoGroups[indexPath.row].id else {return}
            
            self.apiService.deleteGroup(id: id, completion: { (success) in
                if success {
                    self.todoGroups.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.tableView.endUpdates()
                    }
                }
            })
        }
        
        return [deleteAcation]
    }
    
    func createTodoGroup(id: Int, _ title: String){
        let index = todoGroups.count
        
        let todoGroup = TGroup()
        todoGroup.id = id
        todoGroup.title = title
        todoGroup.count = 0
        todoGroups.append(todoGroup)
        
        DispatchQueue.main.async {
            
            let indexPath = IndexPath(row: index, section: 0)
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    func updateTodoGroupCount(tgroup: TGroup, state: StateTodoGroup){
        guard let index = todoGroups.index(of: tgroup) else {return}
        
        todoGroups[index].count = tgroup.count
        
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: index, section: 0)
            
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
        }
    }
}

