//
//  TagScanViewController.swift
//  BrickHack-Mobile
//
//  Created by Peter Kos on 11/1/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import p2_OAuth2
import CoreNFC

class TagScanViewController: UIViewController, UserDataHandler, NFCNDEFReaderSessionDelegate {
    
    @IBAction func startScan(_ sender: Any) {

        // Check if scanning available
        guard NFCNDEFReaderSession.readingAvailable else {
            MessageHandler.showScanningUnsupportedError()
            return
        }

        // Start session
        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        nfcSession!.alertMessage = "Hold your iPhone near your event badge."
        nfcSession!.begin()
    }


    // MARK: Properties
    var userID: Int!
    var oauthGrant: OAuth2ImplicitGrant!
    var nfcSession: NFCNDEFReaderSession?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    // MARK: NFCNDEFReaderSessionDelegate
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // @TODO
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // @TODO
    }


}
