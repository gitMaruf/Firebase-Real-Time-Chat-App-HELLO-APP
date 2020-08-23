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
    private var loginObserver: NSObjectProtocol?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        view.addSubview(noConversationLable)
        //view.backgroundColor = .yellow
        //DatabaseManger.shared.test()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(rightBarButtonTap))
        setupTableView()
         startListeningForConversation()
         loginObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name("SuccessfulSignInNotification"), object: nil, queue: .main, using: {[weak self]_ in
             guard let strongSelf = self else{
                 return
             }
            strongSelf.startListeningForConversation()

         })
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
           print("UserDefaults email not found")
            return
        }
        print("Listen conversatin for user defaults email \(currentUserEmail)")
        
        if let observer = loginObserver{
            NotificationCenter.default.removeObserver(observer)
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
            guard let strongSelf = self else {
                return
            }
            let currentConversation = strongSelf.conversations
//            print("Conversations: \(currentConversation) \n result: \(result)")
            if let targetConversation = currentConversation.first(where: { // first return where satisfied first time
                $0.otherEmail == result.email
            }){
                let vc = ChatViewController(with: targetConversation.otherEmail, id: targetConversation.id)
                vc.isNewConverstion = true
                vc.title = targetConversation.name
                vc.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(vc, animated: true)
            }else{
                strongSelf.createNewConversation(result: result)
            }
            
            
        }
//        navigationController?.pushViewController(vc, animated: true)
        let nvc = UINavigationController(rootViewController: vc)
        present(nvc, animated: true, completion: nil)
    }
    private func createNewConversation(result: SearchResult){
        // check if conversation exist with two user
        // if exist user that
        // else use existance code
        let name = result.name
        let email = result.email
        DatabaseManger.shared.conversationExist(with: email, completion: { [weak self] result in
            switch result{
            case .failure(let error):
                print("Failed: \(error)")
                print("ConversationId not found: \(String(describing: error))")
                let vc = ChatViewController(with: email, id: nil)
                vc.isNewConverstion = true
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            case .success(let conversationId):
//                print("ConversationId exist: \(String(describing: conversationId))")
                let vc = ChatViewController(with: email, id: conversationId)
                vc.isNewConverstion = false
                vc.title = name
                vc.navigationItem.largeTitleDisplayMode = .never
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        })

        
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
       openConversation(model)
    }
    func openConversation(_ model: Conversation){
        let vc = ChatViewController(with: model.otherEmail, id: model.id)
               vc.title = model.name
               vc.navigationItem.largeTitleDisplayMode = .never
               navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let conversatonId = conversations[indexPath.row].id
            tableView.beginUpdates()
            self.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            DatabaseManger.shared.deleteConversation(conversationId: conversatonId, completion: { success in
                if success{
                    DispatchQueue.main.async {
                        tableView.reloadData()
                    }
                    print("Conversation deleted")
                }else{
                    print("Conversation failed to delete")
                }
            })
            
            tableView.endUpdates()
        }
    }
}

