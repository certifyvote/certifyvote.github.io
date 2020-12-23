//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import ResearchKit

open class LoginStep: ORKWaitStep {
    
    let client: Api = Api()
    var loginStepResult: ORKStepResult?
    
    public required override init(identifier: String) {
        super.init(identifier: identifier)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open override func stepViewControllerClass() -> AnyClass {
        return LoginStepViewController.self
    }
    
}
