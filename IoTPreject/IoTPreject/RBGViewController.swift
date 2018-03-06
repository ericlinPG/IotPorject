//
//  RBGViewController.swift
//  IoTPreject
//
//  Created by Eric Lin on 2018/2/15.
//  Copyright © 2018年 Eric Lin. All rights reserved.
//

import UIKit
import Firebase

class RBGViewController: UIViewController {

    @IBOutlet weak var redLabel: UILabel!
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    
    @IBOutlet weak var redSlider: UISlider!
    @IBOutlet weak var greenSlider: UISlider!
    @IBOutlet weak var blueSlider: UISlider!
    
    var rgbRef: DatabaseReference!
    var redValue: Int = 255
    var greenValue: Int = 255
    var blueValue: Int = 255
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //建立rgb節點的參考，並且設定一次監聽，取得R,G,B節點的值
        rgbRef = Database.database().reference(withPath: "RGB")
        rgbRef.observeSingleEvent(of: .value) { (snapshot: DataSnapshot) in
            let rgbValues = snapshot.value as! [String:Float]
            if let r = rgbValues["R"], let g = rgbValues["G"], let b = rgbValues["B"]{
                //依照目前節點中的改變Label值
                self.redLabel.text = "R: \(Int(r))"
                self.greenLabel.text = "G: \(Int(g))"
                self.blueLabel.text = "B: \(Int(b))"
                
                //變更view background Color
                self.view.backgroundColor = UIColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: 1)
                
                //設定Slider初始值
                self.redSlider.value = r
                self.greenSlider.value = g
                self.blueSlider.value = b
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func redSliderChange(_ sender: UISlider) {
        redValue = Int(sender.value)
        redLabel.text = "R: \(redValue)"
        colorChange()
    }
    
    @IBAction func greenSliderChange(_ sender: UISlider) {
        greenValue = Int(sender.value)
        greenLabel.text = "G: \(greenValue)"
        colorChange()
    }
    
    @IBAction func blueSliderChange(_ sender: UISlider) {
        blueValue = Int(sender.value)
        blueLabel.text = "B: \(blueValue)"
        colorChange()
    }
    
    func colorChange() {
        self.rgbRef.setValue(["R": redValue, "G": greenValue, "B": blueValue])
        //改變view背景顏色
        view.backgroundColor = UIColor(red: CGFloat(redValue)/255, green: CGFloat(greenValue)/255, blue: CGFloat(blueValue)/255, alpha: 0.6)
        if redValue == 0, greenValue <= 23, blueValue <= 75{
            redLabel.textColor = UIColor.white
            greenLabel.textColor = UIColor.white
            blueLabel.textColor = UIColor.white
        }else{
            redLabel.textColor = UIColor.black
            greenLabel.textColor = UIColor.black
            blueLabel.textColor = UIColor.black
        }
    }
}
