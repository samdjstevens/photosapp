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
        
        // Remove the text field keyboards when tapping the background
        let tapGesture = UITapGestureRecognizer(target: self, action: "resignTextFieldsAsFirstResponders")
        self.view.addGestureRecognizer(tapGesture)
        
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
        
        // Attempt to retrieve an access token from the API, sending the email and password
        // TODO: Encrypt email and password before send
        let accessTokenRequestData = ["email_address": emailAddressTextField.text!, "password": passwordTextField.text!]
        let accessTokenRequest = PhotosAPIPostRequest(endPoint: "/auth/token", requestData: accessTokenRequestData)
        accessTokenRequest.send { (response: [String: AnyObject]?, error: NSError?) in
            
            
            // Hide the activity spinner
            self.activitySpinner.stopAnimating()
            
            // If there was an error with the request...
            guard error == nil else {
                
                // Clear the password field
                self.passwordTextField.text? = ""
                
                // Re-enable the fields and button
                self.emailAddressTextField.enabled = true
                self.passwordTextField.enabled = true
                self.loginButton.enabled = true
                
                // Check if the error is due to invalid email/password by looking
                // at the error domain and response status code
                if error!.domain == "PhotosAPIResponseError" && error!.code == 403 {
                    
                    // Display an alert informing the user that the combination was invalid
                    return self.displayAlert("Incorrect email/password", message: "That email address and password combination is incorrect.", confirmText: "Try again")
                    
                }
                
                // Otherwise, some other sort of error has occurred on the server
                return self.displayAlert("Unknown Error", message: "Something went wrong, but we don't know what.", confirmText: "Try again")
            }
            
            
            // Successful login! Get our access token to be used to authenticate requests

            // Check that we have an access token returned, displaying an alert if not
            guard let accessToken = response?["access_token"] else {

                // Re-enable the fields and button
                self.emailAddressTextField.enabled = true
                self.passwordTextField.enabled = true
                self.loginButton.enabled = true

                // The response was fine, but we couldnt find the access token in the body...
                return self.displayAlert("Unknown Error", message: "Failed to fetch access token.", confirmText: "Try again")
            }


            // We have an access token. Save to the keychain (TODO) and dismiss the VC
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // Delegate method for the text fields, called when the Return button is pressed.
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        // If the text field is the email address (identified by the tag)
        // then set the password field to be focused and exit
        if textField === emailAddressTextField {
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
    private func resignTextFieldsAsFirstResponders() {
        // Resign all/any first responders in the view
        view.endEditing(true)
    }
    
    // Helper method to display a popup alert, used to indicate something is wrong to the user.
    private func displayAlert(title: String, message: String, confirmText: String) {
        
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
