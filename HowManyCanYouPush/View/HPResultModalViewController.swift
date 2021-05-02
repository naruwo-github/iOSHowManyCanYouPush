//
//  HPResultModalViewController.swift
//  HowManyCanYouPush
//
//  Created by Narumi Nogawa on 2020/11/03.
//

import UIKit
import Accounts
import GameKit

import GoogleMobileAds

// MARK: - 結果モーダル画面クラス
class HPResultModalViewController: UIViewController, GADBannerViewDelegate {
    
    private var dismissCompletion: (() -> Void)?
    private let BOTTOM_BANNER_ID = "ca-app-pub-6492692627915720/1570714342"
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var centerView: UIView!
    @IBOutlet private weak var updateRecordView: UIView!
    @IBOutlet private weak var updateRecordLabel: UILabel!
    @IBOutlet private weak var tappedCountLabel: UILabel!
    @IBOutlet private weak var preHighScoreLabel: UILabel!
    @IBOutlet private weak var rankingButton: UIButton!
    @IBOutlet private weak var shareButton: UIButton!
    @IBOutlet private weak var bottomAdView: GADBannerView!
    
    private let gameHelper = HPGameCenterHelper()
    private var tappedCount: Int = 0
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAd()
        
        self.setupButton()
        self.setupViewAndLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.saveHighScoreAndShowAnimation()
        self.loadBannerAd()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let backCount = HPUserHelper.backToInitialFromResultCount
        HPUserHelper.backToInitialFromResultCount = backCount + 1
        self.dismissCompletion?()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.loadBannerAd()
        })
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
        let text = "\(self.tappedCount) pushed in 10 seconds！"
        let urlString = "https://apps.apple.com/pk/app/push-a-lot/id1539802973"
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
        self.updateRecordLabel.font = UIDevice.current.userInterfaceIdiom == .pad
            ? UIFont.systemFont(ofSize: 40) : UIFont.systemFont(ofSize: 20)
        
        self.tappedCountLabel.text = self.tappedCount.description
        self.tappedCountLabel.font = UIDevice.current.userInterfaceIdiom == .pad
            ? UIFont.systemFont(ofSize: 300) : UIFont.systemFont(ofSize: 150)
        
        if HPUserHelper.bestScore < self.tappedCount {
            self.preHighScoreLabel.text = "Your best score was \(HPUserHelper.bestScore)."
        } else {
            self.preHighScoreLabel.text = "Your best score is \(HPUserHelper.bestScore)."
        }
        self.preHighScoreLabel.font = UIDevice.current.userInterfaceIdiom == .pad
            ? UIFont.systemFont(ofSize: 50) : UIFont.systemFont(ofSize: 25)
    }
    
    private func saveHighScoreAndShowAnimation() {
        if HPUserHelper.bestScore < self.tappedCount {
            self.showUpdateRecordView()
            HPUserHelper.bestScore = self.tappedCount
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
    
    private func setupAd() {
        self.bottomAdView.adUnitID = self.BOTTOM_BANNER_ID
        self.bottomAdView.rootViewController = self
    }
    
    private func loadBannerAd() {
        let frame = { () -> CGRect in
            return view.frame.inset(by: view.safeAreaInsets)
        }()
        let viewWidth = frame.size.width
        self.bottomAdView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        self.bottomAdView.load(GADRequest())
    }
    
}

// MARK: - Game Center画面の関数を扱うための拡張
extension HPResultModalViewController: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
}
