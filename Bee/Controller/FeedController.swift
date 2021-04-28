//
//  FeedController.swift
//  Bee
//
//  Created by Abraham Estrada on 4/12/21.
//

import UIKit
import Firebase
import YPImagePicker

private let photoCellIdentifier = "photo"
private let statusCellIndetifier = "status"

class FeedController: UICollectionViewController {
    
    // MARK: - Properties
    
    private var posts = [Post]() {
        didSet {collectionView.reloadData()}
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchPosts()
        configureCollectionView()
    }
    
    // MARK: - Actions
    
    @objc func handleRefresh() {
        posts.removeAll()
        fetchPosts()
    }
    
    @objc func handleLogout() {
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
    
    @objc func handleNewPost() {
        let newStatusPost = UIAlertAction(title: "New Status", style: .default) { _ in self.createNewStatusPost()}
        let newPhotoPost = UIAlertAction(title: "New Photo", style: .default) { _ in self.createNewPhotoPost()}
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let actionSheet = UIAlertController(title: "New Post", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(newStatusPost)
        actionSheet.addAction(newPhotoPost)
        actionSheet.addAction(cancel)
        actionSheet.view.tintColor = YELLOWCOLOR
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    func didFinishPickingMedia(_ picker: YPImagePicker) {
        picker.didFinishPicking { items, _ in
            picker.dismiss(animated: false) {
                guard let selectedImage = items.singlePhoto?.image else {return}
                
                let mainController = self.tabBarController as? MainTabController
                let controller = NewPhotoPostController()
                controller.currentUser = mainController?.user
                controller.selectedImage = selectedImage
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: false, completion: nil)
            }
        }
    }
    
    // MARK: - API
    
    func fetchPosts() {
        PostService.fetchFeedPosts { (posts) in
            self.posts = posts
            self.checkIfUserLikedPost()
        }
        collectionView.refreshControl?.endRefreshing()
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
        navigationItem.title = "Feed"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "New Post", style: .plain, target: self, action: #selector(handleNewPost))
        
        collectionView.register(StatusPostCell.self, forCellWithReuseIdentifier: statusCellIndetifier)
        collectionView.register(PhotoPostCell.self, forCellWithReuseIdentifier: photoCellIdentifier)
        
        let refersher = UIRefreshControl()
        refersher.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refersher
    }
    
    func createNewStatusPost() {
        let alert = UIAlertController(title: "New Status", message: nil, preferredStyle: .alert)
        alert.addTextField { _ in}
        alert.addAction(UIAlertAction(title: "Post", style: .default, handler: { alertAction in
            let textfield = alert.textFields![0]
            guard let caption = textfield.text else {return}
            guard let mainController = self.tabBarController as? MainTabController else {return}
            guard let currentUser = mainController.user else {return}
            self.showLoader(true)
            
            PostService.uploadStatusPost(caption: caption, user: currentUser) { (error) in
                self.showLoader(false)
                if let error = error {
                    self.showMessage(withTitle: "Error", message: "Failed to upload post: \(error.localizedDescription)")
                    return
                }
            }
            self.handleRefresh()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.view.tintColor = YELLOWCOLOR
        self.present(alert, animated: true, completion: nil)
    }
    
    func createNewPhotoPost() {
        var config = YPImagePickerConfiguration()
        config.library.mediaType = .photo
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen = .library
        config.screens = [.library]
        config.hidesStatusBar = false
        config.hidesBottomBar = false
        config.library.maxNumberOfItems = 1
        
        let picker = YPImagePicker(configuration: config)
        picker.modalPresentationStyle = .fullScreen
        picker.navigationBar.tintColor = YELLOWCOLOR
        present(picker, animated: true, completion: nil)
        
        didFinishPickingMedia(picker)
    }
}

// MARK: - UICollectionViewDataSource

extension FeedController {
    
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
}

// MARK: - UICollectionViewDelegateFlowLayout

extension FeedController: UICollectionViewDelegateFlowLayout {
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
        
        let statusPostSize = CGSize(width: view.frame.width, height: 135 + captionHeight)
        let photoPostSize = CGSize(width: view.frame.width, height: 135 + view.frame.width + captionHeight)
        
        return posts[indexPath.row].imageUrl == "" ? statusPostSize : photoPostSize
    }
}

// MARK: - PostCellDelegate

extension FeedController: PostCellDelegate {
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

// MARK: - UploadPhotoPostControllerDelegate

extension FeedController: UploadPhotoPostControllerDelegate {
    func controllerDidFinishUploadingPhotoPost() {
        handleRefresh()
    }
}
