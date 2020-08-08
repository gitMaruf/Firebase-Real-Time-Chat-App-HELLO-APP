//
//  ViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {

    let tableView: UITableView = {
       let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.isHidden = true
        return table
    }()
    let noConversationLable: UILabel = {
       let label = UILabel()
        label.text = "No Conversation Found!"
        label.isHidden = true
        label.textAlignment =  .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(noConversationLable)
        //view.backgroundColor = .yellow
        //DatabaseManger.shared.test()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(rightBarButtonTap))
        setupTableView()
        print("1 viewDidLoad")
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        print("2 viewDidLayoutSubviews")
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //let isLoginStatus = UserDefaults.standard.bool(forKey: "isLogin")
        validateAuth()
        fetchConversation()
        print("3 viewDidAppear")
    }
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    @objc private func rightBarButtonTap(){
        let vc = NewConversationViewController()
//        navigationController?.pushViewController(vc, animated: true)
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true, completion: nil)
    }
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nvc = UINavigationController(rootViewController: vc)
            nvc.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            present(nvc, animated: true, completion: nil)
        }
        
    }
    public func fetchConversation(){
        tableView.isHidden = false
    }

}
extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        cell.textLabel?.text = "Joe Smith"
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ChatViewController()
        vc.title = "Joe Smith"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

