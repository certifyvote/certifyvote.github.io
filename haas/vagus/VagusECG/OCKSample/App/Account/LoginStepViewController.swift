//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import ResearchKit

open class LoginStepViewController: ORKWaitStepViewController {
    
    typealias Credential = (email: String?, password: String?)
    
    var credential: Credential {
        var email: String? = nil
        var password: String? = nil
        
        if let results = loginStep.loginStepResult?.results {
            for result in results {
                switch result.identifier {
                case ORKLoginFormItemIdentifierEmail:
                    email = (result as? ORKTextQuestionResult)?.textAnswer
                case ORKLoginFormItemIdentifierPassword:
                    password = (result as? ORKTextQuestionResult)?.textAnswer
                default:
                    break
                }
            }
        }
        
        return Credential(email: email, password: password)
    }
    
    var loginStep: LoginStep {
        return step as! LoginStep
    }

    @objc func close() {
        dismiss(animated: true) {
            /*
            if  let window = self.view.window, let mySceneDelegate = window.windowScene?.delegate as? SceneDelegate  {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let manager = appDelegate.synchronizedStoreManager
                let careViewController = UINavigationController(rootViewController: CareViewController(storeManager: manager))
                mySceneDelegate.setRootViewController(viewController: careViewController)

            }*/
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let credential = self.credential
        
        guard let email = credential.email, let password = credential.password else {
            return
        }

        Api.getToken(email: email, password: password) { (response, error) in
            if let error = error {
                Log.error("error \(error.localizedDescription)")
                DispatchQueue.main.async {
                    //let _ = self.alert(error: error)
                }
            } else if let response = response {

                /*if let jsonString = try? JSONSerialization.jsonObject(with: response, options: .allowFragments) {
                    print("jsonString \(jsonString)")
                } else {
                    print("Could not serialize json")
                }*/

                if let loginObject = try? JSONDecoder().decode(LoginResponse.self, from: response) {
                    if let errors = loginObject.errors {
                        DispatchQueue.main.async {
                            var msg = ""
                            if let emailError = errors.email?.first {
                                msg = emailError
                            } else if let passwordError = errors.password?.first {
                                msg = passwordError
                            }
                            let alertTitle = NSLocalizedString("ERROR", comment: "")

                            Log.error(msg)
                            let alertMessage = "CHECK_CREDENTIALS"
                            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { alertAction in
                                self.goForward()
                            })
                            self.present(alert, animated: true, completion: nil)
                        }
                        var config = Config()
                        config.loggedin = nil
                        DispatchQueue.main.async {
                            self.goForward()
                        }
                    } else if loginObject.access_token != nil {
                        var config = Config()
                        config.loggedin = loginObject
                        DispatchQueue.main.async {

                            self.close()
                            Api.getMe { (response, error) in
                                if let error = error {
                                    Log.error(error)
                                } else if let response = response, let meObject = try? JSONDecoder().decode(MeResponse.self, from: response) {
                                    config.userName = meObject.name
                                    config.userEmail = meObject.email
                                }
                            }

                            Api.getPortrait { (response, error) in
                                if let error = error {
                                    Log.error("Portrait \(error)")
                                } else if let response = response, let photoObject = try? JSONDecoder().decode(Photo.self, from: response) {
                                    if let data = Data(base64Encoded: photoObject.data) {
                                        let image = UIImage(data: data)
                                        config.portraitPath = image?.persist()
                                        Log.debug("Portrait retrieved")
                                    }
                                } else {
                                    if let response = response {
                                        if let str = String(data: response, encoding: .utf8) {
                                            Log.error(str)
                                        }
                                    }
                                    Log.error("Portrait could not decode")
                                }
                            }
                        }

                        DispatchQueue.main.async {
                            if let window = self.view.window, let mySceneDelegate = window.windowScene?.delegate as? SceneDelegate  {
                                mySceneDelegate.loadMain()
                            }
                        }
                    } else {
                        var config = Config()
                        config.loggedin = nil
                        DispatchQueue.main.async {
                            let alertTitle = NSLocalizedString("ERROR", comment: "")
                            let alertMessage = loginObject.message
                            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default) { alertAction in
                                self.goForward()
                            })
                            self.present(alert, animated: true, completion: nil)
                        }
                        /*DispatchQueue.main.async {
                            self.goForward()
                        }*/
                    }
                } else {
                    Log.error("Could not decode response")
                }
            }
        }
    }
}
