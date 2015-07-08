//
//  LoginViewController.swift
//  Photos
//
//  Created by Sam Stevens on 08/07/2015.
//  Copyright © 2015 Sam Stevens. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // The email address field
    @IBOutlet weak var emailAddressTextField: UITextField!
    
    // The password field
    @IBOutlet weak var passwordTextField: UITextField!
    
    // The login button
    @IBOutlet weak var loginButton: UIButton!
    
    // The activity spinner
    @IBOutlet weak var activitySpinner: UIActivityIndicatorView!
    
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Set the text field's delagates to self so we can handle
        // the textFieldShouldReturn method
        emailAddressTextField.delegate = self
        passwordTextField.delegate = self
        
        // Don't show the activity spinner just yet
        activitySpinner.stopAnimating()
    }
    
    // Handler for login button presses, validate and submit the login
    // form
    @IBAction func loginButtonPressed() {
     
        
        // Resign the current text field as first responder, if any
        // are
        resignTextFieldsAsFirstResponders()
        
        // Ensure the email address field is filled in, displaying an alert if not
        guard emailAddressTextField.text?.isEmpty != true else {
            return displayAlert("Whoops!", message: "Please enter your email address.", confirmText: "Got it.")
        }
        
        // Ensure the password field is filled in, displaying an alert if not
        guard passwordTextField.text?.isEmpty != true else {
            return displayAlert("Whoops!", message: "Please enter your password.", confirmText: "Aye, aye.")
        }
        
        // Set the activity to start spinning (which also shows it)
        activitySpinner.startAnimating()
        
        // Disable the two fields and the button
        emailAddressTextField.enabled = false
        passwordTextField.enabled = false
        loginButton.enabled = false
        
        // Dismiss the VC for now
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Delegate method for the text fields, called when the Return button is pressed.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        
        // If the text field is the email address (identified by the tag)
        // then set the password field to be focused and exit
        if textField.tag == 0 {
            return passwordTextField.becomeFirstResponder()
        }
        
        
        // Otherwise, trigger the loginButtonPressed method to simulate
        // submitting the form
        loginButtonPressed()
        
        return true
    }
    
    // Resign the current first responder text field if a text field
    // is currently the first responder. Resigning a text field as first
    // responder puts away the keyboard and defocuses.
    func resignTextFieldsAsFirstResponders() {
        
        // Resign the email address text field if its the first responder
        if emailAddressTextField.isFirstResponder() {
            emailAddressTextField.resignFirstResponder()
        }
        
        // Resign the password text field if its the first responder
        if passwordTextField.isFirstResponder() {
            passwordTextField.resignFirstResponder()
        }
    }
    
    // Helper method to display a popup alert, used to indicate something is wrong to the user.
    func displayAlert(title: String, message: String, confirmText: String) {
        
        // Create a new UIAlertController instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Create an action button for the alert to dismiss it
        let confirmAction = UIAlertAction(title: confirmText, style: UIAlertActionStyle.Default, handler: nil)
        
        // Add the action to the controller
        alertController.addAction(confirmAction)
        
        // Present the view controller
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
