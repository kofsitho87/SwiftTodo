//
//  ApiService.swift
//  Todo
//
//  Created by 송희웅 on 2017. 10. 18..
//  Copyright © 2017년 송희웅. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ApiService: NSObject {
    
    static let shared = ApiService()
    
    let baseUrl = "http://13.124.218.189:3000/"
    //let baseUrl = "http://localhost:3000/"
    
    let uid = 1
    var headers : HTTPHeaders = [
        "Accept": "application/json"
    ]
    var parameters: Parameters = [:]
    
    private func request(url: String, params: Parameters, method: HTTPMethod, completion: @escaping (Bool, JSON?) -> Void){
        parameters = params
        
        Alamofire.request(baseUrl + url, method: method, parameters: parameters, encoding: URLEncoding.httpBody, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    guard let data = response.data else {
                        completion(false, nil)
                        return
                    }
                    let json = JSON(data: data)
                    completion(true, json)
                    
                case .failure(let err):
                    print("http response error : ", err.localizedDescription)
                    completion(false, nil)
                }
        }
    }
    
    func getTodosFromGid(gid: Int, completion: @escaping (Bool, [Todo]?) -> Void){
        parameters = ["uid": uid, "gid": gid]
        
        Alamofire.request(baseUrl + "todo/getTodos", method: .post, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = JSON(data: response.data!)
                    
                    guard let todos = json["data"].array else {
                        completion(false, nil)
                        return
                    }
                    
                    let newTodos = todos.map({ (_todo) -> Todo in
                        let todo = Todo()
                        todo.id = _todo["id"].intValue
                        todo.gid = _todo["gid"].intValue
                        todo.content = _todo["content"].stringValue
                        todo.completed = _todo["completed"].boolValue
                        return todo
                    })
                    
                    completion(true, newTodos)
                case .failure(let err):
                    print(err.localizedDescription)
                    completion(false, nil)
                }
        }
    }
    
    
    func getGroups(completion: @escaping (Bool, [TGroup]?, Int) -> Void){
        
        let url = "todo/\(uid)/getList"
        request(url: url, params: parameters, method: .get) { (success, json) in
            if success {
                guard let data = json?["data"].dictionary,
                    let groups = data["groups"]?.array,
                    let totalTodos = data["totalTodos"]?.int else {
                        completion(false, nil, 0)
                        return
                    }
                
                let newGroups = groups.map({ (group) -> TGroup in
                    let g = TGroup()
                    g.id = group["gid"].intValue
                    g.count = group["gcnt"].intValue
                    g.title = group["title"].stringValue
                    return g
                })
                
                completion(true, newGroups, totalTodos)
                return
            }
            
            completion(false, nil, 0)
        }
       
    }
    
    func addTodo(gid: Int, content: String, completion: @escaping (Bool, Todo?) -> Void){
        let url = "todo/add"
        parameters = [
            "uid": uid,
            "gid": gid,
            "content": content,
            "completed": false
        ]
        Alamofire.request(baseUrl + url, method: .post, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
            .responseJSON { (response) in
                switch response.result {
                case .success:
                    let json = JSON(data: response.data!)

                    guard let data = json["data"].dictionary,
                        let todo = data["todo"]?.dictionary else {
                        completion(false, nil)
                        return
                    }
                    
                    let newTodo = Todo()
                    newTodo.id = todo["id"]?.intValue
                    newTodo.gid = todo["gid"]?.intValue
                    newTodo.content = todo["content"]?.stringValue
                    newTodo.completed = (todo["completed"]?.boolValue)!
                    
                    completion(true, newTodo)
                    
                case .failure(let err):
                    print(err.localizedDescription)
                    completion(false, nil)
                }
        }
    }
    
    func deleteTodo(id: Int, completion: @escaping (Bool) -> Void){
        let url = "todo/\(id)"
        let params: Parameters = [
            "uid" : self.uid
        ]
        
        request(url: url, params: params, method: .delete) { (success, json) in
            completion(success)
        }
    }
    
    func changeTodo(id: Int, update: [String: Any], completion: @escaping (Bool) -> Void){
        let url = "todo/\(id)"

        var params: Parameters = update
        params["uid"] = uid
        
        request(url: url, params: params, method: .put) { (success, json) in
            completion(success)
        }
    }
    
    func deleteGroup(id: Int, completion: @escaping (Bool) -> Void){
        let url = "todo/group/\(id)"
        let params: Parameters = [
            "uid" : self.uid
        ]
        
        request(url: url, params: params, method: .delete) { (success, json) in
            completion(success)
        }
    }
    
    func createGroup(title: String, completion: @escaping (Bool, Int?) -> Void){
        let url = "todo/group/"
        let params: Parameters = [
            "uid" : self.uid,
            "title" : title
        ]
        
        request(url: url, params: params, method: .post) { (success, json) in
            guard let data = json?["data"].dictionary,
                let id = data["id"]?.int  else {
                completion(false, nil)
                return
            }
            
            completion(success, id)
        }
    }
    
}
