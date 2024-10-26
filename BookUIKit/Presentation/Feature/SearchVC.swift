//
//  SearchVC.swift
//  BookUIKit
//
//  Created by jiin heo on 10/20/24.
//

import UIKit

final class SearchVC: UIViewController {
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "HomeVC"
        label.font = .systemFont(ofSize: .init(40))
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension SearchVC {
    
    func configLayout() {
        
        self.view.addSubview(titleLabel)
        
        [titleLabel].forEach {
            view.addSubview(titleLabel)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        ])

    }
}
