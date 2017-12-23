//
//  SignupViewController.swift
//  words
//
//  Created by Neo Ighodaro on 09/12/2017.
//  Copyright (c) 2017 CreativityKills Co.. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit


protocol SignupFormErrorLogic
{
    func showValidationError(_ message: String)
}

class SignupViewController: UIViewController, SignupFormErrorLogic
{
    var interactor: SignupBusinessLogic?

    var router: (NSObjectProtocol & SignupRoutingLogic)?

    // MARK: Object lifecycle
  
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
  
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
  
    // MARK: Setup
  
    private func setup()
    {
        let viewController = self
        let interactor = SignupInteractor()
        let router = SignupRouter()
        
        viewController.interactor = interactor
        viewController.router = router
        interactor.router = router
        interactor.viewController = viewController
        router.viewController = viewController
    }
    
    // MARK: Input fields

    @IBOutlet weak var fullNameTextField: AuthTextField!
    
    @IBOutlet weak var emailTextField: AuthTextField!
    
    @IBOutlet weak var passwordTextField: AuthTextField!
    
    // MARK: Actions
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func signupButtonPressed(_ sender: Any) {
        guard let email = emailTextField.text, email != "" else {
            return showValidationError("Email is required!")
        }

        guard let name = fullNameTextField.text, name != "" else {
            return showValidationError("Full name is required!")
        }

        guard let password = passwordTextField.text, password != "" else {
            return showValidationError("Password is required!")
        }

        let request = Signup.Request(name: name, email: email, password: password)
        
        interactor?.createAccount(request: request)
    }

    func showValidationError(_ message: String) {
        let alertCtrl = UIAlertController(title: "Oops! An error occurred", message: message, preferredStyle: .alert)

        alertCtrl.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))

        self.show(alertCtrl, sender: self)
    }
}
