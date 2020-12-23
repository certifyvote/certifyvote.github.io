//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import ResearchKit

open class VagusVerificationViewController : ORKVerificationStepViewController {
    
    private var verificationStep: VagusVerificationStep {
        return step as! VagusVerificationStep
    }
    
    override open func resendEmailButtonTapped() {
        /*if let user = verificationStep.client.activeUser {
            user.sendEmailConfirmation(options: Options(client: verificationStep.client)) { result in
                switch result {
                case .success:
                    if let completionHandler = self.verificationStep.completionHandler {
                        completionHandler(self, nil)
                    } else {
                        self.goForward()
                    }
                case .failure(let error):
                    if let completionHandler = self.verificationStep.completionHandler {
                        completionHandler(self, error)
                    } else {
                        self.goForward()
                    }
                }
            }
        }*/
    }
    
}
