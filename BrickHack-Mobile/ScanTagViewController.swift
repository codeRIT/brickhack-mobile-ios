//
//  ScanTagViewController.swift
//  BrickHack-Mobile
//
//  Created by Christopher Baudouin, Jr. on 11/16/18.
//  Copyright © 2018 codeRIT. All rights reserved.
//

import UIKit
import CoreNFC

class ScanTagViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    
    let reuseIdentifier = "reuseIdentifier"
    var session: NFCNDEFReaderSession?
    
    var detectedAttendees = [NFCNDEFMessage]() // Array of attendee ID's
    var tags = [String]() // Available tags pulled from back-end will be stored here
    @IBOutlet weak var labelCurrentTag: UILabel! // Current tag selected label
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// - TODO: Pull fresh list of available tags from back-end
    }
    
    @IBAction func scanButtonWasPressed(_ sender: Any) {
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold the top of your iPhone near the wristband to scan."
        session?.begin()
    }
    
    @IBAction func changeTagButtonWasPressed(_ sender: Any) {
        let tagPicker = UIPickerView()
        tagPicker.delegate = self
        labelCurrentTag.inputView = tagPicker
    }
    
    /// - Tag: processingTagData
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            // Process detected NFCNDEFMessage objects.
            self.detectedAttendees.append(contentsOf: messages)
            //self.tableView.reloadData()
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
    }
    
}

// Class extension for tag picker-related funtions
extension ScanTagViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        <#code#>
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        <#code#>
    }
    
    
}
