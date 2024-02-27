//
//  MainVC.swift
//  EveryDiary
//
//  Created by t2023-m0044 on 2/21/24.
//

import UIKit

import Firebase
import FirebaseFirestore
import SnapKit

class DiaryListVC: UIViewController {
//    private lazy var magnifyingButton : UIBarButtonItem = {
//        let button = UIBarButtonItem(title: "돋보기",image: UIImage(named: "search"), target: self, action: #selector(tabSettingBTN))
//        return button
//    }()
    private var diaryManager = DiaryManager()
    private var monthlyDiaries: [String: [DiaryEntry]] = [:]
    private var months: [String] = []
    private var diaries: [DiaryEntry] = []
    
    private lazy var themeLabel : UILabel = {
        let label = UILabel()
        label.text = "하루일기"
        label.font = UIFont(name: "SFProDisplay-Bold", size: 33)
        label.textColor = UIColor(named: "theme")
        return label
    }()
    
    private lazy var searchBar: UISearchBar = {
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width - 130
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: width, height: 0))
        searchBar.tintColor = .green
        searchBar.placeholder = "찾고싶은 일기를 검색하세요."
        return searchBar
    }()
    
    private lazy var magnifyingButton = setNavigationItem(
        imageNamed: "search",
        titleText: "돋보기",
        for: #selector(magnifyingButtonTapped)
    )
    private lazy var settingButton = setNavigationItem(
        imageNamed: "setting",
        titleText: "세팅뷰 이동",
        for: #selector(tabSettingBTN)
    )
    private lazy var cancelButton = setNavigationItem(
        imageNamed: "",
        titleText: "취소",
        for: #selector(cancelButtonTapped)
    )
    
    private lazy var writeDiaryButton : UIButton = {
        var config = UIButton.Configuration.plain()
        let button = UIButton(configuration: config)
        button.setImage(UIImage(named: "write"), for: .normal)
        button.addTarget(self, action: #selector(tabWriteDiaryBTN), for: .touchUpInside)
        return button
    }()
    
    private lazy var journalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 20, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.layer.cornerRadius = 0
        collectionView.backgroundColor = .clear
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "background")
        addSubviewsCalendarVC()
        autoLayoutCalendarVC()
        setNavigationBar()
        journalCollectionView.dataSource = self
        journalCollectionView.delegate = self
        journalCollectionView.register(JournalCollectionViewCell.self, forCellWithReuseIdentifier: JournalCollectionViewCell.reuseIdentifier)
            journalCollectionView.register(HeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderView.reuseIdentifier)
        loadDiaries()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("monthlyDiaries : \(monthlyDiaries)")
    }
}

// MARK: Functions in DiaryListVC
extension DiaryListVC {
    // searchBar 설정 및 searchButtonTapped 전까지 hidden처리.
    private func setNavigationBar() {
        searchBar.becomeFirstResponder()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem?.isHidden = true
        self.navigationItem.rightBarButtonItems = [settingButton, magnifyingButton]
        self.navigationController?.navigationBar.tintColor = UIColor(named: "Main")
    }
    
    private func setNavigationItem(imageNamed name: String, titleText: String, for action: Selector) -> UIBarButtonItem {
        var config = UIButton.Configuration.plain()
        if name == "" {
            config.title = titleText
        } else {
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 15)
            config.image = UIImage(named: name)
        }
        let button = UIButton(configuration: config)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.titleLabel?.font = UIFont(name: "SFProDisplay-Bold", size: 20)
        return UIBarButtonItem(customView: button)
    }
    
    private func loadDiaries() {
        diaryManager.fetchDiaries { [weak self] (diaries, error) in
            guard let self = self else { return }
            if let diaries = diaries {
                print("Fetched diaries : \(diaries)")
                // 월별로 데이터 분류
                self.organizeDiariesByMonth(diaries: diaries)
                DispatchQueue.main.async {
                    self.journalCollectionView.reloadData()
                }
            } else if let error = error {
                print("Error loading diaries: \(error)")
            }
        }
    }
    private func organizeDiariesByMonth(diaries: [DiaryEntry]) {
        var organizedDiaries: [String: [DiaryEntry]] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM"
        
        diaries.forEach { diary in
            let month = dateFormatter.string(from: diary.date)
            organizedDiaries[month, default: [] ].append(diary)
        }
        self.monthlyDiaries = organizedDiaries
        self.months = organizedDiaries.keys.sorted()
    }
    
    @objc private func magnifyingButtonTapped() {
        themeLabel.isHidden = true
        self.navigationItem.leftBarButtonItem?.isHidden = false
        navigationItem.rightBarButtonItems = [settingButton, cancelButton]
    }
    @objc private func tabSettingBTN() {
        let settingVC = SettingVC()
        settingVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(settingVC, animated: true)
    }
    @objc private func cancelButtonTapped() {
        themeLabel.isHidden = false
        self.navigationItem.leftBarButtonItem?.isHidden = true
        navigationItem.rightBarButtonItems = [settingButton, magnifyingButton]
    }
    @objc private func tabWriteDiaryBTN() {
        let writeDiaryVC = WriteDiaryVC()
        writeDiaryVC.modalPresentationStyle = .automatic
        self.present(writeDiaryVC, animated: true)
    }
}

// MARK: CollectionView 관련 extension
extension DiaryListVC: UICollectionViewDataSource {
    // 섹션 수 반환(월별로 구분)
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // DiaryEntry 배열을 사용하여 월별로 구분된 섹션의 수를 계산
        
//        let months = Set(diaries.map { $0.date.toString(dateFormat: "yyyyMM") })
        print("numberOfSections : \(months.count)")
        
        return months.count
    }
    // 각 섹션 별 아이템 수 반환
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 섹션(월별)에 해당하는 DiaryEntry 수를 반환
//        let sortedDiaries = diaries.sorted { $0.date < $1.date }
//        let sectionMonth = sortedDiaries.map { $0.date.toString(dateFormat: "yyyyMM") }.unique()[section]
//        let count = sortedDiaries.filter { $0.date.toString(dateFormat: "yyyyMM") == sectionMonth }.count
        
        let month = months[section]
        let count = monthlyDiaries[month]?.count ?? 0
        print("numberOfItemsInSection : \(count)")
        return count
      
    private func setNavigationBar() {
        navigationItem.rightBarButtonItem = settingButton
        navigationController?.navigationBar.tintColor = UIColor(named: "theme")
    }
    
    // 셀 구성
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: JournalCollectionViewCell.reuseIdentifier, for: indexPath) as? JournalCollectionViewCell else {
            fatalError("Unable to dequeue JournalCollectionViewCell")
        }
        // 섹션에 맞는 일기 찾기
        let sortedDiaries = diaries.sorted { $0.date < $1.date }
        let sectionMonth = sortedDiaries.map { $0.date.toString(dateFormat: "yyyyMM") }.unique()[indexPath.section]
        let sectionDiaries = sortedDiaries.filter { $0.date.toString(dateFormat: "yyyyMM") == sectionMonth }
        let diary = diaries[indexPath.row]
        
        cell.setJournalCollectionViewCell(
            title: diary.title,
            content: diary.content,
            weather: diary.weather,
            emotion: diary.emotion,
            date: diary.dateString
        )
        print("cell : \(cell)")
        return cell
    }
    
    // 헤더뷰 구성
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderView.reuseIdentifier, for: indexPath) as? HeaderView else {
            fatalError("Invalid view type")
        }
        let month = months[indexPath.section]
        headerView.titleLabel.text = month
        return headerView
    }
}

extension DiaryListVC: UICollectionViewDelegateFlowLayout {
    // 헤더의 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 15)
    }
    // 셀의 크기 설정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = journalCollectionView.bounds.width
        let height = journalCollectionView.bounds.height / 4.2
        return CGSize(width: width, height: height)
    }
}

// MARK: addSubViews, autoLayout
extension DiaryListVC {
    private func addSubviewsDiaryListVC() {
        view.addSubview(themeLabel)
//        view.addSubview(journalCollectionView)
        view.addSubview(writeDiaryButton)
    }
    
    private func autoLayoutDiaryListVC() {
//        journalCollectionView.snp.makeConstraints { make in
//            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
//            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(0)
//            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(16)
//            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-16)
//        }
        writeDiaryButton.snp.makeConstraints { make in
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing).offset(-10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-32)
        }
        themeLabel.snp.makeConstraints { make in
            make.top.equalTo(view).offset(50)
            make.left.equalTo(view).offset(16)
            make.size.equalTo(CGSize(width:120, height: 50))
        }
    }
}

// Date를 확장하여 문자열 변환 메서드 추가
extension Date {
    func toString(dateFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}

// 문자열 배열에서 중복 제거를 위한 확장
extension Array where Element: Equatable {
    func unique() -> [Element] {
        var uniqueValues: [Element] = []
        for item in self {
            if !uniqueValues.contains(item) {
                uniqueValues.append(item)
            }
        }
        return uniqueValues
    }
}

// DateFormatter를 확장하여 문자열에서 Date로 변환하는 메서드 추가
extension DateFormatter {
    func date(from string: String, withFormat format: String) -> Date? {
        self.dateFormat = format
        return self.date(from: string)
    }
}
