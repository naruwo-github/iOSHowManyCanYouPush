//
//  HPResultModalViewController.swift
//  HowManyCanYouPush
//
//  Created by Narumi Nogawa on 2020/11/03.
//

import UIKit

// MARK: - 結果モーダル画面クラス
class HPResultModalViewController: UIViewController {
    
    private var dismissCompletion: (() -> Void)?
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var centerView: UIView!
    @IBOutlet private weak var updateRecordView: UIView!
    @IBOutlet private weak var tappedCountLabel: UILabel!
    @IBOutlet private weak var preHighScoreLabel: UILabel!
    
    private var tappedCount: Int = 0
    private let highScore = UserDefaults.standard.integer(forKey: "score")
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupButton()
        self.setupViewAndLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.saveHighScoreAndShowAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.dismissCompletion?()
    }
    
    // MARK: - イベント
    
    @IBAction private func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - パブリック関数
    
    public func setup(count: Int, completion: @escaping (() -> Void)) {
        self.tappedCount = count
        self.dismissCompletion = completion
    }
    
    // MARK: - プライベート関数
    
    private func setupButton() {
        self.closeButton.layer.cornerRadius = 15
        self.closeButton.clipsToBounds = false
        self.closeButton.layer.masksToBounds = false
        self.closeButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.closeButton.layer.shadowColor = UIColor.black.cgColor
        self.closeButton.layer.shadowRadius = 4.0
        self.closeButton.layer.shadowOpacity = 0.4
    }
    
    private func setupViewAndLabel() {
        self.centerView.layer.cornerRadius = 10
        
        self.updateRecordView.layer.cornerRadius = 30
        
        self.tappedCountLabel.text = self.tappedCount.description
        
        if self.highScore < self.tappedCount {
            self.preHighScoreLabel.text = "Your best score was \(self.highScore)."
        } else {
            self.preHighScoreLabel.text = "Your best score is \(self.highScore)."
        }
    }
    
    private func saveHighScoreAndShowAnimation() {
        if self.highScore < self.tappedCount {
            self.showUpdateRecordView()
            UserDefaults.standard.set(self.tappedCount, forKey: "score")
        }
    }
    
    private func showUpdateRecordView() {
        self.updateRecordView.alpha = 0.0
        UIView.animate(withDuration: 1.5, delay: 0.0, options: .repeat, animations: {
            self.updateRecordView.alpha = 1.0
        })
    }
    
}
