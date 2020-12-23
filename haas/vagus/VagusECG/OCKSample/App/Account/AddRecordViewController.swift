//
//  AddRecordViewController.swift
//  Vagus
//
//  Created by Johan Sellström on 2020-10-25.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import UIKit

class AddRecordViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return ServiceHealthRecordType.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell.imageView?.image = ServiceHealthRecordType.allCases[indexPath.row].icon
        cell.textLabel?.text = ServiceHealthRecordType.allCases[indexPath.row].rawValue
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let record =  ServiceHealthRecordType.allCases[indexPath.row]
        Log.debug("record \(record)")
        switch record {
            case .withings:
                let manager = WithingsManager.shared
                manager.connect(viewController: self) { (success) in
                    Log.debug(success)
                }
                break
            default:
                break
        }
    }

}
