//
//  FourthViewController.swift
//  GameFinder
//
//  Created by Steven Corrales on 10/2/19.
//  Copyright © 2019 Steven Corrales. All rights reserved.
//

import UIKit
import SimpleCheckbox
import Firebase

class FourthViewController: UIViewController, UITextFieldDelegate {
    var subscriptions = [String: Bool]()
    var checkboxes = [String: Checkbox]()
    var requestGameText : UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = UILabel(frame: CGRect(x: 0, y: 50, width: 300, height: 30))
        title.textAlignment = .center
        title.text = "Subscriptions"
        title.center.x = view.center.x
        view.addSubview(title)
        addCheckboxSubviews()
        authenticateUserAndConfigureView()
        
        let logo = UIImage(named: "GameFinder3.png")
        let imageView = UIImageView(image:logo)
        self.navigationItem.titleView = imageView
    }
    
    func addCheckboxSubviews() {
        let xLoc = 50
        var yLoc = 165
        guard let uid = Auth.auth().currentUser?.uid else { return }
    
        Database.database().reference().child("game_types").observeSingleEvent(of: .value, with: {
            snapshot in
            
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let tickBox = Checkbox(frame: CGRect(x: xLoc, y: yLoc, width: 25, height: 25))
                let label = UILabel(frame: CGRect(x: xLoc + 40, y: yLoc, width: 200, height: 21))
                label.text = snap.value as! String?
                label.textColor = UIColor.white
                self.checkboxes[label.text!] = tickBox
                tickBox.accessibilityIdentifier = label.text
                tickBox.borderStyle = .square
                tickBox.checkmarkStyle = .tick
                tickBox.checkmarkSize = 0.7
                tickBox.addTarget(self, action: #selector(self.checkboxValueChanged(sender:)), for: .valueChanged)
                self.view.addSubview(tickBox)
                self.view.addSubview(label)
                yLoc = yLoc + 35
            }

        })
        let submitButton = UIButton(frame: CGRect(x: xLoc + 100, y: yLoc + 320, width: 350, height: 40))
        submitButton.backgroundColor = .white
        submitButton.setTitleColor(UIColor.mainBlue(), for: .normal)
        submitButton.center.x = self.view.center.x
        submitButton.setTitle("SUBMIT", for: .normal)
        submitButton.showsTouchWhenHighlighted = true
        submitButton.layer.cornerRadius = 5
        submitButton.addTarget(self, action: #selector(updateSubscriptions), for: .touchUpInside)
        self.view.addSubview(submitButton)
        Database.database().reference().child("users").child(uid).child("subscriptions").observeSingleEvent(of: .value, with: {
            snapshot in
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let text = snap.key
                    self.checkboxes[text]?.isChecked = true
                    self.subscriptions[text] = true
                }
        })
        let requestGameLabel = UILabel(frame: CGRect(x: 50, y: yLoc + 380, width: 300, height: 30))
        requestGameLabel.text = "Request an Activity:"
        requestGameLabel.textColor = UIColor.white
        self.view.addSubview(requestGameLabel)
        requestGameText = UITextField(frame: CGRect(x: 50, y: yLoc + 420, width: 315, height: 30))
        requestGameText.borderStyle = UITextField.BorderStyle.roundedRect
        requestGameText.autocorrectionType = UITextAutocorrectionType.no
        requestGameText.keyboardType = UIKeyboardType.default
        requestGameText.returnKeyType = UIReturnKeyType.done
        requestGameText.clearButtonMode = UITextField.ViewMode.whileEditing
        requestGameText.contentVerticalAlignment = UIControl.ContentVerticalAlignment.center
        requestGameText.placeholder = "Enter an activity"
        self.requestGameText.delegate = self
        self.view.addSubview(requestGameText)
        let gameSubmitButton = UIButton(frame: CGRect(x: xLoc + 100, y: yLoc + 470, width: 350, height: 40))
        gameSubmitButton.backgroundColor = .white
        gameSubmitButton.setTitleColor(UIColor.mainBlue(), for: .normal)
        gameSubmitButton.center.x = self.view.center.x
        gameSubmitButton.layer.cornerRadius = 5
        gameSubmitButton.setTitle("REQUEST", for: .normal)
        gameSubmitButton.showsTouchWhenHighlighted = true
        gameSubmitButton.addTarget(self, action: #selector(requestGame), for: .touchUpInside)
        self.view.addSubview(gameSubmitButton)
    }
    
    @objc func requestGame(sender: UIButton!) {
        let input = self.requestGameText.text!
        Database.database().reference().child("requested_games").updateChildValues([input: input])
        let alert = UIAlertController(title: "Requested Game", message: "Your activity has been requested, and will be reviewed.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            self.requestGameText.text = ""
        }))
        self.present(alert, animated: true)
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.requestGameText.endEditing(true)
        return false
    }

    @objc func checkboxValueChanged(sender: Checkbox) {
        if (sender.isChecked) {
            subscriptions[sender.accessibilityIdentifier!] = true
        } else {
            subscriptions.removeValue(forKey: sender.accessibilityIdentifier!)
        }
    }
    
    @objc func updateSubscriptions(sender: UIButton!) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var children = [String]()
        
        let alert = UIAlertController(title: "Update subscriptions?", message: "Are you sure you want to update your subscriptions?", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            if (self.subscriptions.count > 0) {
                Database.database().reference().child("users").child(uid).updateChildValues(["subscriptions": self.subscriptions])
            } else {
                Database.database().reference().child("users").child(uid).updateChildValues(["subscriptions": "none"])
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
            Database.database().reference().child("users").child(uid).child("subscriptions").observeSingleEvent(of: .value, with: {
                snapshot in
                    for child in snapshot.children {
                        let snap = child as! DataSnapshot
                        let text = snap.key
                        children.append(text)
                    }
                for (key, _) in self.checkboxes {
                    if (children.contains(key)) {
                        self.checkboxes[key]?.isChecked = true
                        self.subscriptions[key] = true
                    } else {
                        self.checkboxes[key]?.isChecked = false
                    }
                }
            })
        }))
        self.present(alert, animated: true)
    }

    

    
    //Sign out Button
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Done Already? ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "SignOut", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleSignOut), for: .touchUpInside)
        return button
    }()
    
    var welcomeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.alpha = 0
        return label
    }()
    
    // MARK: - Init
    
    // MARK: - Selectors
    
    @objc func handleSignOut() {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            self.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    // MARK: - API
    
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("users").child(uid).child("username").observeSingleEvent(of: .value) { (snapshot) in
            guard let username = snapshot.value as? String else { return }
            self.welcomeLabel.text = "Welcome, \(username)"
            
            UIView.animate(withDuration: 0.5, animations: {
                self.welcomeLabel.alpha = 1
            })
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = mainStoryboard.instantiateViewController(withIdentifier: "navcontrol") as! UINavigationController
            UIApplication.shared.keyWindow?.rootViewController = viewController
            
        } catch let error {
            print("Failed to sign out with error..", error)
        }
    }
    
    func authenticateUserAndConfigureView() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let viewController = mainStoryboard.instantiateViewController(withIdentifier: "navcontrol") as! UINavigationController
                UIApplication.shared.keyWindow?.rootViewController = viewController
            }
        } else {
            configureViewComponents()
            loadUserData()
        }
    }
    
    
    
    // MARK: - Helper Functions
    
    func configureViewComponents() {
        //view.backgroundColor = UIColor.mainBlue()
        
        tabBarItem.title = "Misc"
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 32, paddingBottom: 12, paddingRight: 32, width: 0, height: 200)
        
        view.addSubview(welcomeLabel)
        welcomeLabel.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 25, paddingLeft: 90, paddingBottom: 0, paddingRight: 32, width: 0, height: 200)
    }
    
}
    // MARK: - Properties
