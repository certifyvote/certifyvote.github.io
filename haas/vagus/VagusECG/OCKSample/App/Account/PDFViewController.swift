//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {

    var name: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        let pdfView = PDFView()

        pdfView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pdfView)

        pdfView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        pdfView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        pdfView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        pdfView.autoScales = true
        
        guard let name = name, let path = Bundle.main.url(forResource: name, withExtension: "pdf") else { return }

        if let document = PDFDocument(url: path) {
            pdfView.document = document
        }


        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(title: NSLocalizedString("DONE", comment: ""), style: .plain, target: self,
                            action: #selector(done))
    }

    @objc private func done() {
        dismiss(animated: true, completion: nil)
    }
}
