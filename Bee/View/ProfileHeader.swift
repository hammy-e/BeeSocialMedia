//
//  ProfileHeader.swift
//  Bee
//
//  Created by Abraham Estrada on 4/12/21.
//

import UIKit

protocol ProfileHeaderDelegate: AnyObject {
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User)
}

class ProfileHeader: UICollectionReusableView {
    
    // MARK: - Properties
    
    var user: User? {
        didSet{
            configure()
        }
    }
    
    weak var delegate: ProfileHeaderDelegate?
    
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
        iv.backgroundColor = .lightGray
        iv.setDimensions(height: 80, width: 80)
        iv.layer.cornerRadius = 80 / 2
        return iv
    }()
    
    private let fullNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var postsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followersLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var followLogoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.cornerRadius = 12
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(handleFollowLogoutTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(roundedView)
        roundedView.anchor(top: topAnchor, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 10, paddingRight: 10)
        
        addSubview(profileImageView)
        profileImageView.centerX(inView: roundedView)
        profileImageView.anchor(top: topAnchor, paddingTop: 24)
        
        addSubview(fullNameLabel)
        fullNameLabel.centerX(inView: roundedView)
        fullNameLabel.anchor(top: profileImageView.bottomAnchor)
        
        let stack = UIStackView(arrangedSubviews: [postsLabel, followersLabel, followingLabel])
        stack.distribution = .fillEqually
        stack.spacing = 25
        
        addSubview(stack)
        stack.centerX(inView: roundedView)
        stack.anchor(top: fullNameLabel.bottomAnchor, paddingTop: 12)
        
        addSubview(followLogoutButton)
        followLogoutButton.centerX(inView: roundedView)
        followLogoutButton.anchor(top: stack.bottomAnchor, left: leftAnchor, right: rightAnchor, paddingTop: 24, paddingLeft: 24, paddingRight: 24)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Actions
    
    @objc func handleFollowLogoutTapped() {
        guard let user = user else {return}
        delegate?.header(self, didTapActionButtonFor: user)
    }
    
    // MARK: - Helpers
    
    func configure() {
        guard let user = user else {return}
        
        fullNameLabel.text = user.fullname
        postsLabel.attributedText = attributedStatText(value: user.stats.posts, label: "Posts")
        followersLabel.attributedText = attributedStatText(value: user.stats.followers, label: "Followers")
        followingLabel.attributedText = attributedStatText(value: user.stats.following, label: "Following")
        profileImageView.sd_setImage(with: URL(string: user.profileImageUrl), completed: nil)
        
        followLogoutButton.setTitle(user.isCurrentUser ? "Logout" : (user.isFollowed ? "Following" : "Follow"), for: .normal)
        followLogoutButton.setTitleColor(user.isCurrentUser ? .black : .white, for: .normal)
        followLogoutButton.backgroundColor = user.isCurrentUser ? #colorLiteral(red: 0.9348467588, green: 0.9434723258, blue: 0.9651080966, alpha: 1) : YELLOWCOLOR
    }
    
    func attributedStatText(value: Int, label: String) -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(value)\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        attributedText.append(NSAttributedString(string: "\(label)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        return attributedText
    }
}
