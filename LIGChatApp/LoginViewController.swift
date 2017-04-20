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
		
		// Check if there is a currently logged in user
		if let loggedInUser = FIRAuth.auth()?.currentUser {
			print("LOGGED IN")
			print(loggedInUser.email)
		} else {
			print("not logged in")
		}
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		authHandle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
			print("STATE DID CHANGE AUTH")
			print(auth)
			print(user)
		}
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		FIRAuth.auth()?.removeStateDidChangeListener(authHandle!)
	}
	
	@IBAction func tapSignupOrLoginButton(_ sender: Any) {
		disableSignupLoginButton()
		signupOrLoginButton.showLoading()
		
		// Check that username and password fields are not empty
		if isUsernameAndPasswordFieldsNotEmpty() {
			let username = usernameTextField.text!
			let password = passwordTextField.text!
			let email = "\(username)@ligchatapp.com"
			
			FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
				print("SIGN IN")
				
				if let user = user {
					print(user.uid)
					print(user.email)
					self.performSegue(withIdentifier: "LoginToChat", sender: nil)
				} else if error != nil {
					// Alert user for incorrect credentials
					let alertController = UIAlertController(title: "Please try again", message:"The username or password you entered did not match our records. Please double-check and try again.", preferredStyle: .alert)
					
					let tryAgainAction = UIAlertAction(title: "Try Again", style: .cancel, handler: nil)
					alertController.addAction(tryAgainAction)
					
					self.present(alertController, animated: true, completion: nil)
				}
				
				self.enableSignupLoginButton()
				self.signupOrLoginButton.hideLoading()
			}
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
	
	// MARK: Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let chatViewController = segue.destination as? ChatViewController {
			let loggedInUser = FIRAuth.auth()?.currentUser
			chatViewController.senderId = loggedInUser!.uid
			chatViewController.senderDisplayName = loggedInUser!.email
		}
	}
}