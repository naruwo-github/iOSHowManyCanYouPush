//
//  HPResultModalViewController.swift
//  HowManyCanYouPush
//
//  Created by Narumi Nogawa on 2020/11/03.
//

import UIKit

class HPResultModalViewController: UIViewController {
    
    private var dismissCompletion: (() -> Void)?
    
    @IBOutlet private weak var closeButton: UIButton!
    @IBOutlet private weak var centerView: UIView!
    @IBOutlet private weak var updateRecordView: UIView!
    @IBOutlet private weak var tappedCountLabel: UILabel!
    @IBOutlet private weak var preHighScoreLabel: UILabel!
    
    private var tappedCount: Int = 0
    private let highScore = UserDefaults.standard.integer(forKey: "score")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupButton()
        self.setupViewAndLabel()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.saveHighScore()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.dismissCompletion?()
    }
    
    @IBAction private func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    public func setup(count: Int, completion: @escaping (() -> Void)) {
        self.tappedCount = count
        self.dismissCompletion = completion
    }
    
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
        
        self.preHighScoreLabel.text = "Your best score is \(self.highScore)."
    }
    
    private func saveHighScore() {
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
