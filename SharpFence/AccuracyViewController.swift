//
//  AccuracyViewController.swift
//  SharpFence
//
//  Created by bharghava on 1/17/18.
//  Copyright © 2018 Rapid Value. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class AccuracyViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    var list = ["LEVEL 1", "LEVEL 2", "LEVEL 3"]
    var accuracy: AccuracyDataModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.dropDown.delegate = self
        self.dropDown.isHidden = true
        self.hideKeyboardWhenTappedAround()
        self.accuracyLevel.delegate = self
       
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.accuracy = CoreDataWrapper.getConfigAccuracy()
        
        if let level = accuracy?.level, let distance = accuracy?.disFilter, let heading = accuracy?.headFilter {
            
            self.accuracyLevel.text = level
            self.distanceFilter.text = String(distance)
            self.headingFilter.text = String(heading)
        
        }
        
    }

    
    
    @IBOutlet weak var accuracyLevel: UITextField!
    @IBOutlet weak var distanceFilter: UITextField!
    
    @IBOutlet weak var headingFilter: UITextField!
    
    @IBOutlet weak var dropDown: UIPickerView!
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
        
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        
        return list.count
        
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        self.view.endEditing(true)
        return list[row]
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        self.accuracyLevel.text = self.list[row]
        self.dropDown.isHidden = true
        
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == self.accuracyLevel {
            textField.endEditing(true)
            self.dropDown.isHidden = false
        }
        
    }
    
    @IBAction func saveClicked(_ sender: Any) {
        var accuracy: CLLocationAccuracy?
        
        switch self.accuracyLevel.text ?? "" {
            
        case "LEVEL 1":
            accuracy =  kCLLocationAccuracyBestForNavigation
            break
            
        case "LEVEL 2":
            accuracy =  kCLLocationAccuracyBest
            break
            
        case "LEVEL 3":
            accuracy =  kCLLocationAccuracyNearestTenMeters
            break
            
        default:
            accuracy =  kCLLocationAccuracyBest
            break
            
        }
        
       
        
        CoreDataWrapper.saveAccuracyToDB(dataModel: AccuracyDataModel(disFilter: Double(self.distanceFilter.text ?? "0.0") , headFilter: Double(self.headingFilter.text ?? "0.0") , level: self.accuracyLevel.text, accuracy: accuracy))
        self.dismiss(animated: true, completion: nil)

    }
    
        
    
    
    
}
