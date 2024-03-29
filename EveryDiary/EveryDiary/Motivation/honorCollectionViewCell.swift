//
//  honorCollectionViewCell.swift
//  EveryDiary
//
//  Created by t2023-m0099 on 3/22/24.
//

import UIKit

class honorCollectionViewCell: UICollectionViewCell {
    static let honorIdentifier = "honorCollectionViewCell"
    
    var images: UIImageView = {
        let images = UIImageView()
        images.contentMode = .scaleAspectFit
        return images
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubView()
        autoLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubView() {
        contentView.addSubview(images)
    }
    
    private func autoLayout() {
        images.snp.makeConstraints { make in
            make.top.bottom.leading.trailing.equalToSuperview()
            make.centerX.centerY.equalToSuperview()
        }
    }
    
    func configureImage(withNumberOfDays numberOfDays: Int) {
         switch numberOfDays {
         case 1...7:
             images.image = UIImage(named: "button1")
         case 8...14:
             images.image = UIImage(named: "button2")
         case 15...21:
             images.image = UIImage(named: "button3")
         case 22...27:
             images.image = UIImage(named: "button4")
         default:
             images.image = UIImage(named: "button5")
         }
     }
}
