//
//  HPResultModalViewController.swift
//  HowManyCanYouPush
//
//  Created by Narumi Nogawa on 2020/11/03.
//

import UIKit

class HPResultModalViewController: UIViewController {
    
    private var dismissCompletion: (() -> Void)?
    private var tappedCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.saveHighScore()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.dismissCompletion?()
    }
    
    func setup(count: Int, completion: @escaping (() -> Void)) {
        self.tappedCount = count
        self.dismissCompletion = completion
    }
    
    func setupTappedCount(count: Int) {
        self.tappedCount = count
    }
    
    private func saveHighScore() {
        let highScore = UserDefaults.standard.integer(forKey: "score")
        if highScore < self.tappedCount {
            UserDefaults.standard.set(self.tappedCount, forKey: "score")
        }
    }
    
}
