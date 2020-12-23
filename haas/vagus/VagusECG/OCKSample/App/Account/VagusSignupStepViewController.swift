//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import ResearchKit

open class VagusSignupStepViewController: ORKWaitStepViewController {
    
    var signupStep: VagusSignupStep {
        return step as! VagusSignupStep
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let registrationStepResult = signupStep.registrationStepResult
        
        var email: String? = nil
        var password: String? = nil
        var givenName: String? = nil
        var familyName: String? = nil
        var gender: String? = nil
        var dateOfBirth: Date? = nil
        
        if let results = registrationStepResult?.results {
            for result in results {
                switch result.identifier {
                case ORKRegistrationFormItemIdentifierEmail:
                    email = (result as? ORKTextQuestionResult)?.textAnswer
                case ORKRegistrationFormItemIdentifierPassword:
                    password = (result as? ORKTextQuestionResult)?.textAnswer
                case ORKRegistrationFormItemIdentifierGivenName:
                    givenName = (result as? ORKTextQuestionResult)?.textAnswer
                case ORKRegistrationFormItemIdentifierFamilyName:
                    familyName = (result as? ORKTextQuestionResult)?.textAnswer
                case ORKRegistrationFormItemIdentifierGender:
                    gender = (result as? ORKChoiceQuestionResult)?.choiceAnswers?.first as? String
                case ORKRegistrationFormItemIdentifierDOB:
                    dateOfBirth = (result as? ORKDateQuestionResult)?.dateAnswer
                default:
                    break
                }
            }
        }

        var name = ""

        if let givenName = givenName {
            name = givenName
        }

        if let familyName = familyName {
            name += " " + familyName
        }

        if let email = email, let password = password {

            Api.signup(name: name, email: email, password: password, password_confirmation: password) { (response, error) in
                if let error = error {
                    print("error \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        //let _ = self.alert(error: error)
                    }
                } else if let response = response {

                    if let jsonString = try? JSONSerialization.jsonObject(with: response, options: .allowFragments) {
                        Log.debug(jsonString)
                    } else {
                        Log.error("Could not serialize json")
                    }

                    if let registrationObject = try? JSONDecoder().decode(RegistrationResponse.self, from: response) {
                        Log.debug(registrationObject)
                        if let errors = registrationObject.errors {
                            DispatchQueue.main.async {
                                let alertTitle = NSLocalizedString("ERROR", comment: "")
                                let alertMessage = ""
                                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "OK", style: .default) { alertAction in
                                    self.goForward()
                                })
                                self.present(alert, animated: true, completion: nil)
                            }
                            print(errors)
                            var config = Config()
                            config.registered = nil
                            self.goBackward()
                        } else {
                            var config = Config()
                            config.registered = registrationObject
                            config.userName = name
                            config.userEmail = email
                            Api.getToken(email: email, password: password) { (response, error) in
                                if let error = error {
                                    print("error \(error.localizedDescription)")
                                    DispatchQueue.main.async {
                                        //let _ = self.alert(error: error)
                                    }
                                } else if let response = response {

                                    if let jsonString = try? JSONSerialization.jsonObject(with: response, options: .allowFragments) {
                                        print("jsonString \(jsonString)")
                                    } else {
                                        print("Could not serialize json")
                                    }

                                    if let loginObject = try? JSONDecoder().decode(LoginResponse.self, from: response) {
                                                //print(registrationObject)
                                        if let errors = loginObject.errors {
                                            DispatchQueue.main.async {
                                                //self.alert(msg: errors.description)
                                            }
                                            print(errors)
                                            var config = Config()
                                            config.loggedin = nil
                                        } else {
                                            print(loginObject)
                                            var config = Config()
                                            config.loggedin = loginObject
                                            // Now set gender, dob

                                            if let dob = dateOfBirth {
                                                let dateFormatter = DateFormatter()
                                                dateFormatter.dateFormat = "yyyy-MM-dd"
                                                let birthday = dateFormatter.string(from: dob)
                                                Api.setMe(gender: gender, birthday: birthday) { (response, error) in
                                                    if let error = error {
                                                        Log.error("\(error)")
                                                    } else if let response = response {
                                                        if let jsonString = try? JSONSerialization.jsonObject(with: response, options: .allowFragments) {
                                                            print("jsonString \(jsonString)")
                                                        } else {
                                                            print("Could not serialize json")
                                                        }
                                                    }
                                                }
                                            }

                                            DispatchQueue.main.async {
                                                self.close()
                                                if  let window = self.view.window, let mySceneDelegate = window.windowScene?.delegate as? SceneDelegate  {
                                                    mySceneDelegate.loadMain()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        print("Could not decode response")
                    }
                }
            }
        }
    }

    @objc func close() {
        dismiss(animated: true) {
        }
    }
    
}
