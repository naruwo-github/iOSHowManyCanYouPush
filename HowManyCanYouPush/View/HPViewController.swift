//
//  HPViewController.swift
//  HowManyCanYouPush
//
//  Created by Narumi Nogawa on 2020/11/03.
//

import GoogleMobileAds

import AppTrackingTransparency
import AVFoundation
import UIKit
import GameKit

// MARK: - スタート画面＝PUSHボタン画面クラス
class HPViewController: UIViewController, GADBannerViewDelegate/*, GADInterstitialDelegate*/ {

    private let gameHelper = HPGameCenterHelper()
    private let TOP_BANNER_ID = "ca-app-pub-6492692627915720/4410584383"
    private let BOTTOM_BANNER_ID = "ca-app-pub-6492692627915720/1570714342"
    
    private var interstitial: GADInterstitialAd?
    private let INTERSTITIAL_ID = "ca-app-pub-6492692627915720/8211310163"
    private let interstitialKey = "showInterstitialCounter"
    
    @IBOutlet private weak var topAdView: GADBannerView!
    @IBOutlet private weak var countDownLabel: UILabel!
    @IBOutlet private weak var countingLabel: UILabel!
    @IBOutlet private weak var highScoreLabel: UILabel!
    @IBOutlet private weak var rankingButton: UIButton!
    @IBOutlet private weak var pushButton: UIButton!
    @IBOutlet private weak var bottomAdView: GADBannerView!
    
    private var countDownTime: Float = 10.0
    private var tappedCount: Int = 0
    private var countRunningFlag = false
    private var timerFunction: Timer?
    private var soundID: SystemSoundID = 1104
    
    // MARK: - ライフサイクル
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupAd()
        self.loadBannerAd()
        
        self.setupLabels()
        self.setupButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.gameHelper.authenticateLocalPlayer(_self: self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { _ in })
        }
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { _ in
            self.loadBannerAd()
        })
    }

    // MARK: - イベント
    
    @IBAction private func pushButtonTapped(_ sender: Any) {
        self.playTappedSound()
        
        if !self.countRunningFlag {
            self.countRunningFlag = true
            self.timerFunction = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(timer), userInfo: nil, repeats: true)
        }
        
        if self.countRunningFlag {
            if self.countDownTime > 0 {
                self.tappedCount += 1
                self.countingLabel.text = self.tappedCount.description
                // 残り5秒未満になったらタップ数を？にする
                if self.countDownTime < 5.0 {
                    self.countingLabel.text = "?"
                }
            }
        }
    }
    
    @IBAction private func rankingButtonTapped(_ sender: Any) {
        self.gameHelper.showRanking(_self: self)
    }
    // MARK: - プライベート関数
    
    @objc private func timer() {
        if self.countDownTime > 0.0 {
            self.countDownTime -= 0.1
            let time = String(format: "%.1f", abs(self.countDownTime))
            self.countDownLabel.text = time.description
        } else {
            self.timerFunction?.invalidate()
            self.countRunningFlag = false
            
            guard let resultVC = R.storyboard.main.hpResultModalViewController() else { return }
            resultVC.setup(count: self.tappedCount, completion: { [unowned self] in
                self.setupLabels()
                self.showInterstitialAd()
            })
            self.present(resultVC, animated: true, completion: nil)
        }
    }
    
    private func setupAd() {
        self.topAdView.adUnitID = self.TOP_BANNER_ID
        self.topAdView.rootViewController = self
        self.bottomAdView.adUnitID = self.BOTTOM_BANNER_ID
        self.bottomAdView.rootViewController = self
        
        GADInterstitialAd.load(withAdUnitID: self.INTERSTITIAL_ID,
                               request: GADRequest(),
                               completionHandler: { [self] ad, error in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                self.interstitial = ad
                               }
        )
    }
    
    private func showInterstitialAd() {
        let counter = UserDefaults.standard.integer(forKey: self.interstitialKey)
        if counter == 5 {
            UserDefaults.standard.set(0, forKey: self.interstitialKey)
            if self.interstitial != nil {
                self.interstitial!.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
        } else {
            UserDefaults.standard.set(counter + 1, forKey: self.interstitialKey)
        }
    }
    
    private func loadBannerAd() {
        let frame = { () -> CGRect in
            return view.frame.inset(by: view.safeAreaInsets)
        }()
        let viewWidth = frame.size.width
        self.topAdView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        self.topAdView.load(GADRequest())
        self.bottomAdView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        self.bottomAdView.load(GADRequest())
    }

    private func setupLabels() {
        self.countDownTime = 10.0
        self.countDownLabel.text = countDownTime.description
        self.countDownLabel.font = UIDevice.current.userInterfaceIdiom == .pad
            ? UIFont.systemFont(ofSize: 130) : UIFont.systemFont(ofSize: 65)
        self.tappedCount = 0
        self.countingLabel.text = tappedCount.description
        self.countingLabel.font = UIDevice.current.userInterfaceIdiom == .pad
            ? UIFont.systemFont(ofSize: 440) : UIFont.systemFont(ofSize: 220)
        self.highScoreLabel.text = "High Score: \(HPUserHelper.bestScore)"
        self.highScoreLabel.font = UIDevice.current.userInterfaceIdiom == .pad
            ? UIFont.systemFont(ofSize: 40) : UIFont.systemFont(ofSize: 20)
    }
    
    private func setupButton() {
        let buttonSideLength = self.pushButton.frame.width
        self.pushButton.layer.cornerRadius = buttonSideLength / 2.0
        self.pushButton.clipsToBounds = false
        self.pushButton.layer.masksToBounds = false
        self.pushButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.pushButton.layer.shadowColor = UIColor.black.cgColor
        self.pushButton.layer.shadowRadius = 4.0
        self.pushButton.layer.shadowOpacity = 0.4
        
        let buttonSideHeight = self.rankingButton.frame.height
        self.rankingButton.layer.cornerRadius = buttonSideHeight / 2.0
        self.rankingButton.clipsToBounds = false
        self.rankingButton.layer.masksToBounds = false
        self.rankingButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        self.rankingButton.layer.shadowColor = UIColor.black.cgColor
        self.rankingButton.layer.shadowRadius = 4.0
        self.rankingButton.layer.shadowOpacity = 0.4
    }
    
    private func playTappedSound() {
        if let soundUrl = CFBundleCopyResourceURL(CFBundleGetMainBundle(), nil, nil, nil) {
            AudioServicesCreateSystemSoundID(soundUrl, &soundID)
            AudioServicesPlaySystemSound(soundID)
        }
    }
    
//    // Tells the delegate an ad request succeeded.
//    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
//      print("interstitialDidReceiveAd")
//    }
//
//    // Tells the delegate an ad request failed.
//    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
//      print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
//    }
//
//    // Tells the delegate that an interstitial will be presented.
//    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
//      print("interstitialWillPresentScreen")
//    }
//
//    // Tells the delegate the interstitial is to be animated off the screen.
//    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
//      print("interstitialWillDismissScreen")
//    }
//
//    // Tells the delegate the interstitial had been animated off the screen.
//    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
//      print("interstitialDidDismissScreen")
//    }
//
//    // Tells the delegate that a user click will open another app
//    // (such as the App Store), backgrounding the current app.
//    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
//      print("interstitialWillLeaveApplication")
//    }
    
}

// MARK: - Game Center画面の関数を扱うための拡張
extension HPViewController: GKGameCenterControllerDelegate {
    
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
    
}
