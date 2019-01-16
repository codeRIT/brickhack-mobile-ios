//
//  ScanTagViewController.swift
//  BrickHack-Mobile
//
//  Created by Christopher Baudouin, Jr. on 11/16/18.
//  Copyright © 2018 codeRIT. All rights reserved.
//

import UIKit
import CoreNFC
import OAuth2
import Alamofire
import VYNFCKit

class ScanTagViewController: UIViewController {
    
    var session: NFCNDEFReaderSession?
    var tags: Array<(Int, String)>? // Available tags pulled from back-end will be stored here
    var currentTag: (Int, String)?
    var oauth2: OAuth2ImplicitGrant?
    var sessionManager: SessionManager?
    let tagsAPI = "https://staging.brickhack.io/manage/trackable_tags.json"
    let submitTagAPI = "https://staging.brickhack.io/manage/trackable_events.json"
    @IBOutlet weak var labelCurrentTag: UILabel! // Current tag selected label
    @IBOutlet weak var changeTagTextField: UITextField!
    @IBOutlet weak var scanTagButton: UIButton!
    
    override func viewDidLoad() {
        self.tags = [(-1, "None")]
        
        sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2!)
        sessionManager!.adapter = retrier
        sessionManager!.retrier = retrier
        sessionManager!.request(tagsAPI).validate().responseJSON{ response in
            let _  = self.sessionManager
            let dict = response.result.value as! Array<[String: Any]>
            
            for i in 0...(dict.count-1){
                let name = dict[i]["name"] as! String
                let id = dict[i]["id"] as! Int
                self.tags?.append((id, name))
            }
            
            self.changeTagTextField.isEnabled = true
            self.createTagPicker()
            self.createToolbar()
        }
        if tags == nil{
            changeTagTextField.isEnabled = false
            scanTagButton.isEnabled = false
        }
        self.prepareNFCSession()
        super.viewDidLoad()
    }
    
    func prepareNFCSession(){
        self.session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        self.session?.alertMessage = "Hold the top of your iPhone near the wristband to scan."
    }
}

// Class extension for NFC-related functions
extension ScanTagViewController: NFCNDEFReaderSessionDelegate{
    
    @IBAction func scanButtonWasPressed(_ sender: Any) {
        dismissPicker()
        self.session?.begin()
    }
    
    /// - Tag: processingTagData
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            for message in messages {
                for payload in message.records {
                    guard let parsedPayload = VYNFCNDEFPayloadParser.parse(payload) else {
                        continue
                    }
                    var text = ""
                    if let parsedPayload = parsedPayload as? VYNFCNDEFTextPayload {
                        self.submitTag(bandUID: String(format: "%@%@", text, parsedPayload.text))
                        text = "[Text payload]\n"
                        text = String(format: "%@%@", text, parsedPayload.text)
                        
                    } else {
                        text = "Parsed but unhandled payload type"
                    }
                    NSLog("%@", text)
                }
            }
        }
    }
    
    /// - Tag: endScanning
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a success read
            // during a single tag read mode, or user canceled a multi-tag read mode session
            // from the UI or programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                let alertController = UIAlertController(
                    title: "Scan Error Occurred",
                    message: "An error occurred while scanning, please inform an organizer.",
                    preferredStyle: .alert
                )
                print(error.localizedDescription)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                DispatchQueue.main.async {
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        // A new session instance is required to read new tags.
        self.session = nil
        self.prepareNFCSession()
    }
    
    func submitTag(bandUID:String){
        let retrier = OAuth2RetryHandler(oauth2: self.oauth2!)
        sessionManager!.adapter = retrier
        sessionManager!.retrier = retrier
        let json: [String: [String: Any]] = ["trackable_event": ["band_id":bandUID, "trackable_tag_id":currentTag!.0]]
        sessionManager!.request(submitTagAPI, method: .post, parameters: json, encoding: JSONEncoding.default, headers: ["Content-Type" :"application/json"]).responseJSON(){ response in
            debugPrint(response)
        }
    }
}

// Class extension for tag picker-related funtions
extension ScanTagViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func createTagPicker(){
        let picker = UIPickerView()
        picker.delegate = self
        changeTagTextField.inputView = picker
    }
    
    func createToolbar(){
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let donebutton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(ScanTagViewController.dismissPicker))
        
        toolBar.setItems([donebutton], animated: true)
        toolBar.isUserInteractionEnabled = true
        changeTagTextField.inputAccessoryView = toolBar
    }
    
    @objc func dismissPicker(){
        view.endEditing(true)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return (self.tags?.count)!
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.tags?[row].1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentTag = tags?[row]
        labelCurrentTag.text = tags?[row].1
        
        if(row == 0){
            scanTagButton.isEnabled = false
        }else{
            scanTagButton.isEnabled = true
        }
    }
}
