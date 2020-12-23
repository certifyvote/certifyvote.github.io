//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import ResearchKit

open class VagusRegistrationStep: ORKRegistrationStep {
    
    public var signupStep: VagusSignupStep?
    
    open override func stepViewControllerClass() -> AnyClass {
        return VagusRegistrationStepViewController.self
    }
    
}
