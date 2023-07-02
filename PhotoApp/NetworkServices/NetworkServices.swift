//
//  NetworkServices.swift
//  PhotoApp
//
//  Created by admin1 on 30.06.23.
//

import UIKit

protocol NetworkServices {
    func getData(page: Int, complition: @escaping (Result<Element, Error>) -> Void)
    func sendPostData(id: Int, image: Data, complition: @escaping (Result<String, Error>) -> Void)
    
    func loadImage(imageURL: URL, runQueue: DispatchQueue, complitionQueue: DispatchQueue, complition: @escaping (UIImage?, Error?) -> ())
}

enum Errors: Error {
    case invalidURL
    case invalideState
}

final class NetworkServicesImpl: NetworkServices {
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    
    init(urlSession: URLSession = .shared, jsonDecoder: JSONDecoder = .init()) {
        self.urlSession = urlSession
        self.jsonDecoder = jsonDecoder
    }
    
    func getData(page: Int, complition: @escaping (Result<Element, Error>) -> Void) {
        guard let url = URL(string: "https://junior.balinasoft.com/api/v2/photo/type?page=\(page)") else {
            complition(.failure(Errors.invalidURL))
            return
        }
        
        let request = urlSession.dataTask(with: url) { [jsonDecoder] data, response, error in
            switch (data, error) {
            case let (.some(data), nil):
                do {
                    let photo = try jsonDecoder.decode(Element.self, from: data)
                    complition(.success(photo))
                } catch {
                    complition(.failure(Errors.invalideState))
                }
            case let (nil, .some(error)):
                complition(.failure(error))
            default: complition(.failure(Errors.invalideState))
            }
        }
        request.resume()
    }
    
    func loadImage(imageURL: URL, runQueue: DispatchQueue, complitionQueue: DispatchQueue, complition: @escaping (UIImage?, Error?) -> ()) {
        runQueue.async {
            do {
                let data = try Data(contentsOf: imageURL)
                complitionQueue.async { complition(UIImage(data: data), nil) }
            } catch let error {
                complitionQueue.async { complition(nil, error)}
            }
        }
    }
    
    func sendPostData(id: Int, image: Data, complition: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "https://junior.balinasoft.com/api/v2/photo") else {
            return
        }
        
        let boundary = UUID().uuidString
        var body = Data()
        
        // Добавляем имя в тело запроса
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("Владислав Шимченко".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        // Добавляем ид в тело запроса
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"typeId\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(id)".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)

        // Добавляем изображение в тело запроса
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"photo\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(image)
        body.append("\r\n".data(using: .utf8)!)
        
        // Заканчиваем запрос
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let task = urlSession.dataTask(with: request) { data, response, error in
            switch (data, error) {
            case (.some(_), nil):
                guard let response = response as? HTTPURLResponse else {
                    complition(.failure(Errors.invalideState))
                    return
                }
                complition(.success("Response status code: \(response.statusCode)"))
            case let (nil, .some(error)):
                complition(.failure(error))
            default: complition(.failure(Errors.invalideState))
            }
        }
        task.resume()
    }
}

