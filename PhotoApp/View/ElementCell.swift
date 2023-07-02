//
//  ElementCell.swift
//  PhotoApp
//
//  Created by admin1 on 30.06.23.
//

import UIKit

final class ElementCell: UITableViewCell {
    
    let imageViewElement: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        return view
    }()
    
    let textLable: UILabel = {
        let lable = UILabel()
        lable.font = UIFont.systemFont(ofSize: 20)
        return lable
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        [
            imageViewElement,
            textLable
        ].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            imageViewElement.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageViewElement.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageViewElement.heightAnchor.constraint(equalToConstant: 130),

            textLable.topAnchor.constraint(equalTo: imageViewElement.bottomAnchor, constant: 0),
            textLable.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            textLable.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
    }
}
