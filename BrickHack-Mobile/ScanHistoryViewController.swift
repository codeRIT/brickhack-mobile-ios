//
//  ScanHistoryViewController.swift
//  BrickHack-Mobile
//
//  Created by Christopher Baudouin, Jr. on 1/16/19.
//  Copyright © 2019 codeRIT. All rights reserved.
//

import UIKit
import OAuth2
import Alamofire

final class ScanHistoryViewController: UIViewController {

    var oauth2: OAuth2ImplicitGrant?
    var sessionManager: SessionManager?
    var scanHistory: [TrackableEvent] = []
    var currentUser: Int?
    var loadingView: UIAlertController?
    var tags: [Int:String] = [:]
    
    @IBOutlet weak var scanHistoryTable: UITableView!
    
    // Presents a loading message to user when getting tags from environment
    override func viewDidLoad() {
        if(hasInternetAccess()){
            loadingView = UIAlertController(title: nil, message: "Loading scans...", preferredStyle: UIAlertController.Style.alert)
            
            let spinner = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            spinner.hidesWhenStopped = true
            spinner.style = UIActivityIndicatorView.Style.gray
            spinner.startAnimating()
            loadingView!.view.addSubview(spinner)
            present(loadingView!, animated: true, completion: nil)
            
            sessionManager = SessionManager()
            let retrier = OAuth2RetryHandler(oauth2: oauth2!)
            sessionManager!.adapter = retrier
            sessionManager!.retrier = retrier
            sessionManager!.request(currentUserRoute).validate().responseJSON{ response in
                let _  = self.sessionManager
                let dict = response.result.value as? [String: Any]
                self.currentUser = dict?["resource_owner_id"] as? Int ?? 0
                self.getTagHistory()
            }
        }else{
            self.displayNoNetworkAlert()
            _ = self.navigationController?.popViewController(animated: true)
        }
        super.viewDidLoad()
    }
    
    // As AlamoFire is asynchronous, a function is needed to continue the data retrieval process
    func getTagHistory(){
        let usersTags = "\(trackableEventsRouteByUserRoute)\(currentUser!)"
        
        sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2!)
        sessionManager!.adapter = retrier
        sessionManager!.retrier = retrier
        sessionManager!.request(usersTags).validate().responseJSON{ response in
            let _  = self.sessionManager
            let dict = response.result.value as? Array<[String: Any]> ?? [[:]]

            if(dict.count > 0){ // Case where there are no scans
                for i in 0...(dict.count-1){
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                    
                    let bandID = dict[i]["band_id"] as? String ?? ""
                    let createdAt = dateFormatter.date(from: dict[i]["created_at"] as? String ?? "")
                    let id = dict[i]["id"] as? Int ?? 0
                    let trackableTagID = dict[i]["trackable_tag_id"] as! Int
                    let user_id = self.currentUser!
                    let updatedAt = dateFormatter.date(from: dict[i]["updated_at"] as? String ?? "")
                    
                    let trackableEvent = TrackableEvent(bandID: bandID, createdAt: createdAt!, id: id, trackableTagID: trackableTagID, userID: user_id, updatedAt: updatedAt!)
                    self.scanHistory.append(trackableEvent)
                }
                self.getTagData()
            }else{
                self.loadingView!.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    // As AlamoFire is asynchronous, a function is needed to continue the data retrieval process
    func getTagData(){
        sessionManager = SessionManager()
        let retrier = OAuth2RetryHandler(oauth2: oauth2!)
        sessionManager!.adapter = retrier
        sessionManager!.retrier = retrier
        sessionManager!.request(trackableTagsRoute).validate().responseJSON{ response in
            let _  = self.sessionManager
            let dict = response.result.value as! Array<[String: Any]>
            for i in 0...(dict.count-1){
                let id = dict[i]["id"] as? Int ?? 0
                let name = dict[i]["name"] as? String ?? ""
                self.tags[id] = name
            }
            self.scanHistory = self.scanHistory.sorted(by: {$0.createdAt > $1.createdAt})
            self.scanHistoryTable.delegate = self
            self.scanHistoryTable.dataSource = self
            self.scanHistoryTable.reloadData()
            self.loadingView!.dismiss(animated: false, completion: nil)
        }
    }
    
    // Used to determine if the device currently has access to the internet and can establish a connection to the environment
    func hasInternetAccess() -> Bool{
        if networkReachabilityManager?.isReachable ?? false{
            return true
        }else{
            return false
        }
    }
    
    // Displays a network issue alert if device isn't connected to the internet or can't connect to environment
    func displayNoNetworkAlert(){
        let alertController = UIAlertController(
            title: "Network Issue",
            message: "An issue occured with your network. Please be sure you are connected to the internet.",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

// Class extension for UITableView related functions
extension ScanHistoryViewController: UITableViewDataSource, UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scanHistory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let trackableEvent = scanHistory[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TrackableEventCell") as! TrackableEventCell
        cell.setTrackableEventData(label: tags[trackableEvent.trackableTagID] ?? "Deleted Tag", updatedAt: trackableEvent.updatedAt)
        return cell
    }
}
