//
//  HPGameCenterHelper.swift
//  HowManyCanYouPush
//
//  Created by Narumi Nogawa on 2020/11/11.
//

import Foundation
import GameKit

// MARK: - GameCenterの関数を扱うクラス（シングルトン）
final class HPGameCenterHelper {
    
    init() {
    }
    
    // ゲームセンターのログイン処理
    func authenticateLocalPlayer(_self: UIViewController) {
        let player = GKLocalPlayer.local // ログイン確認画面の作成
        player.authenticateHandler = {(viewController, _/*error*/) -> Void in
            // GameCenterに認証されていない時、viewControllerに認証画面が入ってくるので、
            // それを表示させれば認証処理が簡単にできる
            if viewController != nil {
                _self.present(viewController!, animated: true, completion: nil)
            }
        }
    }
    
    // ランキング画面を表示する
    func showRanking(_self: UIViewController, completion: (() -> Void)?) {
        let gcView = GKGameCenterViewController()
        gcView.gameCenterDelegate = _self as? GKGameCenterControllerDelegate
        gcView.viewState = GKGameCenterViewControllerState.leaderboards
        _self.present(gcView, animated: true, completion: completion)
    }
    
    // 最高スコアを送信する
    func sendLeaderboard(_ id: String = "PushALotBoard", rate: Int64, _self: UIViewController) {
        let score = GKScore(leaderboardIdentifier: id)
        if GKLocalPlayer.local.isAuthenticated {
            score.value = rate
            GKScore.report([score], withCompletionHandler: { (error) in
                if error != nil {
                    // GameCenter送信時にエラー
                }
            })
        } else {
            // GameCenterにログインしてない
            self.authenticateLocalPlayer(_self: _self)
        }
    }
    
}
