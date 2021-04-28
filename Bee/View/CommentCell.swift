//
//  CommentCell.swift
//  Bee
//
//  Created by Abraham Estrada on 4/13/21.
//

import UIKit

class CommentCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    var comment: Comment? {
        didSet{configure()}
    }
    
    private let roundedView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        return iv
    }()
    
    private let commentLabel = UILabel()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(roundedView)
        roundedView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 10, paddingRight: 10)
        
        addSubview(profileImageView)
        profileImageView.centerY(inView: roundedView, leftAnchor: leftAnchor, paddingLeft: 18)
        profileImageView.setDimensions(height: 40, width: 40)
        profileImageView.layer.cornerRadius = 40 / 2
        
        commentLabel.numberOfLines = 0
        addSubview(commentLabel)
        commentLabel.centerY(inView: roundedView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 18)
        commentLabel.anchor(right: rightAnchor, paddingRight: 18)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let comment = comment else {return}
        
        profileImageView.sd_setImage(with: URL(string: comment.profileImageUrl))
        commentLabel.attributedText = commentLabelText(comment: comment)
    }
    
    func commentLabelText(comment: Comment)  -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: "\(comment.username) ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedString.append(NSAttributedString(string: "\(comment.commentText)", attributes: [.font: UIFont.systemFont(ofSize: 14)]))
        
        return attributedString
    }
}
