//
//  SceneDelegate.swift
//  PhotoApp
//
//  Created by admin1 on 30.06.23.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        let view = BuilderImpl.createViewModule()
        window?.rootViewController = view
        window?.makeKeyAndVisible()
    }
}


