//
//  JoinedEventsController.swift
//  GameFinder
//
//  Created by Warren Waleed on 11/18/19.
//  Copyright © 2019 Steven Corrales. All rights reserved.
//

import UIKit
import Firebase

class JoinedEventsController: UIViewController, UITextFieldDelegate {
    override func viewDidLoad() {
           super.viewDidLoad()
           guard let uid = Auth.auth().currentUser?.uid else { return }
        var username = ""
        var eventsList = [String]()
        Database.database().reference().child("users").child(uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            username = (snapshot.value as? String)!
        }
           Database.database().reference().child("joined_events").observeSingleEvent(of: .value, with: {
               snapshot in
               
               for child in snapshot.children {
                   let snap = child as! DataSnapshot
                for c in snap.children {
                    let childsnap = c as! DataSnapshot
                    if (childsnap.key == username) {
                        eventsList.append(snap.key)
                    }
                }
                
               }
               var yLoc = 180
            let title = UILabel(frame: CGRect(x: 125, y: yLoc, width: 350, height: 30))
            title.text = "Joined Events"
            title.textColor = UIColor.white
            yLoc += 50
            self.view.addSubview(title)
            for n in eventsList {
                   let label = UILabel(frame: CGRect(x: 40, y: yLoc, width: 350, height: 21))
                   label.text = n
                   label.textColor = UIColor.white
                   yLoc = yLoc + 35
                   self.view.addSubview(label)
               }
           })
           
       }
}
