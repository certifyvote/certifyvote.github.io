//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import Foundation
import CareKit
import CareKitUI
import ResearchKit

class ConsentDocument: ORKConsentDocument {
    // MARK: Properties

    let ipsum = [
        "Congratulations to having made a great choice and wanting to take conrol of your health.",
        "To apply our analysis and give you the results we need to process and store your ECG data.",
        "We take your privacy very seriously and will never share any data without your consent.",
        "Time to time we may offer you the possibility to participate in clinical studies but otherwise your data is only used to provide insights for yourself. ",
        "You may at any time withdraw, delete your account and all your data.",
    ]

    // MARK: Initialization

    override init() {
        super.init()

        title = NSLocalizedString("CONSENT_FORM", comment: "")

        let sectionTypes: [ORKConsentSectionType] = [
            .overview,
            .dataGathering,
            .privacy,
            .dataUse,
            /*.timeCommitment,
            .studySurvey,
            .studyTasks,*/
            .withdrawing
        ]
        sections = []

        for sectionType in sectionTypes {
            let section = ORKConsentSection(type: sectionType)

            let localizedIpsum = NSLocalizedString(ipsum[sectionTypes.firstIndex(of: sectionType)!], comment: "")
            let localizedSummary = localizedIpsum.components(separatedBy: ".")[0] + "."

            section.summary = localizedSummary
            section.content = localizedIpsum
            if sections == nil {
                sections = [section]
            } else {
            sections!.append(section)
            }
        }

        let signature = ORKConsentSignature(forPersonWithTitle: nil, dateFormatString: nil, identifier: "ConsentDocumentParticipantSignature")
        addSignature(signature)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ORKConsentSectionType: CustomStringConvertible {

    public var description: String {
        switch self {
            case .overview:
                return "Overview"
            case .dataGathering:
                return "DataGathering"

            case .privacy:
                return "Privacy"

            case .dataUse:
                return "DataUse"

            case .timeCommitment:
                return "TimeCommitment"

            case .studySurvey:
                return "StudySurvey"
            case .studyTasks:
                return "StudyTasks"
            case .withdrawing:
                return "Withdrawing"
            case .custom:
                return "Custom"

            case .onlyInDocument:
                return "OnlyInDocument"
        @unknown default:
            fatalError()
        }
    }
}

class WelcomeViewController: OCKListViewController {

    var config = AppConfig()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        //title = "Welcome"
        let introLabel = UILabel()
        introLabel.numberOfLines = 0
        introLabel.text = "To continue, please login or sign up for an account"
        introLabel.textAlignment = .center

        let logoImage: UIImage!

        if traitCollection.userInterfaceStyle == .dark {
            logoImage =  UIImage(named: "logo_white")
        } else {
            logoImage =  UIImage(named: "logo")
        }

        let logoView = UIImageView(image: logoImage)

        logoView.contentMode = .scaleAspectFit
        let loginButton = OCKButton(text: "Login")
        loginButton.label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        //loginButton.setStyleForSelectedState(true)
        loginButton.addTarget(self, action: #selector(login), for: .touchUpInside)

        let signupButton = OCKButton(text: "Signup")
        signupButton.label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        signupButton.setStyleForSelectedState(true)
        signupButton.addTarget(self, action: #selector(signup), for: .touchUpInside)

        /*
        let testButton = OCKButton(text: "Consent")
        testButton.label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        testButton.setStyleForSelectedState(true)
        testButton.addTarget(self, action: #selector(test), for: .touchUpInside)
        */

        logoView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
                logoView.heightAnchor.constraint(equalToConstant: 100)])

        appendView(logoView, animated: true)
        appendView(introLabel, animated: true)
        appendView(loginButton, animated: true)
        appendView(signupButton, animated: true)
        //appendView(testButton, animated: true)

    }

    private var loginTask: ORKTask {
        /*
        A login step view controller subclass is required in order to use the login step.
        The subclass provides the behavior for the login step forgot password button.
        */
        class LoginViewController : ORKLoginStepViewController {
            override func forgotPasswordButtonTapped() {
                let alertTitle = NSLocalizedString("FORGOT_PASSWORD?", comment: "")
                let alertMessage = NSLocalizedString("", comment: "")
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

        /*
        A login step provides a form step that is populated with email and password fields,
        and a button for `Forgot password?`.
        */
        let loginTitle = NSLocalizedString("LOGIN", comment: "")
        let loginStep = LoginFormStep(identifier: String(describing:"loginStep"), title: loginTitle, text: "", loginViewControllerClass: LoginFormStepViewController.self)

        /*
        A wait step allows you to validate the data from the user login against your server before proceeding.
        */
        let waitTitle = NSLocalizedString("LOGGING_IN", comment: "")
        let waitText = NSLocalizedString("VALIDATE_CREDENTIALS", comment: "")
        let waitStep = LoginStep(identifier: String(describing:"loginWaitStep"))
        waitStep.title = waitTitle
        waitStep.text = waitText

        loginStep.loginStep = waitStep

        let healthDataStep = HealthDataStep(identifier: "Health")

        return ORKOrderedTask(identifier: String(describing:"loginTask"), steps: [loginStep, waitStep, healthDataStep])
    }

    /// This task presents the Account Creation process.
    private var accountCreationTask: ORKTask {

        let healthDataStep = HealthDataStep(identifier: "Health")

        let consentDocument = ConsentDocument()
        let consentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)

        /*
         A wait step allows you to upload the data from the user registration onto your server before presenting the verification step.
         */

        let waitTitle = NSLocalizedString("CREATING_ACCOUNT", comment: "")
        let waitText = NSLocalizedString("UPLOAD_DATA", comment: "")
        let signupStep = VagusSignupStep(identifier: String(describing:"waitStep"))
        signupStep.title = waitTitle
        signupStep.text = waitText

        /*
        A registration step provides a form step that is populated with email and password fields.
        If you wish to include any of the additional fields, then you can specify it through the `options` parameter.
        */
        let registrationTitle = NSLocalizedString("REGISTRATION" , comment: "")
        let passcodeValidationRegularExpressionPattern = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d]{8,}$" //"^(?=.*\\d).{4,8}$"
        let passcodeValidationRegularExpression = try! NSRegularExpression(pattern: passcodeValidationRegularExpressionPattern)
        let passcodeInvalidMessage = NSLocalizedString("VALID_PASS", comment: "")

        let registrationOptions: ORKRegistrationStepOption = [.includeGivenName, .includeFamilyName, .includeGender, .includeDOB]
        let registrationStep = VagusRegistrationStep(identifier: String(describing:"registrationStep"), title: registrationTitle, text: NSLocalizedString("ENTER_INFORMATION", comment: ""), passcodeValidationRegularExpression: passcodeValidationRegularExpression, passcodeInvalidMessage: passcodeInvalidMessage, options: registrationOptions)
        registrationStep.signupStep = signupStep

        /*
        A verification step view controller subclass is required in order to use the verification step.
        The subclass provides the view controller button and UI behavior by overriding the following methods.
        */
        class VerificationViewController : ORKVerificationStepViewController {
            override func resendEmailButtonTapped() {
                let alertTitle = NSLocalizedString("RESEND_EMAIL", comment: "")
                let alertMessage = NSLocalizedString("", comment: "")
                let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }

        let verificationStep = VagusVerificationStep(identifier: String(describing:"verificationStep"), text: "")
        verificationStep.registrationStep = registrationStep

        return ORKOrderedTask(identifier: String(describing:"accountCreationTask"), steps: [
            consentStep,
            healthDataStep,
            registrationStep,
            signupStep,
            verificationStep
        ])
    }


    @objc func login() {
        let loginViewController = ORKTaskViewController(task: loginTask, taskRun: nil)
        loginViewController.navigationController?.setNavigationBarHidden(true, animated: false)
        loginViewController.delegate = self
        loginViewController.outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        present(loginViewController, animated: true, completion: nil)
    }

    @objc func signup() {
        let signupViewController = ORKTaskViewController(task: accountCreationTask, taskRun: nil)
        signupViewController.navigationController?.setNavigationBarHidden(true, animated: false)
        signupViewController.delegate = self
        present(signupViewController, animated: true, completion: nil)
    }

    @objc func test() {

        let consentDocument = ConsentDocument()
        let consentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
        let consentTask = ORKOrderedTask(identifier: String(describing:"consentTask"), steps: [
            consentStep
        ])

        let consentViewController = ORKTaskViewController(task: consentTask, taskRun: nil)
        consentViewController.navigationController?.setNavigationBarHidden(true, animated: false)
        consentViewController.delegate = self
        present(consentViewController, animated: true, completion: nil)
    }

}


extension WelcomeViewController: ORKTaskViewControllerDelegate {

    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        if step is HealthDataStep {
            let healthStepViewController = HealthDataStepViewController(step: step)
            return healthStepViewController
        }
        return nil
    }

    public func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
    }

    public func taskViewController(_ taskViewController: ORKTaskViewController, shouldPresent step: ORKStep) -> Bool {
        return true
    }

    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {

        switch reason {
            case .completed:
                
                dismiss(animated: true, completion: nil)

                /*
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let manager = appDelegate.synchronizedStoreManager

                if  let window = self.view.window, let mySceneDelegate = window.windowScene?.delegate as? SceneDelegate  {
                    let controller =  ScreeningResultsViewController()
                    controller.manager = manager
                    let resultsViewController = UINavigationController(rootViewController: controller)
                    mySceneDelegate.setRootViewController(viewController: resultsViewController)
                }
                */

            case .discarded, .failed, .saved:
                dismiss(animated: true, completion: nil)
        default:
            break
        }
    }

    
}
