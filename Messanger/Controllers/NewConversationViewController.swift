//
//  NewConversationViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    let hud = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]]()
    private var result = [[String: String]]()
    
    private var hasFeched = false
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.barStyle = .black
        searchBar.placeholder = "Search New Users"
        return searchBar
    }()
    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.isHidden = true
        return table
    }()
    let noSearchResult: UILabel = {
        let label = UILabel()
        label.text = "No Search Result!"
        label.isHidden = true
        label.textAlignment =  .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noSearchResult)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noSearchResult.frame = CGRect(x: 0, y: (view.frame.height-200)/2, width: view.frame.width, height: 200)
    }
    @objc private func dismissSelf(){
        self.dismiss(animated: true, completion: nil)
    }
}
extension NewConversationViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        result.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = result[indexPath.row]["name"]
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        //start conversation
    }
    
}
extension NewConversationViewController: UISearchBarDelegate{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        result.removeAll()
        hud.show(in: view)
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else{
            return
        }
        searchUsers(query: text)
    }
    private func searchUsers(query: String){
        print("checked if array has firebase result")
        if hasFeched{
            print("if it does; Filter")
        filterUsers(with: query)
        }else{
            print("if not fetch then filter")
            
            DatabaseManger.shared.getAllUsers(completion: {[weak self] result in
                switch result{
                case .success(let usersCollection):
                    self?.hasFeched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case .failure(let error):
                    print("Database Manager Shared Get All Users Error: \(error)")
                }
            })
        }
    }
    
    func filterUsers(with term: String){
        guard hasFeched else{
            return
        }
        hud.dismiss()
        let result: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else{
                return false
            }
            print("I am here \(name)")
            return name.hasPrefix(term.lowercased())
        })
        self.result = result
        updateUI()
    }
    func updateUI(){
        if result.isEmpty{
            self.noSearchResult.isHidden = false
            self.tableView.isHidden = true
        }else{
            self.noSearchResult.isHidden = true
            self.tableView.isHidden = false
            tableView.reloadData()
        }
    }
}
