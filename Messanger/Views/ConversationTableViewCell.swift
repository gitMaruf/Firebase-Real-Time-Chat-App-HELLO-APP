//
//  ConversationTableViewCell.swift
//  Messanger
//
//  Created by Maruf Howlader on 8/12/20.
//  Copyright © 2020 Creative Young. All rights reserved.
//

import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    static let identifier = "ConversationTableViewCell"
    
    let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        return imageView
    }()
    let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()
    let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10, y: 10, width: 100, height: 100)
        userNameLabel.frame = CGRect(x: userImageView.frame.width + 20, y: 10, width: contentView.frame.width - userImageView.frame.width - 20, height: (contentView.frame.height-20)/2)
        userMessageLabel.frame = CGRect(x: userImageView.frame.width + 20, y: userNameLabel.frame.height+15, width: contentView.frame.width - userImageView.frame.width - 20, height: (contentView.frame.height-20)/2)
    }
    
    public func configure(with model: Conversation){
        userNameLabel.text = model.name
        userMessageLabel.text = model.latestMessasge.text
        let otherUserEmail = model.otherEmail
         let safeOtherUserEmail = DatabaseManger.safeEmail(emailAddress: otherUserEmail)
        let path = "images/\(safeOtherUserEmail)_profile_picture.jpg"
        StorageManager.shared.downloadProfilePicture(with: path, completion: {[weak self] result in
            switch result{
            case .success(let url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case .failure(let error):
                print("User Image download error: \(error)")
            }
        })
    }
    
    required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }
}
