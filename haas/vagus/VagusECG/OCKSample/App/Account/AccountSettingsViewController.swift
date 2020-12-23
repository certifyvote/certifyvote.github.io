//
//  Created by Johan Sellström.
//  Copyright © 2020 Advatar Systems. All rights reserved.
//

import UIKit
import CareKit
import CareKitStore
import CoreBluetooth
import ResearchKit

public protocol WatchDelegate {
    func didConnect()
    func setProgress(_ progress: Float)
    func setDone()
}

class AccountSettingsViewController: UITableViewController, WatchDelegate {

    let accountSection = 0

    #if VAGUS_WATCH
    let vagusSection = 1
    let optionalSection = 2
    let aboutSection = 3
    let recordsSection = 4

    let ratingRow = 0
    let scienceRow = 1
    let qaRow = 2
    let manualRow = 3
    let factsRow = 4
    let vagusAccountRow = 5
    let contactRow = 6
    #else
    let vagusSection = -1
    let optionalSection = 1
    let aboutSection = 2
    let recordsSection = 3

    let ratingRow = 0
    let scienceRow = 1
    let qaRow = 2
    let manualRow = -3
    let factsRow = -4
    let vagusAccountRow = 3
    let contactRow = 4

    #endif

    func setDone() {
        DispatchQueue.main.async {
            self.progressBar.setProgress(0.0, animated: true)
        }
        Log.debug("done")
    }

    func setProgress(_ progress: Float) {
        Log.debug("progress \(progress)")
        DispatchQueue.main.async {
            self.progressBar.setProgress(progress, animated: true)
        }
    }

    func didConnect() {
        tableView.reloadData()
    }

    var accountCommands = [NSLocalizedString("CHANGE_PASSWORD", comment: ""), NSLocalizedString("LOGOUT", comment: "")]
    var watchCommands = [NSLocalizedString("ALARMA", comment: ""), NSLocalizedString("CONF", comment: ""), NSLocalizedString("FIRMWARE", comment: ""), NSLocalizedString("DISCONNECT", comment: "")]

    #if VAGUS_WATCH
    var infoCommands = [NSLocalizedString("RATE_US", comment: ""), NSLocalizedString("SCIENCE", comment: ""), NSLocalizedString("QA", comment: ""), NSLocalizedString("MANUAL", comment: ""), NSLocalizedString("FACTS", comment: ""), NSLocalizedString("VACCOUNT", comment: ""), NSLocalizedString("CONTACT", comment: "")]
    #else
    var infoCommands = [NSLocalizedString("RATE_US", comment: ""), NSLocalizedString("SCIENCE", comment: ""), NSLocalizedString("QA", comment: ""),  NSLocalizedString("VACCOUNT", comment: ""), NSLocalizedString("CONTACT", comment: "")]
    #endif

    private var cbManager: CBCentralManager = CBCentralManager()
    private var cbPeripherals = [CBPeripheral]()
    var config = Config()
    var indicator = UIActivityIndicatorView()
    var wasDelegate: WatchDelegate?
    public var renderDelegate: RenderDelegate?
    var portrait: UIImage?
    let progressBar = UIProgressView(progressViewStyle: .bar)

    override func viewDidLoad() {

        super.viewDidLoad()
        title = NSLocalizedString("DETAILS", comment: "")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.register(UINib(nibName: "ToggleTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "toggleCell")
        tableView.register(UINib(nibName: "PortraitViewCell", bundle: Bundle.main), forCellReuseIdentifier: "portraitCell")

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        tableView.refreshControl = refreshControl
        let headerView = UIImageView()
        headerView.image = UIImage(named: "nerve")
        tableView.tableHeaderView = headerView

        if let path = config.portraitPath {
            portrait = path.imageFromCache
        }

        progressBar.setProgress(0.0, animated: false)
        navigationController?.positionProgressBar(progressBar)

    }

    override func viewDidDisappear(_ animated: Bool) {
        IWownManager.shared.delegate = wasDelegate
    }

    override func viewDidAppear(_ animated: Bool) {
        wasDelegate = IWownManager.shared.delegate
        IWownManager.shared.delegate = self
        Log.error("Account")
        //if IWownManager.shared.selectedPeripheral?.state != .connected {
            setupBLE()
        //}
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        indicator.stopAnimating()
    }

    @objc func refresh(_ sender : UIRefreshControl){
        sender.endRefreshing()
        tableView.reloadData()
    }

    func setupBLE() {
        cbPeripherals.removeAll()
        cbManager = CBCentralManager(delegate: self, queue: nil)
        cbManager.delegate = self
        indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        indicator.style = UIActivityIndicatorView.Style.medium
        indicator.startAnimating()
        indicator.backgroundColor = .clear
        indicator.hidesWhenStopped = true
    }

    @objc func scanDevice() -> Void {
        let matchingOptions = [CBConnectionEventMatchingOption.serviceUUIDs: [BTCProto.protobuf.sampleServiceUUID]]
        cbManager.registerForConnectionEvents(options: matchingOptions)
        cbManager.scanForPeripherals(withServices: nil, options: nil)
    }

    func checkBluetooth(isON: Bool) {

        if isON == false{
            let alertController = UIAlertController(title: NSLocalizedString("SETTINGS", comment: ""), message: NSLocalizedString("BLE", comment: ""), preferredStyle: UIAlertController.Style.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (action) in
                let url = URL(string: UIApplication.openSettingsURLString)
                let app = UIApplication.shared
                app.open(url!)
            }
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    func batteryIndicator(level: UInt32) -> UIImage? {
        if level < 25 {
            return UIImage(systemName: "battery.0")
        } else if level >= 25 && level < 75 {
            return UIImage(systemName: "battery.25")
        } else {
            return UIImage(systemName: "battery.100")
        }
    }
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 && IWownManager.shared.selectedPeripheral?.state == .connected {
            return 132.0
        }
        return 44.0
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 116.0
        }
        return 44.0
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        #if VAGUS_WATCH
        if section == 0 {
            return nil
        } else if section == 1 {
            if IWownManager.shared.selectedPeripheral?.state == .connected {
                let containerView = UIView()
                let contentView = UIStackView()
                contentView.axis = .horizontal
                contentView.spacing = 8.0
                // Watch
                let watchStack = UIStackView()
                watchStack.axis = .vertical
                let deviceLabel = UILabel()
                deviceLabel.text = connectedDeviceName
                deviceLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
                deviceLabel.textColor = .secondaryLabel
                deviceLabel.sizeToFit()
                let watchView = UIImageView(image: UIImage(named:"watch"))
                watchStack.addArrangedSubview(watchView)
                //watchStack.addArrangedSubview(deviceLabel)
                // Status
                let statusStack = UIStackView()
                statusStack.axis = .vertical
                statusStack.distribution = .equalCentering

                let batteryStack = UIStackView()
                batteryStack.axis = .horizontal

                let batteryLabel = UILabel()
                batteryLabel.text = " " + String(describing: batteryLevel) + "%"
                batteryLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
                batteryLabel.textColor = .secondaryLabel
                batteryLabel.sizeToFit()

                let batteryView = UIImageView(image: batteryIndicator(level: batteryLevel))
                batteryStack.addArrangedSubview(batteryView)
                batteryStack.addArrangedSubview(batteryLabel)

                let versionLabel = UILabel()
                versionLabel.text = "Firmware: " + connectedDeviceVersion
                versionLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
                versionLabel.textColor = .secondaryLabel
                versionLabel.sizeToFit()

                statusStack.addArrangedSubview(batteryStack)
                statusStack.addArrangedSubview(versionLabel)
                statusStack.addArrangedSubview(UIView())

                contentView.addArrangedSubview(deviceLabel)
                contentView.addArrangedSubview(watchStack)
                contentView.addArrangedSubview(statusStack)

                containerView.addSubview(contentView)

                contentView.translatesAutoresizingMaskIntoConstraints = false
                watchView.translatesAutoresizingMaskIntoConstraints = false
                batteryView.translatesAutoresizingMaskIntoConstraints = false

                NSLayoutConstraint.activate([
                    contentView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
                    contentView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
                    /*
                    contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16.0),
                    contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16.0),
                    contentView.topAnchor.constraint(equalTo: containerView.topAnchor),
                    contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
                    */
                    watchView.heightAnchor.constraint(equalToConstant: 80.0),
                    watchView.widthAnchor.constraint(equalToConstant: 80.0),
                    batteryView.heightAnchor.constraint(equalToConstant: 22.0),
                    batteryView.widthAnchor.constraint(equalToConstant: 22.0),
                ])
                return containerView
                //return nil
            } else {
                indicator.startAnimating()
                let view = UIView()
                let label = UILabel()
                label.text = "WATCHES"
                label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
                label.textColor = .secondaryLabel
                //UIFont.preferredFont(forTextStyle: .title2)
                view.addSubview(label)
                view.addSubview(indicator)
                label.translatesAutoresizingMaskIntoConstraints = false
                indicator.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0),
                                                indicator.trailingAnchor.constraint(equalTo: view.trailingAnchor)
                ])
                return view
            }
        }
        #endif
        return nil
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case accountSection:
                return NSLocalizedString("ACCOUNT", comment: "")
            case vagusSection:
                if IWownManager.shared.selectedPeripheral?.state == .connected {
                    return connectedDeviceName
                } else {
                    return NSLocalizedString("WATCHES", comment: "")
                }
            case optionalSection:
                return NSLocalizedString("DIAGRAMS", comment: "")
            case aboutSection:
                return NSLocalizedString("ABOUT", comment: "")
            case recordsSection:
                return NSLocalizedString("HEALTH_RECORDS", comment: "")
            default:
                return nil
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        var num = 4
        #if SERVICES
        num = 5
        #endif

        #if VAGUS_WATCH
        #else
        num -= 1
        #endif

        return num
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        #if VAGUS_WATCH
        if section == accountSection {
            return accountCommands.count + 3
        } else if section == vagusSection {
            if IWownManager.shared.selectedPeripheral?.state == .connected {
                return watchCommands.count
            } else {
                return cbPeripherals.count
            }
        } else if section == optionalSection {
            return OCKStore.OptionalTasks.availableCases.count
        } else if section == aboutSection {
            return infoCommands.count
        } else if section == recordsSection {
            if let count = config.healthRecords?.count {
                return count + 1
            } else {
                return 1
            }
        }
        #else
        if section == accountSection {
            return accountCommands.count + 3
        } else if section == optionalSection {
            return OCKStore.OptionalTasks.availableCases.count
        } else if section == aboutSection {
            return infoCommands.count
        } else if section == recordsSection {
            if let count = config.healthRecords?.count {
                return count + 1
            } else {
                return 1
            }
        }
        #endif

        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell!
            // Account
        if indexPath.section == accountSection {
            switch indexPath.row {
                case 0: // Portrait
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "portraitCell", for: indexPath) as? PortraitViewCell {
                        cell.selectionStyle = .none
                        if let path = config.portraitPath {
                            portrait = path.imageFromCache
                        }
                        if let portrait = portrait {
                            cell.portraitView.image = portrait
                            let backgroundColor = portrait.getPixelColor(pos: CGPoint(x: 0, y: 0))
                            Log.verbose("Portrait background color \(backgroundColor)")
                            cell.portraitView.backgroundColor = backgroundColor
                            cell.portraitView.layer.borderWidth = 1.0
                            cell.portraitView.layer.borderColor = UIColor.lightGray.cgColor
                        } else {
                            cell.portraitView.image = UIImage(systemName: "camera.viewfinder")
                        }
                        return cell
                    } else {
                        cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                        cell.textLabel?.text = "Error"
                    }
                case 1: // name
                    cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    cell.textLabel?.text = config.userName
                break
                case 2:
                    cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    cell.textLabel?.text = config.userEmail
                    break
                default:
                    cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                    cell.textLabel?.text = accountCommands[indexPath.row-3]
                    break
            } // Watch

        } else if indexPath.section == vagusSection {
            if IWownManager.shared.selectedPeripheral?.state == .connected {
                cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                cell.textLabel?.text = watchCommands[indexPath.row]
            } else {
                let watch = cbPeripherals[indexPath.row]
                cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                cell.textLabel?.text = watch.name
            }

        // Diagrams
        } else if indexPath.section == optionalSection {
            let cell = tableView.dequeueReusableCell(withIdentifier: "toggleCell", for: indexPath) as! ToggleTableViewCell
            let task = OCKStore.OptionalTasks.availableCases[indexPath.row]
            Log.debug("task \(task) isOn \(task.isON)")
            cell.toggleButton.setOn(task.isON, animated: true)
            cell.textLabel?.text = task.title
            cell.delegate = self
            return cell
            // About
        } else if indexPath.section == aboutSection {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            cell.textLabel?.text = infoCommands[indexPath.row]
            // Records
        } else if indexPath.section == recordsSection {
            cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            if indexPath.row == config.healthRecords?.count {
                cell.textLabel?.text = "Add Health Record"
            } else {
                cell.imageView?.image = ServiceHealthRecordType.allCases[indexPath.row].icon
                cell.textLabel?.text  = ServiceHealthRecordType.allCases[indexPath.row].rawValue
            }
        }
        cell.selectionStyle = .none
        return cell
    }

    private var infoTask: ORKTask {
        let consentDocument = InfoDocument()
        let infoStep = ORKVisualConsentStep(identifier: "VisualInfoStep", document: consentDocument)
        return ORKOrderedTask(identifier: String(describing:"infoTask"), steps: [
            infoStep
        ])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        switch indexPath.section {
            case accountSection:
                switch indexPath.row {
                    case 0:
                        let imagePicker =  UIImagePickerController()
                        imagePicker.delegate = self
                        #if IOS_SIMULATOR || arch(i386) || arch(x86_64)
                        imagePicker.sourceType = .photoLibrary
                        #else
                        imagePicker.sourceType = .camera
                        #endif
                        present(imagePicker, animated: true, completion: nil)
                        break
                    case 3: // Change password
                        resetPassword()
                        break
                    case 4:
                        guard let window = self.view.window, let mySceneDelegate = window.windowScene?.delegate as? SceneDelegate  else {
                            return
                        }
                        dismiss(animated: true) {
                            let welcomeViewController = WelcomeViewController()
                            let nav = UINavigationController(rootViewController: welcomeViewController)
                            mySceneDelegate.setRootViewController(viewController: nav)
                            var config = Config()
                            config.loggedin = nil
                        }
                    default:
                        break
                }
            case vagusSection:
                if IWownManager.shared.selectedPeripheral?.state != .connected {
                    Log.debug("Clicked to Connect \(cbPeripherals[indexPath.row].name)")
                    IWownManager.shared.delegate = self
                    IWownManager.shared.connect(peripheral: cbPeripherals[indexPath.row])
                } else {
                    Log.debug(watchCommands[indexPath.row])
                    switch indexPath.row {
                        case 0: // Alarm
                            guard IWownManager.shared.selectedPeripheral?.state == .connected,
                                IWownManager.shared.writeCharacter != nil else {

                                    return
                            }
                            let environment = Alarms.Environment(
                                watchConfigurator: WatchConfigurator(
                                    watchCommander: WatchCommander(),
                                    watchName: connectedDeviceName
                                )
                            )
                            present(
                                Widget(
                                    viewModel: .init(
                                        initial: .init(alarmGroup: environment.watchConfigurator.alarmGroup),
                                        environment: environment, reducer: Alarms.reducer
                                    ),
                                    render: { context in AlarmsView(context: context) }
                                )
                            )
                            break
                        case 1: // Configuration
                            guard IWownManager.shared.selectedPeripheral?.state == .connected,
                                IWownManager.shared.writeCharacter != nil else {
                                    return
                            }
                            let environment = WatchConfiguration.Environment(
                                watchConfigurator: WatchConfigurator(
                                    watchCommander: WatchCommander(),
                                    watchName: connectedDeviceName
                                )
                            )
                            present(
                                Widget(
                                    viewModel: .init(
                                        initial: .init(watchConfigurator: environment.watchConfigurator),
                                        environment: environment, reducer: WatchConfiguration.reducer
                                    ),
                                    render: { context in WatchConfigurationView(context: context) }
                                )
                            )
                            break
                        case 2: // Firmware
                            let alertTitle = NSLocalizedString("SORRY", comment: "")
                            let alertMessage = NSLocalizedString("NOT_IMPLEMENTED", comment: "")
                            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                            break
                        case 3:
                            IWownManager.shared.disconnect()
                            cbPeripherals = []
                            setupBLE()
                            tableView.reloadData()
                            break
                        default:
                            break
                    }
                }
                break
            case optionalSection:
                let task = OCKStore.OptionalTasks.availableCases[indexPath.row]
                Log.debug("Clicked \(task)")
                break
            case aboutSection:
                switch indexPath.row {
                    case ratingRow: // Rate
                        let urlString = "https://apps.apple.com/app/id1502988848?action=write-review"
                        guard let writeReviewURL = URL(string: urlString)
                        else {
                            Log.error("Expected a valid URL, not \(urlString)")
                            return
                        }
                        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                        break
                    case scienceRow: // Science
                        let viewController = ORKTaskViewController(task: infoTask, taskRun: nil)
                        viewController.delegate = self
                       // let navigationController = UINavigationController(rootViewController: viewController)
                        present(viewController, animated: true, completion: nil)
                        break
                    case qaRow: // Q&A
                        let vc = PDFViewController()
                        vc.name = "qa"
                        vc.title = "Q&A"
                        let nav = UINavigationController(rootViewController: vc)
                        self.present(nav, animated: true, completion: nil)
                        break
                    case manualRow: // User Manual
                        let vc = PDFViewController()
                        vc.name = "manual"
                        vc.title = "User Manual"
                        let nav = UINavigationController(rootViewController: vc)
                        self.present(nav, animated: true, completion: nil)
                        break
                    case factsRow: // Fact Sheet
                        let vc = PDFViewController()
                        vc.name = "facts"
                        vc.title = "Fact Sheet"
                        let nav = UINavigationController(rootViewController: vc)
                        self.present(nav, animated: true, completion: nil)
                        break
                    case vagusAccountRow: // Vagus Cloud
                        let urlString = Api.baseURL
                        guard let writeReviewURL = URL(string: urlString)
                        else {
                            Log.error("Expected a valid URL, not \(urlString)")
                            return
                        }
                        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
                        break
                    case contactRow: // Contact
                        let vc = ContactViewController()
                        let nav = UINavigationController(rootViewController: vc)
                        self.present(nav, animated: true, completion: nil)
                        break
                    default:
                        break
                }
                break
            case recordsSection:
                Log.debug("Clicked health record")
                let records = Config().healthRecords
                if indexPath.row == records?.count {
                    let addRecordViewController = AddRecordViewController()
                    navigationController?.pushViewController(addRecordViewController, animated: true)
                } else if let record = records?[indexPath.row]  {
                    switch record.type {
                        case .symbiome:
                            let microbiomeViewController = MicrobiomeViewController()
                            navigationController?.pushViewController(microbiomeViewController, animated: true)
                        default:
                            break
                    }
                }
                break
            default:
                break
        }
    }

    func resetPassword() {

        guard let email = config.userEmail else {
            return
        }

        Api.forgot(email: email) { (data, error) in
            DispatchQueue.main.async {
                if let error = error {
                    Log.error("\(error)")
                    let alertTitle = NSLocalizedString("ERROR", comment: "")
                    let alertMessage = NSLocalizedString("\(error)", comment: "")
                    let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else if let data = data {
                    let decoder = JSONDecoder()
                    if let response = try? decoder.decode(ForgotResponse.self, from: data) {
                        if let errors = response.errors, let msg = errors.email.first {
                            let alertTitle = NSLocalizedString("ERROR", comment: "")
                            let alertMessage = NSLocalizedString(msg, comment: "")
                            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            let message = response.message
                            let alertTitle = NSLocalizedString("PASSWORD_RECOVERY", comment: "")
                            let alertMessage = NSLocalizedString(message, comment: "")
                            let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
}

extension AccountSettingsViewController: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .resetting:
            Log.debug("Connection with the system service was momentarily lost. Update imminent")
        case .unsupported:
            Log.debug("Platform does not support the Bluetooth Low Energy Central/Client role")
        case .unauthorized:
            if #available(iOS 13.0, *) {

            } else {
                switch central.authorization {
                case .restricted:
                    Log.debug("Bluetooth is restricted on this device")
                case .denied:
                    Log.debug("The application is not authorized to use the Bluetooth Low Energy role")
                default:
                    Log.debug("Something went wrong. Cleaning up cbManager")
                }
            }
        case .poweredOff:
            self.checkBluetooth(isON: false)
            Log.debug("Bluetooth is currently powered off")
        case .poweredOn:
            Log.debug("Starting cbManager")
            self.scanDevice()
        default:
            Log.debug("Cleaning up cbManager")
        }
    }

    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        Log.debug("connectionEventDidOccur for peripheral: \(peripheral.name)")
        switch event {
        case .peerConnected:
            Log.debug("Peer \(String(describing: peripheral.name)) connected")
            //cbPeripherals.append(peripheral)
        case .peerDisconnected:
            Log.debug("Peer \(String(describing: peripheral.name)) disconnected!")
        default:
            Log.debug("Peer remove \(String(describing: peripheral.name)) ")
            if let idx = cbPeripherals.firstIndex(where: { $0 === peripheral }) {
                cbPeripherals.remove(at: idx)
            }
        }
        tableView.reloadData()
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !cbPeripherals.contains(peripheral), let name = peripheral.name , name.contains("ECG-") {
            Log.debug("Add peripheral named \(name)")
            cbPeripherals.append(peripheral)
            tableView.reloadData()
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        Log.debug("peripheral: \(String(describing: peripheral.name)) connected")
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Log.debug("peripheral: \(String(describing: peripheral.name)) failed to connect")
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Log.debug("peripheral: \(String(describing: peripheral.name)) disconnected")
    }

}

extension AccountSettingsViewController: ToggleDelegate {

    func didToggle(_ cell: UITableViewCell, isOn: Bool) {
        Log.debug("ToggleDelegate")
        guard let indexPath = tableView.indexPath(for: cell), indexPath.section == 2 else {
            Log.error("Could not find cell")
            return
        }
        let tasks = OCKStore.OptionalTasks.availableCases
        let task = tasks[indexPath.row]
        Log.debug("About to toggle \(task) isON \(task.isON)")
        task.toogle()
        Log.debug("After isON \(task.isON)")
        renderDelegate?.didUpdate()
        Log.debug("AccountSettingsViewController didToggle \(task.title) \(task.isON)")
    }

}

extension AccountSettingsViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true, completion: nil)

        guard let originalImage = (info[.originalImage] as? UIImage), let image = originalImage.upOrientationImage() else {
            Log.error("Error picking image")
            return
        }

        portrait = image

        if let path = image.persist() {
            config.portraitPath = path
            Log.verbose("info \(info) \(path)")
            tableView.reloadData()
            Api.setPortrait(image: image) { (response, error) in
                if let error = error {
                    Log.error("Portrait \(error)")
                } else if let response = response {
                    if let str = String(data: response, encoding: .utf8) {
                        Log.debug("Portait \(str)")
                    }
                } else {
                    Log.error("Portrait no response")
                }
            }
        }
    }
}


extension AccountSettingsViewController: ORKTaskViewControllerDelegate {

    func taskViewController(_ taskViewController: ORKTaskViewController, viewControllerFor step: ORKStep) -> ORKStepViewController? {
        return nil
    }

    public func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
    }

    public func taskViewController(_ taskViewController: ORKTaskViewController, shouldPresent step: ORKStep) -> Bool {
        return true
    }

    public func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {

        switch reason {
            case .completed:
                dismiss(animated: true, completion: nil)
            case .discarded, .failed, .saved:
                dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
}
