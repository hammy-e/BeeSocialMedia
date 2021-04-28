//
//  Status.swift
//  Bee
//
//  Created by Abraham Estrada on 4/19/21.
//

import UIKit
import SDWebImage
import Firebase

protocol PostCellDelegate: AnyObject {
    func cell(_ cell: PostCell, wantsToShowCommentsFor post: Post)
    func cell(_ cell: PostCell, didLike post: Post)
    func cell (_ cell: PostCell, wantsToShowProfileFor uid: String)
    func cell (_ cell: PostCell, didTapPostOptionsFor post: Post)
}

protocol PostCell: AnyObject {
    var post: Post? {get set}
    var likeButton: UIButton {get set}
}

class StatusPostCell: UICollectionViewCell, PostCell {
    
    // MARK: - Properties
    
    var post: Post? {
        didSet{
            configure()
        }
    }
    
    weak var delegate: PostCellDelegate?
    
    private let roundedView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 25
        return view
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.backgroundColor = .lightGray
        iv.setDimensions(height: 45, width: 45)
        iv.layer.cornerRadius = 45 / 2
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showUserProfile))
        iv.isUserInteractionEnabled = true
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private lazy var usernameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.addTarget(self, action: #selector(showUserProfile), for: .touchUpInside)
        return button
    }()
    
    lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "heart"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(likePost), for: .touchUpInside)
        return button
    }()
    
    private lazy var commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "message"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(commentPost), for: .touchUpInside)
        return button
    }()
    
    private let likesLabel: UILabel = {
        let label = UILabel()
        label.text = "1 Like"
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()
    
    private let captionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let postTimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleOptionsTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func showUserProfile() {
        guard let post = post else {return}
        delegate?.cell(self, wantsToShowProfileFor: post.ownerUid)
    }
    
    @objc func likePost() {
        guard let post = post else {return}
        delegate?.cell(self, didLike: post)
    }
    
    @objc func commentPost() {
        guard let post = post else {return}
        delegate?.cell(self, wantsToShowCommentsFor: post)
    }
    
    @objc func handleOptionsTapped() {
        guard let post = post else {return}
        delegate?.cell(self, didTapPostOptionsFor: post)
    }
    
    // MARK: - Helpers
    
    func configure() {
        
        guard let post = post else {return}
        
        captionLabel.text = post.caption
        
        profileImageView.sd_setImage(with: URL(string: post.ownerImageUrl))
        usernameButton.setTitle(post.ownerUsername, for: .normal)
        
        likesLabel.text = post.likes == 1 ? "\(post.likes) like" : "\(post.likes) likes"
        likeButton.tintColor = post.didLike ? YELLOWCOLOR : .black
        likeButton.setImage(UIImage(systemName: post.didLike ? "heart.fill" : "heart"), for: .normal)
        
        var timestampString: String? {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.second, .minute, .hour, .day, .weekOfMonth]
            formatter.maximumUnitCount = 1
            formatter.unitsStyle = .full
            return formatter.string(from: post.timestamp.dateValue(), to: Date())
        }
        
        postTimeLabel.text = timestampString
        
        layoutViews()
    }
    
    func layoutViews() {
        addSubview(roundedView)
        roundedView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 10, paddingRight: 10)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 22, paddingLeft: 22)
        
        addSubview(usernameButton)
        usernameButton.centerY(inView: profileImageView, leftAnchor: profileImageView.rightAnchor, paddingLeft: 10)
        
        addSubview(postTimeLabel)
        postTimeLabel.centerY(inView: profileImageView)
        postTimeLabel.anchor(right: rightAnchor, paddingRight: 22)
        
        addSubview(captionLabel)
        captionLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 8)
        captionLabel.centerX(inView: roundedView)
        captionLabel.setWidth(self.frame.width - 30)
        
        configureActionButtons()
    }
    
    func configureActionButtons() {
        let stackView = UIStackView(arrangedSubviews: [likeButton, likesLabel, commentButton])
        stackView.axis = .horizontal
        stackView.distribution = .equalCentering
        
        addSubview(stackView)
        stackView.centerX(inView: roundedView)
        stackView.anchor(top: captionLabel.bottomAnchor, width: 125, height: 50)
        
        if Auth.auth().currentUser?.uid == post?.ownerUid {
            addSubview(optionsButton)
            optionsButton.anchor(top: captionLabel.bottomAnchor, right: rightAnchor, paddingTop: 16, paddingRight: 32)
        }
    }
}
