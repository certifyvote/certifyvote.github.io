//
//  MicrobiomeViewController.swift
//  Vagus
//
//  Created by Johan Sellström on 2020-10-25.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import Foundation
import UIKit
import CareKit
import CareKitUI

class MicrobiomeViewController: OCKListViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Microbiome"
        
        let spacer = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 16.0))
        self.appendView(spacer, animated: true)

        var values = [[Double]]()

        let test = TestProcessor.fromFile(name: "symbiome")

        //Log.debug("Symbiome test \(test)")
        //Log.debug("Areas \(test?.samples.first?.areas)")

        var titles = [String]()

        if let samples = test?.samples {
            Log.debug("Number of samples \(samples.count)")
            for sample in samples {
                var v = [Double]()
                for area in sample.areas {
                    Log.debug(area)
                    Log.debug(area.id)
                    let lower : UInt32 = 10
                    let upper : UInt32 = 50
                    let randomNumber = arc4random_uniform(upper - lower) + lower
                    v.append(Double(randomNumber))
                    titles.append(area.id.capitalized)
                    let groups = area.organismGroups
                    for group in groups {
                        Log.debug(group.title)
                    }
                }
                values.append(v)
            }
        }

        for i in 0..<values.count {
            let radarView = MicrobiomeView(measuredAt: Date(), titles: titles, values: values, comment: "comment", index: i, device: .symbiome)
            radarView.headerView.titleLabel.text = NSLocalizedString("MANAL", comment: "")
            radarView.headerView.detailLabel.text = NSLocalizedString("MORE_COVERAGE", comment: "")
            appendView(radarView, animated: true)
        }
        
    }

}
