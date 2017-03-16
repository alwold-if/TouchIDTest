//
//  ViewController.swift
//  TouchIDTest
//
//  Created by Albert Wold on 3/13/17.
//  Copyright © 2017 iFactor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!

    @IBAction func saveButtonTapped(_ sender: Any) {
        do {
            try TouchIDManager.shared.save(username: usernameTextField.text!, password: passwordTextField.text!)
        } catch {
            NSLog("errrr \(error)")
        }
    }

    @IBAction func touchIDButtonTapped(_ sender: Any) {
        if let (username, password) = TouchIDManager.shared.load() {
            let alert = UIAlertController(title: "TouchID", message: "Got \(username) and \(password)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            NSLog("got nothing")
        }
    }
}

