//
//  Presenter.swift
//  PhotoApp
//
//  Created by admin1 on 30.06.23.
//

import UIKit

protocol ViewProtocol: AnyObject {
    func succes()
    func failure(error: Error)
    func showServerResponse(status: String)
}

protocol Presenter: AnyObject {
    var content: [Content]? {get set}
    var images: [UIImage] {get set}
    
    init(view: ViewProtocol, networkServices: NetworkServices)
    
    func getElement()
    func getImages(elemnts: [Content])
    func uploadMoreElement()
    func sendPhoto(image: UIImage, id: Int)
}

final class PresenterImpl: Presenter {
    weak var view: ViewProtocol?
    let networkServices: NetworkServices
    var content: [Content]?
    var images = [UIImage]()
    var page = 1
    
    required init(view: ViewProtocol, networkServices: NetworkServices) {
        self.view = view
        self.networkServices = networkServices
        getElement()
    }
    
    func getElement() {
        networkServices.getData(page: 0) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.content = data.content
                    self.getImages(elemnts: data.content)
                case .failure(let error):
                    self.view?.failure(error: error)
                }
            }
        }
    }
    
    func uploadMoreElement() {
        networkServices.getData(page: self.page) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.content?.append(contentsOf: data.content)
                    self.getImages(elemnts: data.content)
                    self.page += 1
                case .failure(let error):
                    self.view?.failure(error: error)
                }
            }
        }
    }
    
    func getImages(elemnts: [Content]) {
        let dispatchGroup = DispatchGroup()
        for i in 0..<elemnts.count {
            dispatchGroup.enter()
            networkServices.loadImage(imageURL: URL(string: elemnts[i].image ?? "https://smk-dental.ru/images/design/blank-photo.jpg")!,
                                      runQueue: DispatchQueue.global(),
                                      complitionQueue: DispatchQueue.main) { [weak self] result, error in
                guard let self = self else { return }
                guard let image = result else { return }
                self.images.append(image)
                if self.images.count == content?.count { self.view?.succes() }
                dispatchGroup.leave()
            }
        }
    }
    
    func sendPhoto(image: UIImage, id: Int) {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        
        networkServices.sendPostData(id: id, image: imageData) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let status):
                    self.view?.showServerResponse(status: status)
                case .failure(let error):
                    self.view?.failure(error: error)
                }
            }
        }
    }
}
