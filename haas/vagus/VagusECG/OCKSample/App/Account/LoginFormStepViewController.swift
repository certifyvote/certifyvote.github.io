//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import ResearchKit

open class LoginFormStepViewController: ORKLoginStepViewController {
    
    typealias Credential = (email: String?, password: String?)
    
    var credential: Credential {
        var email: String? = nil
        var password: String? = nil
        
        if let results = result?.results {
            for result in results {
                switch result.identifier {
                case "ORKLoginFormItemEmail":
                    email = (result as? ORKTextQuestionResult)?.textAnswer
                case "ORKLoginFormItemPassword":
                    password = (result as? ORKTextQuestionResult)?.textAnswer
                default:
                    break
                }
            }
        }
        return Credential(email: email, password: password)
    }

    var loginFormStep: LoginFormStep {
        return step as! LoginFormStep
    }
    
    open override func goForward() {
        loginFormStep.loginStep?.loginStepResult = result
        super.goForward()
    }
    
    open override func forgotPasswordButtonTapped() {

        let credential = self.credential
        guard let email = credential.email else {
            let alertTitle = NSLocalizedString("FORGOT_PASSWORD?", comment: "")
            let alertMessage = NSLocalizedString("TYPE_EMAIL", comment: "")
            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }

        Log.debug("forgotPasswordButtonTapped \(email)")

        Api.forgot(email: email) { (data, error) in
            DispatchQueue.main.async {
                if let error = error {
                    Log.error("\(error)")
                    let alertTitle = NSLocalizedString("ERROR", comment: "")
                    let alertMessage = NSLocalizedString("\(error)", comment: "")
                    let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if let data = data {
                    let decoder = JSONDecoder()
                    if let response = try? decoder.decode(ForgotResponse.self, from: data) {
                        if let errors = response.errors, let msg = errors.email.first {
                            let alertTitle = NSLocalizedString("ERROR", comment: "")
                            let alertMessage = NSLocalizedString(msg, comment: "")
                            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            let message = response.message
                            let alertTitle = NSLocalizedString("PASSWORD_RECOVERY", comment: "")
                            let alertMessage = NSLocalizedString(message, comment: "")
                            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }

        /*
        User.resetPassword(usernameOrEmail: email, options: nil) {
            switch $0 {
            case .success:
                let alertTitle = NSLocalizedString("Forgot password?", comment: "")
                let alertMessage = NSLocalizedString("Email sent!", comment: "")
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            case .failure(let error):
                let alertTitle = NSLocalizedString("Forgot password?", comment: "")
                let alertMessage = error.localizedDescription
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }*/

    }
    
}
