//
//  MTBiometricAuthentication.swift
//  MTFaceIdAuthentication
//
//  Created by SA on 11/4/17.
//  Copyright © 2017 sriscode. All rights reserved.
//

import Foundation
import LocalAuthentication

extension Notification.Name {
    static let MTBiometricAuthenticationNotificationLoginStatus = Notification.Name("LoginStatus")
}

struct MTBiomericAuthenticationStatus {
    var success = false
    var errorCode: Int?
    var errorMessage = ""
    
    mutating func setLoginSuccess() {
        self.success = true
    }
    
    mutating func setLoginFail(errorCode: Int, errorMessage: String) {
        self.success = false
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}

class MTBiometricAuthentication {
    
    var authStatus =  MTBiomericAuthenticationStatus()
    //reasonString is prompted to user for login with touchid
    var reasonString = "For bio auth"
    static let status = "status"
    
    func authenticationWithBiometricID() {
        let localAuthenticationContext = LAContext()
        localAuthenticationContext.localizedFallbackTitle = "Use Passcode"
        
        var authError: NSError?
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reasonString) { success, error in
                
                if success {
                    self.authStatus.setLoginSuccess()
                    self.postNotification(userInfo: [MTBiometricAuthentication.status : self.authStatus])
                    
                } else {
                    guard let error = error else {
                        return
                    }
                    let errorMessage = self.errorMessageForFails(errorCode: error._code)
                    self.authStatus.setLoginFail(errorCode: error._code, errorMessage: errorMessage)
                    self.postNotification(userInfo: [MTBiometricAuthentication.status : self.authStatus])
                }
            }
        } else {
            
            guard let error = authError else {
                return
            }
            let errorMessage = self.errorMessageForFails(errorCode: error._code)
            self.authStatus.setLoginFail(errorCode: error._code, errorMessage: errorMessage)
            self.postNotification(userInfo: [MTBiometricAuthentication.status : self.authStatus])
        }
    }
    
    
    func errorMessageForFailsDeprecatediniOS11(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
               message = "unknown error"
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "身份驗證不成功，因為失敗的觸摸ID嘗試失敗太多，現在Touch ID被鎖定。需要密碼才能解鎖Touch ID"
            case LAError.touchIDNotAvailable.rawValue:
                message = "身份驗證無法啟動，因為設備上的Touch ID不可用"
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "身份驗證無法啟動，因為Touch ID未在設備上註冊"
            default :
                message = "unknown error"
            }
        }
        
        return message
    }
    
    func errorMessageForFails(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
        case LAError.authenticationFailed.rawValue:
            message = "身份驗證不成功，因為用戶未能提供有效的憑據"
            
        case LAError.appCancel.rawValue:
            message = "應用程序已取消身份驗證"
            
        case LAError.invalidContext.rawValue:
            message = "此呼叫已無效"
            
        case LAError.notInteractive.rawValue:
            message = "Authentication failed, because it would require showing UI which has been forbidden by using interactionNotAllowed property"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Authentication could not start, because passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was canceled by system"
            
        case LAError.userCancel.rawValue:
            message = "Authentication was canceled by user"
            
        case LAError.userFallback.rawValue:
            message = "Authentication was canceled, because the user tapped the fallback button"
       
        case LAError.biometryNotAvailable.rawValue:
            message = "Authentication could not start, because biometry is not available on the device"
            
        case LAError.biometryLockout.rawValue:
            message = "Authentication was not successful, because there were too many failed biometry attempts and                          biometry is now locked"
            
        case LAError.biometryNotEnrolled.rawValue:
            message = "Authentication could not start, because biometric authentication is not enrolled"
    
        default:
            message = self.errorMessageForFailsDeprecatediniOS11(errorCode: errorCode)
        }

        return message
    }
   
    func postNotification(userInfo: [String: MTBiomericAuthenticationStatus]) {
          NotificationCenter.default.post(name: .MTBiometricAuthenticationNotificationLoginStatus, object: self, userInfo: userInfo)
    }
    
    
}
