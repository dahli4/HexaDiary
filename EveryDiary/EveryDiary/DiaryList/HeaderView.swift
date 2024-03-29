//
//  HeaderView.swift
//  EveryDiary
//
//  Created by t2023-m0026 on 2/27/24.
//

import UIKit

class HeaderView: UICollectionReusableView {
    static let reuseIdentifier = "HeaderView"
    
    let headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    private func setupViews() {
        addSubview(headerLabel)
        
        headerLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
        }
    }
}
