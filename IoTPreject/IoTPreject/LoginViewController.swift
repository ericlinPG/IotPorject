//
//  LoginViewController.swift
//  FaceIdTest
//
//  Created by Eric Lin on 2018/2/19.
//  Copyright © 2018年 Eric Lin. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userNameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var faceIdLoginButton: UIButton!
    @IBOutlet weak var creatButton: UIButton!
    
    //改變狀態列
//    override var preferredStatusBarStyle: UIStatusBarStyle{
//        return .lightContent
//    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.authenticationCompletionHandler(loginStatusNotification:)), name: .MTBiometricAuthenticationNotificationLoginStatus, object: nil)
        
        //呼叫修改登入畫面樣式
        setupLogView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
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
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func signInButton(_ sender: UIButton) {
        if userNameText.text != "" && passwordText.text != ""{
            authService(email: userNameText.text!, password: passwordText.text!)
        }else{
            displayAlert(title: "Sing In Error", message: "Please entry your email and password !")
        }
    }
    
    @IBAction func creatAcount(_ sender: UIButton) {
            if userNameText.text != "" && passwordText.text != ""{
                createUser(email: userNameText.text!, password: passwordText.text!)
                
            }else{
                displayAlert(title: "Opps !!", message: "Please entry your email and password !")
            }
    }
    
    //驗證User 登入
    func authService(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error ) in
            if error != nil{
                let errorString = String(describing: (error! as NSError).userInfo["error_name"]!)
                if errorString ==  "ERROR_USER_NOT_FOUND"{
                    self.displayAlert(title: "Opps !!", message: "找不到使用者，請先建立帳號！")
                    self.loginButton.isHidden  = true
                }else{
                    self.displayAlert(title: "Sign In Error", message: error!.localizedDescription)
                }
            }else{
                self.onLoginSuccess()
            }
        }
    }
    
    //新增使用者
    func createUser(email: String, password: String){
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil{
                self.displayAlert(title: "建立帳號錯誤", message: error!.localizedDescription)
            }else{
                 self.onLoginSuccess()
            }
        }
    }
    
    //Alert 錯誤訊息
    func displayAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func LoginSubmitted(_ sender: Any) {
        authenticateWithBiometric()
    }
    
    //設定登入畫面樣式
    func setupLogView(){
        setCorner(customView: loginButton, radius: 10)
        setCorner(customView: faceIdLoginButton, radius: 10)
        setCorner(customView: creatButton, radius: 10)
        
        setTextField(customTextField: userNameText, iconName: "username")
        setTextField(customTextField: passwordText, iconName: "password")
        
        self.creatButton.layer.borderWidth = 2.0
        self.creatButton.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
    }
    
    //設定TextField、Button圓角
    func setCorner(customView: UIView, radius: CGFloat) {
        customView.layer.cornerRadius = radius
        customView.clipsToBounds = true
    }
    //設定TextField左邊圖示
    func setTextField(customTextField: UITextField, iconName: String) {
        customTextField.leftViewMode = UITextFieldViewMode.always
        
        var iconView = UIImageView()
        iconView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 20))
        iconView.contentMode = UIViewContentMode.scaleAspectFit
        iconView.image = UIImage(named: iconName)
        
        customTextField.leftView = iconView
        customTextField.layer.borderWidth = 1
        customTextField.layer.borderColor = #colorLiteral(red: 0.8374180198, green: 0.8374378085, blue: 0.8374271393, alpha: 1)
    }
    
    @objc func authenticationCompletionHandler(loginStatusNotification: Notification) {
        if let _ = loginStatusNotification.object as? MTBiometricAuthentication, let userInfo = loginStatusNotification.userInfo {
            if let authStatus = userInfo[MTBiometricAuthentication.status] as? MTBiomericAuthenticationStatus {
                if authStatus.success {
                    print("Login Success")
                    DispatchQueue.main.async {
                        self.onLoginSuccess()
                    }
                } else {
                    if let errorCode = authStatus.errorCode {
                        print("Login Fail with code \(String(describing: errorCode)) reason \(authStatus.errorMessage)")
                        DispatchQueue.main.async {
                            self.onLoginFail()
                        }
                        
                    }
                }
            }
        }
    }
    
    func onLoginSuccess() {
       // performSegue(withIdentifier: "goHome", sender: self)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "Home") as! UITabBarController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }
    
    func onLoginFail() {
        let alert = UIAlertController(title: "Login", message: "Login Failed", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func authenticateWithBiometric() {
        let bioAuth = MTBiometricAuthentication()
        bioAuth.reasonString = "To login into the app"
        bioAuth.authenticationWithBiometricID()
    }

}
