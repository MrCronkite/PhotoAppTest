//
//  Photo.swift
//  PhotoApp
//
//  Created by admin1 on 30.06.23.
//

import Foundation

// MARK: - Photo
struct Element: Decodable {
    let page, pageSize, totalPages, totalElements: Int
    let content: [Content]
}

// MARK: - Content
struct Content: Decodable {
    let id: Int
    let name: String
    let image: String?
}
