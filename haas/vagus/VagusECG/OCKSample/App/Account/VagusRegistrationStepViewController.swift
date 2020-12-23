//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import ResearchKit

open class VagusRegistrationStepViewController: ORKFormStepViewController {
    
    var registrationStep: VagusRegistrationStep {
        return step as! VagusRegistrationStep
    }
    
    open override func goForward() {
        registrationStep.signupStep?.registrationStepResult = result
        super.goForward()
    }
    
}
