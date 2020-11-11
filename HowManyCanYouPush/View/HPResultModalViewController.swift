//
//  HPResultModalViewController.swift
//  HowManyCanYouPush
//
//  Created by Narumi Nogawa on 2020/11/03.
//

import UIKit
import Accounts
import GameKit

// MARK: - 結果モーダル画面クラス
class HPResultModalViewController: UIViewController {
    
    private var dismissCompletion: (() -> Void)?
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var centerView: UIView!
    @IBOutlet private weak var updateRecordView: UIView!
    @IBOutlet private weak var tappedCountLabel: UILabel!
    @IBOutlet private weak var preHighScoreLabel: UILabel!
    @IBOutlet private weak var rankingButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    
    private let gameHelper = HPGameCenterHelper()
    private let highScore = UserDefaults.standard.integer(forKey: "score")
    private var tappedCount: Int = 0
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupButton()
        self.setupViewAndLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.gameHelper.authenticateLocalPlayer(_self: self)
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
    
    @IBAction private func rankingButtonTapped(_ sender: Any) {
        self.gameHelper.sendLeaderboard(rate: Int64(self.tappedCount), _self: self)
        self.gameHelper.showRanking(_self: self)
    }
    
    @IBAction private func shareButtonTapped(_ sender: Any) {
        let text = "10秒間に\(self.tappedCount)回プッシュ達成！！！"
        let urlString = "https://www.apple.com/jp/app-store/"
        let image = R.image.appicon_for_share()!
        self.showActivityView(shareText: text, showWebSite: urlString, shareImage: image)
    }
    
    // MARK: - パブリック関数
    
    public func setup(count: Int, completion: @escaping (() -> Void)) {
        self.tappedCount = count
        self.dismissCompletion = completion
    }
    
    // MARK: - プライベート関数
    
    private func setupButton() {
        self.closeButton.layer.cornerRadius = 15
        self.setShadowOnButton(button: self.closeButton)
        
        self.rankingButton.layer.cornerRadius = 25
        self.setShadowOnButton(button: self.rankingButton)
        
        self.shareButton.layer.cornerRadius = 25
        self.setShadowOnButton(button: self.shareButton)
    }
    
    private func setShadowOnButton(button: UIButton) {
        button.clipsToBounds = false
        button.layer.masksToBounds = false
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowRadius = 4.0
        button.layer.shadowOpacity = 0.4
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
    
    private func showActivityView(shareText: String, showWebSite: String, shareImage: UIImage) {
        let websiteURL = NSURL(string: showWebSite)!
        let activityItems = [shareText, websiteURL, shareImage] as [Any]
        // 初期化処理
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // 使用しないアクティビティタイプ
        let excludedActivityTypes = [
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.airDrop,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.copyToPasteboard,
            UIActivity.ActivityType.mail,
            UIActivity.ActivityType.markupAsPDF,
            UIActivity.ActivityType.message,
            UIActivity.ActivityType.openInIBooks,
//            UIActivity.ActivityType.postToFacebook,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToTencentWeibo,
//            UIActivity.ActivityType.postToTwitter,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.saveToCameraRoll
        ]
        activityVC.excludedActivityTypes = excludedActivityTypes
        self.present(activityVC, animated: true, completion: nil)
    }
    
}

extension HPResultModalViewController: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
}
