//
//  LoginViewController.swift
//  LIGChatApp
//
//  Created by Alfonz Montelibano on 4/18/17.
//  Copyright © 2017 alphonsus. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {

	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var signupOrLoginButton: LoaderButton!
	
	var authHandle: FIRAuthStateDidChangeListenerHandle?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		usernameTextField.addTarget(self, action: #selector(usernamePasswordFieldEdited), for: .editingChanged)
		passwordTextField.addTarget(self, action: #selector(usernamePasswordFieldEdited), for: .editingChanged)
		
		// By default, signup/login button is disabled until
		// username and pass fields are not empty
		disableSignupLoginButton()
		
		// Rounded corners for button
		self.signupOrLoginButton.layer.cornerRadius = 5
		
		// Change corner radius for text fields
		usernameTextField.layer.cornerRadius = 5
		passwordTextField.layer.cornerRadius = 5
	}
	
	// Sign in to Firebase account with email and password
	private func attemptSignIn(email: String, password: String) {
		FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
			if user != nil {
				// Login successful
				self.presentChatView()
			} else if error != nil {
				// User not found, alert user to create new account
				let createAccountAlert = UIAlertController(title: "Create Account?", message:"The username or password you entered did not match our records. Would you like to sign up this account?", preferredStyle: .alert)
				
				createAccountAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
					self.enableSignupLoginButton()
					self.signupOrLoginButton.hideLoading()
				}))
				
				
				createAccountAlert.addAction(UIAlertAction(title: "Sign Up", style: .default, handler: { (action: UIAlertAction!) in
					self.attemptCreateAccount(email: email, password: password)
				}))
				
				self.present(createAccountAlert, animated: true, completion: nil)
				
			}
		}
	}
	
	// Create account with email and password
	private func attemptCreateAccount(email: String, password: String) {
		FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
			if user != nil {
				self.presentChatView()
			} else if error != nil {
				var errorMessage: String = ""
				if let errCode = FIRAuthErrorCode(rawValue: error!._code) {
					switch errCode {
					case .errorCodeInvalidEmail:
						errorMessage = "The username you entered contains invalid characters. Please try again."
						
					case .errorCodeEmailAlreadyInUse:
						errorMessage = "The e-mail address is already in use."
						
					case .errorCodeWeakPassword:
						errorMessage = "Please enter a password with at least 6 characters."
						
					default:
						errorMessage = "There was a problem signing up your account. Please try again."
					}
				}
				
				let signupErrorAlert = UIAlertController(title: "Sign Up Unsuccessful", message: errorMessage, preferredStyle: .alert)
				signupErrorAlert.addAction(UIAlertAction(title: "Try Again", style: .cancel, handler: nil))
				self.present(signupErrorAlert, animated: true, completion: nil)
				
				self.enableSignupLoginButton()
				self.signupOrLoginButton.hideLoading()
			}
		})
	}
	
	// MARK: IBActions
	@IBAction func tapSignupOrLoginButton(_ sender: Any) {
		disableSignupLoginButton()
		signupOrLoginButton.showLoading()
		
		// Check that username and password fields are not empty
		if isUsernameAndPasswordFieldsNotEmpty() {
			let username = usernameTextField.text!
			let password = passwordTextField.text!
			let email = "\(username)@ligchatapp.com"
			
			self.attemptSignIn(email: email, password: password)
		} else {
			// Alert user that username or password field is empty
			let alertController = UIAlertController(title: "Please try again", message:"Please enter a username and password.", preferredStyle: .alert)
			
			let tryAgainAction = UIAlertAction(title: "Try Again", style: .cancel, handler: nil)
			alertController.addAction(tryAgainAction)
			
			self.present(alertController, animated: true, completion: nil)
			
			self.enableSignupLoginButton()
			self.signupOrLoginButton.hideLoading()
		}
	}

	// MARK: Utility/helper functions
	func presentChatView(){
		let chatNavController = self.storyboard!.instantiateViewController(withIdentifier: "ChatCollectionNavController") as! UINavigationController
		
		self.present(chatNavController, animated: false, completion: nil)
	}
	
	func isUsernameAndPasswordFieldsNotEmpty() -> Bool {
		if let username = self.usernameTextField.text, let password = self.passwordTextField.text,
			!username.isEmpty, !password.isEmpty {
			return true
		}

		return false
	}
	
	func enableSignupLoginButton() {
		signupOrLoginButton.isEnabled = true
		signupOrLoginButton.isUserInteractionEnabled = true
		signupOrLoginButton.alpha = 1
	}
	
	func disableSignupLoginButton() {
		signupOrLoginButton.isEnabled = false
		signupOrLoginButton.isUserInteractionEnabled = false
		signupOrLoginButton.alpha = 0.5
	}
	
	// Called when username and password textfields are edited, used to enable or disable the signup/login button
	func usernamePasswordFieldEdited(_ textField: UITextField) {
		if isUsernameAndPasswordFieldsNotEmpty() {
			enableSignupLoginButton()
		} else {
			disableSignupLoginButton()
		}
	}
}
