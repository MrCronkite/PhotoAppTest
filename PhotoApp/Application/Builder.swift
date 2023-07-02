//
//  Builder.swift
//  PhotoApp
//
//  Created by admin1 on 30.06.23.
//

import UIKit

protocol Builder {
    static func createViewModule() -> UIViewController
}

class BuilderImpl: Builder {
    static func createViewModule() -> UIViewController {
        let view = ViewController()
        let networkServices = NetworkServicesImpl()
        let presentr = PresenterImpl(view: view, networkServices: networkServices)
        view.presenter = presentr
        return view
    }
}
