//
//  DetailVC.swift
//  EveryDiary
//
//  Created by t2023-m0099 on 3/21/24.
//

import UIKit

import SnapKit

class DetailVC: UIViewController {
    private var firstLayer = CAShapeLayer()
    private var secondLayer = CAShapeLayer()
    private let windowLayer = CALayer()
    
    var selectedData = Set<Int>()
    var yearMonthKey = String()
    
    private lazy var closeButton : UIButton = {
        let closeButton = UIButton()
        closeButton.setImage(UIImage(systemName:"xmark"), for: .normal)
        closeButton.sizeToFit()
        closeButton.tintColor = .mainCell
        closeButton.addTarget(self, action: #selector(closeDetailVC), for: .touchUpInside)
        return closeButton
    }()

    private lazy var detailImageView: UIImageView = {
        let detailImageView = UIImageView()
        detailImageView.contentMode = .scaleToFill
        return detailImageView
    }()
    
    private lazy var detailView: UIView = {
        let detailView = UIView()
        detailView.backgroundColor = .clear
        return detailView
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        drawCacheBackBuildingPath()
        drawCacheBuildingPath()
        drawWindows()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        addSubView()
        updateImageForMonth()
        autoLayout()
    }
    
    private func updateImageForMonth() {
        let monthString = yearMonthKey.suffix(2)
        if let month = Int(monthString) {
            let imageName: String
            switch month {

            case 3...5:
                imageName = "detailImage3"
            case 6...8:
                imageName = "detailImage2"
            case 9...11:
                imageName = "detailImage4"
            default:
                imageName = "detailImage" // 기본 이미지 이름
            }
            detailImageView.image = UIImage(named: imageName)
        }
    }

        @objc private func closeDetailVC() {
        self.dismiss(animated: true, completion: nil)
    }
    
    private func drawCacheBuildingPath() {
        let buildingPath: UIBezierPath
        if let cachedBuildingPath = BezierPathCache.shared.getBezierPath(forKey: "cachedBuildingPath") {
            buildingPath = cachedBuildingPath
        } else {
            buildingPath = BuildingView().drawBuilding()
            BezierPathCache.shared.setBezierPath(buildingPath, forKey: "cachedBuildingPath")
        }
        secondLayer.path = buildingPath.cgPath
        secondLayer.fillColor = UIColor.black.cgColor
        detailView.layer.addSublayer(secondLayer)
    }
    
    private func drawCacheBackBuildingPath() {
        let backBuildingPath: UIBezierPath
        if let cachedBackBuildingPath = BezierPathCache.shared.getBezierPath(forKey: "cachedBackBuildingPath") {
            backBuildingPath = cachedBackBuildingPath
        } else {
            backBuildingPath = BuildingView().drawBackBuilding()
            BezierPathCache.shared.setBezierPath(backBuildingPath, forKey: "cachedBackBuildingPath")
        }
        firstLayer.path = backBuildingPath.cgPath
        firstLayer.fillColor = UIColor.darkGray.cgColor
        detailView.layer.addSublayer(firstLayer)
    }
    
    private func drawWindows() {
        let building1 = BuildingSize(position: CGPoint(x: 0, y: view.layer.bounds.height * 0.78),
                                     size: CGSize(width: view.layer.bounds.width * 0.07, height: view.layer.bounds.height * 0.22),
                                     windowLayout: WindowLayout(columns: [[0, 1], [1, 1], [1], [1, 1], [1]]))
        
        let building2 = BuildingSize(position: CGPoint(x: view.layer.bounds.width * 0.21, y: view.layer.bounds.height * 0.77),
                                     size: CGSize(width: view.layer.bounds.width * 0.07, height: view.layer.bounds.height * 0.21),
                                     windowLayout: WindowLayout(columns: [[0, 1, 1], [1, 0, 1],[1, 1], [0, 1]]))
        
        let building3 = BuildingSize(position: CGPoint(x: view.layer.bounds.width * 0.51, y: view.layer.bounds.height * 0.8),
                                     size: CGSize(width: view.layer.bounds.width * 0.048, height: view.layer.bounds.height * 0.15),
                                     windowLayout: WindowLayout(columns: [[1, 1, 0],[0, 1, 1], [1, 0, 1], [0, 1]]))
        
        let building4 = BuildingSize(position: CGPoint(x: view.layer.bounds.width * 0.73, y: view.layer.bounds.height * 0.83),
                                     size: CGSize(width: (view.layer.bounds.width - view.layer.bounds.width * 0.92), height: view.layer.bounds.height * 0.3),
                                     windowLayout: WindowLayout(columns: [[1], [1], [1, 1, 1], [1, 1]]))
        
        let building5 = BuildingSize(position: CGPoint(x: 0, y: view.layer.bounds.height * 0.75),
                                     size: CGSize(width: view.layer.bounds.width * 0.045, height: view.layer.bounds.height * 0.3),
                                     windowLayout: WindowLayout(columns: [[0, 1, 1]]))
        
        let building6 = BuildingSize(position: CGPoint(x: view.layer.bounds.width * 0.94, y: view.layer.bounds.height * 0.75),
                                     size: CGSize(width: view.layer.bounds.width * 0.045, height: view.layer.bounds.height * 0.3),
                                     windowLayout: WindowLayout(columns: [[1]]))
        
        let buildings = [building1, building2, building3, building4, building5, building6]
        WindowDrawingHelper.drawBuildingWithWindows(buildings: buildings, onLayer: windowLayer, diaryDays: selectedData)
        detailView.layer.addSublayer(windowLayer)
    }
}

extension DetailVC {
    private func addSubView() {
        view.addSubview(detailImageView)
        view.addSubview(detailView)
        view.addSubview(closeButton)
    }
    
    private func autoLayout() {
        detailImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        detailView.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view.safeAreaLayoutGuide)
            make.top.bottom.equalTo(view.safeAreaLayoutGuide).offset(100)
        }
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            make.right.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.width.height.equalTo(25)
        }
        closeButton.imageView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setNavigationBar() {
        navigationController?.navigationBar.tintColor = .white
    }
}
