//
//  EventController.swift
//  DISPLAYS EVENTS 
//  GameFinder
//
//  Created by Warren Waleed on 10/6/19.
//  Copyright © 2019 Steven Corrales. All rights reserved.
//

import UIKit
import Firebase
import GoogleMobileAds


class EventController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    var cellDetails:String = ""
    var eventArray = [String]()
    
    func LocalNotifications(Title: String, Body: String, Timeint: Date) {
        // Step 1: Ask for Permission
        let center =  UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) {(granted, error) in
            print("granted: \(granted)")
            
        }
        
        // Step 2: Create the notification content
        let content = UNMutableNotificationContent()
        content.title = Title
        content.body = Body
        
        // Step 3: Create the notification trigger
        let date = Timeint
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Step 4: Create the request
        
        let uuidString = UUID().uuidString
        
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        // Step 5: Register the request
        center.add(request) { (error) in
            // Check the error parameter and handle any errors
        }
    }
    
    func showToast(message : String) {

        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 120, y: self.view.frame.size.height - 385, width: 250, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 12.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.5, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "newlogo")
        return iv
    }()
    
    
    
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("JOIN EVENT", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(joinEvent), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("DELETE EVENT", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(deleteEvent), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let unjoinButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("LEAVE EVENT", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.mainBlue(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(unjoinEvent), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()

    // MARK: - Init
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        
        return true
    }
    
    private func parseDate(_ str : String) -> Date {
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MMM d yyyy"
        return dateFormat.date(from: str)!
    }

    var bannerView: GADBannerView!
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
     bannerView.translatesAutoresizingMaskIntoConstraints = false
     view.addSubview(bannerView)
     view.addConstraints(
       [NSLayoutConstraint(item: bannerView,
                           attribute: .bottom,
                           relatedBy: .equal,
                           toItem: bottomLayoutGuide,
                           attribute: .top,
                           multiplier: 1,
                           constant: 0),
        NSLayoutConstraint(item: bannerView,
                           attribute: .centerX,
                           relatedBy: .equal,
                           toItem: view,
                           attribute: .centerX,
                           multiplier: 1,
                           constant: 0)
       ])
    }
    var eDate: String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewComponents()
        // Do any additional setup after loading the view.
        bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        
    }
    
    //preventing rotation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        get {
            return .portrait
        }
    }
    
    // MARK: - Selectors
    
    @objc func deleteEvent() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to delete this event?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Delete Event", style: .destructive, handler: { (_) in
            self.deleteEventFunc()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteEventFunc() {
        let childstr = eventArray[0] + " Created by:" + eventArray[5].split(separator: ":")[1]
        Database.database().reference().child("events").child(childstr).removeValue()
        Database.database().reference().child("joined_events").child(childstr).removeValue()
        handleShowLogin()
        self.showToast(message: "Successfully deleted event")
    }
    
    @objc func joinEvent() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to join this event?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Join Event", style: .destructive, handler: { (_) in
            self.join()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func unjoinEvent() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to leave this event?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Leave Event", style: .destructive, handler: { (_) in
            self.unjoin()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func unjoin() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            guard let username = snapshot.value as? String else { return }
            Database.database().reference().child("joined_events").child(self.cellDetails).child(username).removeValue()
        }
        self.showToast(message: "Successfully left event")
    }
    
    func join() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            guard let username = snapshot.value as? String else { return }
            Database.database().reference().child("joined_events").child(self.cellDetails).setValue([username: uid])
        }
        self.showToast(message: "Successfully joined event")
        
        Database.database().reference().child("events").child(cellDetails).observeSingleEvent(of: .value, with: {
            snapshot in
            
            let delimiter = " Created"
            let eventTitle = snapshot.key.components(separatedBy: delimiter)[0]
            var eventDate = ""
            var eventLoc = ""
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if (snap.key == "Location of event") {
                    eventLoc = "Location: \(snap.value as! String)"
                }
                if (snap.key == "Time of event") {
                    let delimiter = " "
                    let dateString = Array((snap.value as! String).components(separatedBy: delimiter))
                    eventDate = dateString.joined(separator: " ")
                    print("EVENT DATE:     ", eventDate)
                    self.eDate = eventDate
                    print("FIRST EVENT DATE:     ", eventDate.asDate)
                           let modDate = Calendar.current.date(byAdding: .hour, value: -1, to: eventDate.asDate)!
                    let body = "This Event you joined is happening now at " +  eventLoc + "!!"
                    let body2 = "This Event you joined is happening soon at " +  eventLoc + "!!"
                    self.LocalNotifications(Title: eventTitle, Body: body, Timeint: eventDate.asDate)
                    self.LocalNotifications(Title: eventTitle, Body: body2, Timeint: modDate)
                }
            }
        })
    }
    
    @objc func handleShowLogin() {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = mainStoryboard.instantiateViewController(withIdentifier: "tabBar") as! UITabBarController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    // MARK: - API
    
    
    
    // MARK: - Helper Functions
    
    func configureViewComponents() {
        view.backgroundColor = UIColor.mainBlue()
        navigationController?.navigationBar.isHidden = true
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        var eventCreator = ""
        var peopleString = ""
        
        Database.database().reference().child("joined_events").child(cellDetails).observeSingleEvent(of: .value, with: {
            snapshot in
            var count = 1
            for _ in snapshot.children {
                count += 1
            }
            print(count)
            peopleString = "Joined People: \(count)"
        })
        
        Database.database().reference().child("events").child(cellDetails).observeSingleEvent(of: .value, with: {
            snapshot in
            
            let delimiter = " Created"
            let eventTitle = snapshot.key.components(separatedBy: delimiter)[0]
            var eventLoc = ""
            var eventSkill = ""
            var eventDate = ""
            var eventCategory = ""
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                if (snap.key == "Location of event") {
                    eventLoc = "Location: \(snap.value as! String)"
                }
                if (snap.key == "Skill") {
                    eventSkill = "Skill: \(snap.value as! String)"
                }
                if (snap.key == "Category") {
                    eventCategory = "Category: \(snap.value as! String)"
                }
                if (snap.key == "Time of event") {
                    let delimiter = " "
                    let dateString = Array((snap.value as! String).components(separatedBy: delimiter))
                    eventDate = dateString.joined(separator: " ")
                }
                if (snap.key == "Creator") {
                    eventCreator = "Event by: \(snap.value as! String)"
                }
            }
            let eventDateString = "Date: \(eventDate)"
            self.eventArray = [eventTitle, eventLoc, eventSkill, eventDateString, eventCategory, eventCreator, peopleString]
            var yLoc = 180
            for n in 0 ... 6 {
                let label = UILabel(frame: CGRect(x: 40, y: yLoc, width: 350, height: 21))
                label.text = self.eventArray[n]
                label.textColor = UIColor.white
                label.shadowColor = UIColor.black
                label.layer.shadowOffset = CGSize(width: -2, height: -2)
                yLoc = yLoc + 35
                self.view.addSubview(label)
            }
        })
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            guard let username = snapshot.value as? String else { return }
            if (eventCreator == "Event by: " + username) {
                self.view.addSubview(self.deleteButton)
                self.deleteButton.anchor(top: self.logoImageView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 275, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
            } else {
                self.view.addSubview(self.loginButton)
                self.loginButton.anchor(top: self.logoImageView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 275, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
                
                self.view.addSubview(self.unjoinButton)
                self.unjoinButton.anchor(top: self.loginButton.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, paddingTop: 20, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
            
            }
        }
    }
}

extension String {
    /// Returns a date from a string in MMMM dd, yyyy. Will return today's date if input is invalid.
    var asDate: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "E, MMM d yyyy h:mm a"
        return formatter.date(from: self) ?? Date()
    }
}
