//
//  ViewController.swift
//  PhotoApp
//
//  Created by admin1 on 30.06.23.
//

import UIKit

final class ViewController: UIViewController{
    
    var presenter: Presenter!
    var id: Int!
    
    let mainTableView: UITableView = {
        var view = UITableView()
        view = .init(frame: .zero, style: .plain)
        view.separatorStyle = .singleLine
        view.rowHeight = UITableView.automaticDimension
        view.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        configureViewController()
    }
}

extension ViewController {
    private func configureViewController() {
        view.addSubview(mainTableView)
        mainTableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mainTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            mainTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            mainTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
            mainTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
        ])
        
        mainTableView.register(ElementCell.self, forCellReuseIdentifier: "\(ElementCell.self)")
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
    }
    
    private func showAlert(text: String, title: String) {
        let alert = UIAlertController(title: title, message: text, preferredStyle: .actionSheet)
        let actionAC = UIAlertAction(title: "OK", style: .cancel)
        
        alert.addAction(actionAC)
        present(alert, animated: true)
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.content?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(ElementCell.self)",
                                                       for: indexPath) as? ElementCell
        else { return UITableViewCell() }
        let title = presenter.content?[indexPath.row].name
        let image = presenter.images[indexPath.row]
        
        cell.imageViewElement.image = image
        cell.textLable.text = title
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (presenter.content?.count ?? 0) - 3 {
            presenter.uploadMoreElement()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.id = indexPath.row
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        
        if  UIImagePickerController.isCameraDeviceAvailable(.rear) {
            imagePicker.sourceType = .camera
            imagePicker.cameraDevice = .rear
            
            if UIImagePickerController.isCameraDeviceAvailable(.front) {
                imagePicker.cameraDevice = .rear
                imagePicker.cameraCaptureMode = .photo
            }
            present(imagePicker, animated: true, completion: nil)
        } else {
            imagePicker.sourceType = .photoLibrary
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        presenter.sendPhoto(image: image, id: self.id)
    }
}

extension ViewController: ViewProtocol {
    func showServerResponse(status: String) {
        self.showAlert(text: status, title: "Picture sent successfully")
    }
    
    func succes() {
        self.mainTableView.reloadData()
    }
    
    func failure(error: Error) {
        self.showAlert(text: error.localizedDescription, title: "Error")
    }
}
