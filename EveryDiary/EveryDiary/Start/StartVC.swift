//
//  StartVC.swift
//  EveryDiary
//
//  Created by Dahlia on 3/13/24.
//

import UIKit

import SnapKit
import FirebaseAuth

class StartVC: UIViewController {
    
    private var pageVC : PageVC!
    
    private var currentPageIndex : Int = 0
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.currentPageIndicatorTintColor = .mainTheme
        control.pageIndicatorTintColor = .subBackground
        return control
    }()
    
    private lazy var startButton : UIButton = {
        let button = UIButton()
        button.setTitle("다음", for: .normal)
        button.layer.backgroundColor = UIColor(named: "loginBackground")?.cgColor
        button.setTitleColor(.mainCell, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.shadowOpacity = 0.1
        button.layer.shadowColor = UIColor(named: "mainTheme")?.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 0)
        button.layer.shadowRadius = 3
        button.addTarget(self, action: #selector(startButtonTouchOutside), for: .touchUpInside)
        button.addTarget(self, action: #selector(startButtonTouchDown), for: .touchDown)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainCell
        
        addSubViewsStartVC()
        autoLayoutStartVC()
        
        print("\(String(describing: pageVC))")
    }
    
    @objc private func startButtonTouchOutside() {
        startButton.layer.backgroundColor = UIColor(named: "loginBackground")?.cgColor
        if currentPageIndex < pageVC.pages.count - 1 {
            moveToNextPage()
        } else {
            UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
            signOut()
            showMainScreen()
        }
    }
    
    @objc private func startButtonTouchDown() {
        startButton.layer.backgroundColor = UIColor(named: "subBackground")?.cgColor
    }
    
    private func addSubViewsStartVC() {
        if !UserDefaults.standard.bool(forKey: "hasSeenOnboarding") {
            pageVC = PageVC(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            pageVC.delegate = self
            pageControl.numberOfPages = pageVC.pageCount
            
            view.addSubview(startButton)
            addChild(pageVC)
            view.addSubview(pageVC.view)
            view.addSubview(pageControl)
        } else {
            showMainScreen()
        }
    }
    
    private func autoLayoutStartVC(){
        startButton.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.equalTo(view.safeAreaLayoutGuide).offset(-100)
            make.height.equalTo(50)
        }
        pageVC.view.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.top.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.width.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.bottom.equalTo(pageControl.snp.top).offset(16)
        }
        pageControl.snp.makeConstraints { make in
            make.centerX.equalTo(view.safeAreaLayoutGuide)
            make.bottom.equalTo(startButton.snp.top).offset(-16)
            make.width.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    private func updateButtonText() {
        if currentPageIndex < pageVC.pageCount - 1 {
            startButton.setTitle("다음", for: .normal)
        } else {
            startButton.setTitle("시작하기", for: .normal)
        }
    }
    
    private func moveToNextPage() {
        let nextPageIndex = currentPageIndex + 1
        guard nextPageIndex < pageVC.pageCount else { return }
        
        guard let currentViewController = pageVC.viewControllers?.first,
              let nextViewController = pageVC.pageViewController(pageVC, viewControllerAfter: currentViewController) else {
            return
        }
        pageVC.setViewControllers([nextViewController], direction: .forward, animated: true) { completed in
            if completed {
                self.currentPageIndex = nextPageIndex
                self.pageControl.currentPage = self.currentPageIndex
                self.updateButtonText()
            }
        }
    }
    
    private func signOut() {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            if Auth.auth().currentUser == nil {
                print("로그아웃 성공!")
                NotificationCenter.default.post(name: .loginstatusChanged, object: nil)
            } else {
                print("로그아웃 실패!")
            }
        } catch let signOutError as NSError {
            print("Error Signing out:  %@", signOutError)
        }
    }
    
    private func showMainScreen() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension StartVC : UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let currentPage = pageVC?.viewControllers?.first, let currentIndex = pageVC?.pages.firstIndex(of: currentPage) else {
            return
        }
        currentPageIndex = currentIndex
        pageControl.currentPage = currentIndex
        updateButtonText()
    }
}
