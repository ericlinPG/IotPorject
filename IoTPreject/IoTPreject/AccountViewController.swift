//
//  LogoutViewController.swift
//  IoTPreject
//
//  Created by Eric Lin on 2018/2/28.
//  Copyright © 2018年 Eric Lin. All rights reserved.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {
    
    var name: String?
    
    
    @IBOutlet weak var chgPassword: UITextField!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var logOutBtn: UIButton!
    
    @IBOutlet weak var delBtn: UIButton!
    @IBOutlet weak var chgBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInfo()
        setupLogView()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //點選空白處讓鍵盤消失
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    //點選return讓鍵盤消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    //設定畫面樣式
    func setupLogView(){
        setCorner(customView: logOutBtn, radius: 10)
        setCorner(customView: delBtn, radius: 10)
        setCorner(customView: chgBtn, radius: 10)
    }
    
    //設定TextField、Button圓角
    func setCorner(customView: UIView, radius: CGFloat) {
        customView.layer.cornerRadius = radius
        customView.clipsToBounds = true
    }
    
    //取得user info
    func userInfo() {
        if Auth.auth().currentUser != nil{
            let user = Auth.auth().currentUser
            if let user = user{
                let name = user.email
                userNameLabel.text = name
            }
        }else{
            userNameLabel.text = "Admin User "
            chgPassword.isEnabled = false
            chgPassword.isSecureTextEntry = false
            chgPassword.text = "無法修改密碼！"
            chgBtn.isHidden = true
            delBtn.isHidden = true
        }
    }
    //修改密碼
    func changePassword(password: String) {
        if password != ""{
            Auth.auth().currentUser?.updatePassword(to: password, completion: { (error) in
                if error != nil{
                    self.displayAlert(title: "錯誤", message: error!.localizedDescription)
                }else{
                    self.displayAlert(title: "修改完成", message: "下次登入請使用新的密碼登入，謝謝！")
                }
            })
        }
    }
    
    //Alert 錯誤訊息
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //登出帳號
    func logOut() {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                let loginVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
                present(loginVc, animated: true, completion: nil)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }else{
            //如果是用生物辨識登入
            let loginVc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
            present(loginVc, animated: true, completion: nil)
        }
    }
    
    @IBAction func logOutButton(_ sender: UIButton) {
        logOut()
    }
    
    @IBAction func changePassword(_ sender: UIButton) {
            if let chgPwd = chgPassword.text{
                changePassword(password: chgPwd)
            }
    }
    
    @IBAction func delAccountButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Warning", message: "此帳號即將刪除，如需使用請重新申請！", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "確定", style: .destructive) { (action: UIAlertAction) -> Void in
            let user = Auth.auth().currentUser
            user?.delete(completion: { (error) in
                if error != nil{
                    self.displayAlert(title: "錯誤", message: error!.localizedDescription)
                }else{
                    print("Delete OK!")
                    self.logOut()
                }
            })
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

