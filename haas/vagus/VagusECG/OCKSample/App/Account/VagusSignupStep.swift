//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import ResearchKit

open class VagusSignupStep: ORKWaitStep {

    let client: Api = Api()
    var registrationStepResult: ORKStepResult?
    
    public required override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func stepViewControllerClass() -> AnyClass {
        return VagusSignupStepViewController.self
    }
    
}
