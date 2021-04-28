//
//  MainTabController.swift
//  Bee
//
//  Created by Abraham Estrada on 4/12/21.
//

import UIKit
import Firebase

class MainTabController: UITabBarController {
    
    // MARK: - Properties
    
    var user: User? {
        didSet{
            guard let user = user else {return}
            configureViewControllers(withUser: user)
        }
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserIsLoggedIn()
        fetchUser()
    }
    
    // MARK: - API
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let controller = LoginController()
                controller.delegate = self
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true, completion: nil)
            }
        }
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        UserService.fetchUser(withUid: uid) { (user) in
            self.user = user
        }
    }
    
    func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            showMessage(withTitle: "Error", message: "Failed to sign out")
        }
    }
    
    // MARK: - Helpers
    
    func configureViewControllers(withUser: User) {
        let homeLayout = UICollectionViewFlowLayout()
        let todayTab = templateNavigationController(unselectedImage: UIImage(systemName: "house")!, selectedImage: UIImage(systemName: "house.fill")!, rootViewController: FeedController(collectionViewLayout: homeLayout))

        let allTab = templateNavigationController(unselectedImage: UIImage(systemName: "magnifyingglass.circle")!, selectedImage: UIImage(systemName: "magnifyingglass.circle.fill")!, rootViewController: SearchController())
        
        let settingsTab = templateNavigationController(unselectedImage: UIImage(systemName: "person")!, selectedImage: UIImage(systemName: "person.fill")!, rootViewController: ProfileController(user: withUser))
        
        viewControllers = [todayTab, allTab, settingsTab]
        
        tabBar.tintColor = YELLOWCOLOR
    }
    
    func templateNavigationController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: rootViewController)
        nav.tabBarItem.selectedImage = selectedImage
        nav.tabBarItem.image = unselectedImage
        nav.navigationBar.tintColor = YELLOWCOLOR
        
        return nav
    }
}

//MARK: - AuthenticationDelegate

extension MainTabController: AuthenticationDelegate {
    func authenticationDidComplete() {
        fetchUser()
        self.dismiss(animated: true, completion: nil)
    }
}
