//
//  LightViewController.swift
//  IoTPreject
//
//  Created by Eric Lin on 2018/2/15.
//  Copyright © 2018年 Eric Lin. All rights reserved.
//

import UIKit
import Firebase

class LightViewController: UIViewController {
    @IBOutlet weak var lightBtn: UIButton!
    
    //宣告資料庫參考
    var relayRef: DatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //建立relayRef的實體，實體是參考Firebase上的節點
        relayRef = Database.database().reference(withPath:  "Relay/D1")
        
        //將節點加入監聽器
        relayRef.observe(.value) { (snapshot: DataSnapshot) in
            //取得Relay/D1節點（值）
            let d1State = snapshot.value as! Bool
            //判斷節點內容值是true還是false來變更圖片，並變更prompt
            if d1State{
                self.navigationItem.prompt = "目前狀態：開啟"
                self.lightBtn.setImage(UIImage.init(named: "open"), for: UIControlState.normal)
            }else{
                self.navigationItem.prompt = "目前狀態：關閉"
                self.lightBtn.setImage(UIImage.init(named: "close"), for: UIControlState.normal)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func userChangeLight(_ sender: UIButton) {
        //當使用者按下Button時改變節點內容值
        relayRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let d1State = snapshot.value as! Bool
            self.relayRef.setValue(!d1State)
        }
    }
}
