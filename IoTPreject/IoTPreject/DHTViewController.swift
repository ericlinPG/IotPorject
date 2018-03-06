//
//  DHTViewController.swift
//  IoTPreject
//
//  Created by Eric Lin on 2018/2/18.
//  Copyright © 2018年 Eric Lin. All rights reserved.
//

import UIKit
import Firebase

class DHTViewController: UIViewController {
    
    @IBOutlet weak var CelsiusField: UITextField!
    @IBOutlet weak var CelsiusFieldIndex: UITextField!
    @IBOutlet weak var HumidityField: UITextField!
    
    //建立參考節點
    lazy var DHTref: DatabaseReference! = Database.database().reference(withPath: "DHT")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //建立節點的監聽
        DHTref.observe(.value) { (datasnapshot: DataSnapshot) -> Void in
            if let dhtDict = datasnapshot.value as? [String:String]{
                if self.HumidityField.text != "濕度:\(dhtDict["Humidity"] ?? "不明")"{
                    let newValue = "濕度:\(dhtDict["Humidity"] ?? "不明")"
                    self.delay(targetField: self.HumidityField, changedValue: newValue)
                }
                if self.CelsiusField.text != "攝氏 :\(dhtDict["Celsius"] ?? "不明")"{
                    let newValue = "攝氏 :\(dhtDict["Celsius"] ?? "不明")"
                    self.delay(targetField: self.CelsiusField, changedValue: newValue)
                }
                if self.CelsiusFieldIndex.text != "攝氏指數:\(dhtDict["CelsiusIndex"] ?? "不明")"{
                    let newValue = "攝氏指數:\(dhtDict["CelsiusIndex"] ?? "不明")"
                    self.delay(targetField: self.CelsiusFieldIndex, changedValue:newValue)
                }
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func delay(targetField field:UITextField,changedValue value:String){
        field.textColor = UIColor.red;
        field.text = value;
        
        let when = DispatchTime.now() + 0.5
        DispatchQueue.main.asyncAfter(deadline: when){
            field.textColor = UIColor.black
            field.text = value
        }
    }
    
}
