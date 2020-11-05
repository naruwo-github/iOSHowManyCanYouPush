//
//  HPViewController.swift
//  HowManyCanYouPush
//
//  Created by Narumi Nogawa on 2020/11/03.
//

import UIKit
import AVFoundation

class HPViewController: UIViewController {

    @IBOutlet private weak var countDownLabel: UILabel!
    @IBOutlet private weak var countingLabel: UILabel!
    @IBOutlet private weak var highScoreLabel: UILabel!
    @IBOutlet private weak var pushButton: UIButton!
    
    private var countDownTime: Float = 10.0
    private var tappedCount: Int = 0
    private var countRunningFlag = false
    private var timerFunction: Timer?
    private var soundID: SystemSoundID = 1104
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupLabels()
        self.setupButton()
    }

    @IBAction private func pushButtonTapped(_ sender: Any) {
        self.playTappedSound()
        
        if !self.countRunningFlag {
            self.countRunningFlag = true
            self.timerFunction = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector:#selector(timer) , userInfo: nil, repeats: true)
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
    
    @objc private func timer() {
        if self.countDownTime > 0.0 {
            self.countDownTime -= 0.1
            let time = String(format: "%.1f", abs(self.countDownTime))
            self.countDownLabel.text = time.description
        } else {
            self.timerFunction?.invalidate()
            self.countRunningFlag = false
            
            let resultVC = self.storyboard?.instantiateViewController(withIdentifier: "HPResultModalViewController") as! HPResultModalViewController
            resultVC.setup(count: self.tappedCount, completion: { [unowned self] in
                self.setupLabels()
            })
            self.present(resultVC, animated: true, completion: nil)
        }
    }
    
    private func setupLabels() {
        self.countDownTime = 10.0
        self.countDownLabel.text = countDownTime.description
        self.tappedCount = 0
        self.countingLabel.text = tappedCount.description
        let highestCount = UserDefaults.standard.integer(forKey: "score")
        self.highScoreLabel.text = "High Score: \(highestCount)"
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
    }
    
    private func playTappedSound() {
        if let soundUrl = CFBundleCopyResourceURL(CFBundleGetMainBundle(), nil, nil, nil) {
            AudioServicesCreateSystemSoundID(soundUrl, &soundID)
            AudioServicesPlaySystemSound(soundID)
        }
    }
    
}

