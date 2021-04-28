//
//  NewPhotoPostController.swift
//  Bee
//
//  Created by Abraham Estrada on 4/13/21.
//

import UIKit

protocol UploadPhotoPostControllerDelegate: AnyObject {
    func controllerDidFinishUploadingPhotoPost()
}

class NewPhotoPostController: UIViewController {
    
    // MARK: - Properties
    
    var currentUser: User?
    
    var delegate: UploadPhotoPostControllerDelegate?
    
    var selectedImage: UIImage? {
        didSet { photoImageView.image = selectedImage }
    }
    
    private let photoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    
    private let captionTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.layer.cornerRadius = 25
        return tv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Actions
    
    @objc func didTapCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapPost() {
        guard let image = selectedImage else {return}
        guard let caption = captionTextView.text else {return}
        guard let currentUser = currentUser else {return}
        
        showLoader(true)
        
        PostService.uploadPhotoPost(caption: caption, image: image, user: currentUser) { (error) in
            self.showLoader(false)
            if let error = error {
                self.showMessage(withTitle: "Error", message: "Failed to upload post: \(error.localizedDescription)")
                return
            }
            self.delegate?.controllerDidFinishUploadingPhotoPost()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = #colorLiteral(red: 0.9348467588, green: 0.9434723258, blue: 0.9651080966, alpha: 1)
        navigationItem.title = "Upload Post"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action: #selector(didTapPost))
        navigationController?.navigationBar.tintColor = YELLOWCOLOR
        
        view.addSubview(photoImageView)
        photoImageView.setDimensions(height: 180, width: 180)
        photoImageView.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 8)
        photoImageView.centerX(inView: view)
        photoImageView.layer.cornerRadius = 10
        
        view.addSubview(captionTextView)
        captionTextView.anchor(top: photoImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 12, paddingLeft: 12, paddingRight: 12, height: 120)
    }
}
