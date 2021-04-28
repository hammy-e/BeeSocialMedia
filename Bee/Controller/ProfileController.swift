//
//  ProfileController.swift
//  Bee
//
//  Created by Abraham Estrada on 4/12/21.
//

import UIKit
import Firebase

private let photoCellIdentifier = "photo"
private let statusCellIndetifier = "status"
 
class ProfileController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var user: User
    
    private var posts = [Post]() {
        didSet{collectionView.reloadData()}
    }
    
    // MARK: - Lifecycle
    
    init(user: User) {
        self.user = user
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        checkIfUserIsFollowed()
        fetchUserStats()
        fetchPosts()
    }
    
    // MARK: - Actions
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchPosts()
        fetchUserStats()
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
            let controller = LoginController()
            controller.delegate = self.tabBarController as? MainTabController
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
            
        } catch {
            showMessage(withTitle: "Error", message: "Failed to sign out")
        }
    }
    
    // MARK: - API
    
    func checkIfUserIsFollowed() {
        UserService.checkIfUserIsFollowed(uid: user.uid) { (isFollowed) in
            self.user.isFollowed = isFollowed
            self.collectionView.reloadData()
            self.checkIfUserLikedPost()
        }
    }
    
    func fetchUserStats() {
        UserService.fetchUserStats(uid: user.uid) { (stats) in
            self.user.stats = stats
            self.collectionView.reloadData()
        }
    }
    
    func fetchPosts() {
        PostService.fetchPosts(forUser: user.uid) { (posts) in
            self.posts = posts
            self.checkIfUserLikedPost()
            self.collectionView.reloadData()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    func checkIfUserLikedPost() {
        posts.forEach { (post) in
            PostService.checkIfUserLikedPost(post: post) { (didLike) in
                if let index = self.posts.firstIndex(where: {$0.postId == post.postId}) {
                    self.posts[index].didLike = didLike
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    func configureCollectionView() {
        collectionView.backgroundColor = #colorLiteral(red: 0.9348467588, green: 0.9434723258, blue: 0.9651080966, alpha: 1)
        
        navigationItem.title = user.username
        
        collectionView.register(StatusPostCell.self, forCellWithReuseIdentifier: statusCellIndetifier)
        collectionView.register(PhotoPostCell.self, forCellWithReuseIdentifier: photoCellIdentifier)
        collectionView.register(ProfileHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: statusCellIndetifier)
        
        let refersher = UIRefreshControl()
        refersher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refersher
    }
}

// MARK: - UICollectionViewDataSource

extension ProfileController {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if posts[indexPath.row].imageUrl == "" {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: statusCellIndetifier, for: indexPath) as! StatusPostCell
            cell.post = posts[indexPath.row]
            cell.delegate = self
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoCellIdentifier, for: indexPath) as! PhotoPostCell
            cell.post = posts[indexPath.row]
            cell.delegate = self
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: statusCellIndetifier, for: indexPath) as! ProfileHeader
        header.user = user
        header.delegate = self
        return header
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ProfileController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let captionHeight: CGFloat = {
            let label = UILabel()
            label.numberOfLines = 0
            label.text = posts[indexPath.row].caption
            label.lineBreakMode = .byWordWrapping
            label.setWidth(self.view.frame.width)
            let captionFrame = label.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            return captionFrame.height
        }()
        
        let statusPostSize = CGFloat(135 + captionHeight)
        let photoPostSize = CGFloat(135 + view.frame.width + captionHeight)
        
        return CGSize(width: view.frame.width, height: posts[indexPath.row].imageUrl == "" ? statusPostSize : photoPostSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 250)
    }
}

// MARK: - PostCellDelegate

extension ProfileController: PostCellDelegate {
    func cell(_ cell: PostCell, wantsToShowCommentsFor post: Post) {
        let controller = CommentController(post: post)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func cell(_ cell: PostCell, didLike post: Post) {
        cell.post?.didLike.toggle()
        
        if post.didLike {
            PostService.unlikePost(post: post) { (error) in
                cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
                cell.likeButton.tintColor = .black
                cell.post?.likes = post.likes - 1
            }
        } else {
            PostService.likePost(post: post) { (error) in
                cell.likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
                cell.likeButton.tintColor = YELLOWCOLOR
                cell.post?.likes = post.likes + 1
            }
        }
    }
    
    func cell(_ cell: PostCell, wantsToShowProfileFor uid: String) {
        UserService.fetchUser(withUid: uid) { (user) in
            let controller = ProfileController(user: user)
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func cell(_ cell: PostCell, didTapPostOptionsFor post: Post) {
        let deletePost = UIAlertAction(title: "Delete Post", style: .destructive) { _ in
            self.showLoader(true)
            PostService.deletePost(post) { (error) in
                self.showLoader(false)
                if let error = error {
                    self.showMessage(withTitle: "Error", message: "Failed to login user: \(error.localizedDescription)")
                    return
                }
                self.handleRefresh()
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let actionSheet = UIAlertController(title: "Options", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(deletePost)
        actionSheet.addAction(cancel)
        actionSheet.view.tintColor = YELLOWCOLOR
        
        present(actionSheet, animated: true, completion: nil)
    }
}

// MARK: - ProfileHeaderDelegate

extension ProfileController: ProfileHeaderDelegate {
    func header(_ profileHeader: ProfileHeader, didTapActionButtonFor user: User) {
        if user.isCurrentUser {
            logout()
        }else if user.isFollowed {
            UserService.unfollow(uid: user.uid) { (error) in
                self.user.isFollowed = false
                self.collectionView.reloadData()
                PostService.updateUserFeedAfterFollowing(user: user, didFollow: false)
            }
        } else {
            UserService.follow(uid: user.uid) { (error) in
                self.user.isFollowed = true
                self.collectionView.reloadData()
                
                PostService.updateUserFeedAfterFollowing(user: user, didFollow: true)
            }
        }
    }
}
