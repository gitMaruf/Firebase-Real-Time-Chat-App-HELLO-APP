//
//  ViewController.swift
//  Messanger
//
//  Created by Maruf Howlader on 7/10/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//
import UIKit
import FirebaseAuth

public struct Conversation{
    let id: String
    let name: String
    let otherEmail: String
    let latestMessasge: LatestMessasge
}
public struct LatestMessasge {
    let text: String
    let date: String
    let isRead: Bool
}
class ConversationsViewController: UIViewController {
    
    private var conversations = [Conversation]()
    let tableView: UITableView = {
       let table = UITableView()
//        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: ConversationTableViewCell.identifier)
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
        startListeningForConversation()
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
    private func startListeningForConversation(){
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else{
            return
        }
        let safeEmail = DatabaseManger.safeEmail(emailAddress: currentUserEmail)
        DatabaseManger.shared.getAllConversation(for: safeEmail, completion: {[weak self] result in
            switch result{
            case .success(let conversations):
                //print("coversations is \(conversations)")
                guard !conversations.isEmpty else{
                    return
                }
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
            print("Conversation Listening Error(No Conversation Found) \(error)")
            }
        })
    }
    
    private func setupTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    @objc private func rightBarButtonTap(){
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            print("\(result)")
            
            self?.createNewConversation(result: result)
        }
//        navigationController?.pushViewController(vc, animated: true)
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true, completion: nil)
    }
    private func createNewConversation(result: [String: String]){
        guard let name = result["name"], let email = result["email"] else{
            return
        }
        let vc = ChatViewController(with: email, id: nil)
        vc.isNewConverstion = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
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
        return conversations.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, for: indexPath) as! ConversationTableViewCell
        let model = conversations[indexPath.row]
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        //cell.textLabel?.text = "Joe Smith"
        cell.configure(with: model)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        let vc = ChatViewController(with: model.otherEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

