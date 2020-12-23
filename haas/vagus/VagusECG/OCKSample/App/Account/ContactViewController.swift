//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import UIKit

class ContactViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("CONTACT", comment: "")
        textView.tintColor = view.window?.tintColor
        textView.isEditable = false
        textView.textColor = .secondaryLabel
        textView.font = .systemFont(ofSize: 20)
        textView.text = "Vagus Health Ltd\nCambridge (UK), Reg Nr: 11101252\nwww.vagus.co\ninfo@vagus.co"
        textView.dataDetectorTypes = [UIDataDetectorTypes.link]
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: "Done", style: .plain, target: self,
                            action: #selector(done))
    }

    @objc private func done() {
        dismiss(animated: true, completion: nil)
    }
}
