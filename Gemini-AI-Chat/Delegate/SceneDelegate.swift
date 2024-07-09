//
//  SceneDelegate.swift
//  swift-login-system
//
//  Created by eren on 26.04.2024.
//

import UIKit
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        self.setupWindow(with: scene)
        self.checkAuthentication()
    }

    private func setupWindow(with scene: UIScene) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.makeKeyAndVisible()
    }
    
    public func checkAuthentication() {
        if Auth.auth().currentUser == nil {
            self.goToController(with: LoginViewController())
        } else {
            self.goToController(with: HomeViewController(viewModel: ChatViewModel(), viewController: MenuViewController()))
        }
    }
    
    private func goToController(with viewController: UIViewController) {
   
                let nav = UINavigationController(rootViewController: viewController)
                self.window?.rootViewController = nav
                
    }

}

