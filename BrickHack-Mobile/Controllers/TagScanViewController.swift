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

class TagScanViewController: UIViewController,
                             UITableViewDelegate, NFCNDEFReaderSessionDelegate,
                             UITableViewDataSource, UserDataHandler {

    // MARK: IBActions and IBOutlets

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

    @IBOutlet weak var scanHistoryTableView: UITableView!

    // MARK: Properties
    var userID: Int!
    var oauthGrant: OAuth2ImplicitGrant!
    var nfcSession: NFCNDEFReaderSession?
    // Scan model
    var scans = [Scan]()


    override func viewDidLoad() {
        super.viewDidLoad()

        scanHistoryTableView.delegate = self
        scanHistoryTableView.dataSource = self

        // Test data for now
        // @FIXME: Remove this when testing real data
        scans.append(Scan(title: "asdf", date: Date.init(timeIntervalSinceNow: 0)))
        scans.append(Scan(title: "asdf2", date: Date.init(timeIntervalSinceNow: 50)))

        // @TODO: Add network support! Grabbing/getting scan data
    }

    // MARK: NFCNDEFReaderSessionDelegate
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // @TODO: this
        // Blocker: tags and scanning capability
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // @TODO: this
        // Blocker: tags and scanning capability
    }

    // MARK: TableView things
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scans.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let scanCell = tableView.dequeueReusableCell(withIdentifier: "scanCell")!

        // Setup the cell with some data
        scanCell.textLabel!.text = scans[indexPath.row].title
        scanCell.detailTextLabel!.text = scans[indexPath.row].date.description
        // @TODO: use date formatter to make it nice and short

        return scanCell
    }


}
