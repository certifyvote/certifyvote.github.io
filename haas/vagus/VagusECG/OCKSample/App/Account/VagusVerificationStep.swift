//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import ResearchKit

open class VagusVerificationStep: ORKVerificationStep {
    
    let client: Api = Api()
    
    public typealias VerificationHandler = (VagusVerificationViewController, Swift.Error?) -> Void
    
    public var registrationStep: VagusRegistrationStep?
    var completionHandler: VerificationHandler?
    
    public init(identifier: String, text: String?, completionHandler: VerificationHandler? = nil) {
        self.completionHandler = completionHandler
        super.init(identifier: identifier, text: text, verificationViewControllerClass: VagusVerificationViewController.self)
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
