//
//  ObserverMenuController.swift
//  Graviton
//
//  Created by Sihao Lu on 2/19/17.
//  Copyright © 2017 Ben Lu. All rights reserved.
//

import QuartzCore
import SpaceTime
import UIKit

private let buttonCellId = "buttonCell"
private let detailCellId = "detailCell"
private let toggleCellId = "toggleCell"
private let locationCellId = "locationCell"
private let headerFooterId = "headerFooter"

class ObserverMenuController: ObserverTableViewController {
    var menu: Menu!

    private var locationSubId: SubscriptionUUID!
    private var indexPathsToDisable = Set<IndexPath>()
    private var selectedCity: City?

    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true

        tableView.register(MenuCell.self, forCellReuseIdentifier: detailCellId)
        tableView.register(MenuToggleCell.self, forCellReuseIdentifier: toggleCellId)
        tableView.register(MenuButtonCell.self, forCellReuseIdentifier: buttonCellId)
        tableView.register(MenuLocationCell.self, forCellReuseIdentifier: locationCellId)

        locationSubId = LocationManager.default.subscribe(didUpdate: { [weak self] _ in
            self?.tableView.reloadRows(at: self!.menu.indexPathsNeedsReloadUponLocationUpdate, with: .none)
        })

        setUpBlurredBackground()

        let behaviors = menu.registerAllConditionalDisabling()
        behaviors.forEach { [weak self] behavior in
            let indexPath = self!.menu.indexPath(for: behavior.setting)!
            if behavior.condition == Settings.default[behavior.dependent] {
                self!.indexPathsToDisable.insert(indexPath)
            } else {
                self!.indexPathsToDisable.remove(indexPath)
            }
            Settings.default.subscribe(setting: behavior.dependent, object: self!, valueChanged: { [weak self] _, newValue in
                if behavior.condition == newValue {
                    self!.indexPathsToDisable.insert(indexPath)
                } else {
                    self!.indexPathsToDisable.remove(indexPath)
                }
                self!.tableView.reloadRows(at: [indexPath], with: .automatic)
            })
            Settings.default.subscribe(setting: behavior.setting, object: self!, valueChanged: { [weak self] _, newValue in
                if let cell = self!.tableView.cellForRow(at: indexPath) as? MenuToggleCell, cell.toggle.isEnabled == newValue {
                    self!.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            })
        }

        selectedCity = CityManager.default.currentlyLocatedCity

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonTapped(sender:)))
        title = menu.title
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Settings.default.unsubscribe(object: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let volatileIndexPaths = self.menu?.volatileIndexPaths {
            tableView.reloadRows(at: volatileIndexPaths, with: .none)
        }
    }

    deinit {
        if let locationSubId = locationSubId {
            LocationManager.default.unsubscribe(locationSubId)
        }
    }

    @objc func doneButtonTapped(sender _: UIBarButtonItem) {
        CityManager.default.currentlyLocatedCity = selectedCity
        navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Menu delivered actions

    @objc func jumpToCelestialPoint(_ userInfo: Any?) {
        guard let dict = userInfo as? [String: Double] else { fatalError() }
        let coordinate = EquatorialCoordinate(dictionary: dict)
        navigationController?.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "jumpToCelestialPoint"), object: self, userInfo: ["content": coordinate])
    }

    @objc func jumpToDirection(_ userInfo: Any?) {
        guard let dict = userInfo as? [String: Double] else { fatalError() }
        let coordinate = HorizontalCoordinate(dictionary: dict)
        navigationController?.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "jumpToDirection"), object: self, userInfo: ["content": coordinate])
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return menu.sections.count
    }

    override func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menu.sections[section].items.count
    }

    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = menu[indexPath]
        cell.backgroundColor = UIColor.clear
        if let menuCell = cell as? MenuCell {
            menuCell.textLabelLeftInset = item.image == nil ? 21 : 60
        }
        cell.imageView?.image = item.image
        switch item.type {
        case .detail, .multipleSelect:
            cell.textLabel?.text = item.text
            cell.accessoryType = .disclosureIndicator
        case .toggle:
            cell.textLabel?.text = item.text
            let toggleCell = cell as! MenuToggleCell
            let shouldDisable = indexPathsToDisable.contains(indexPath)
            toggleCell.textLabel?.isEnabled = !shouldDisable
            toggleCell.toggle.isEnabled = !shouldDisable
        case .button:
            cell.textLabel?.text = item.text
        case .external:
            break
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = menu[indexPath]
        let cell: UITableViewCell
        switch item.type {
        case .toggle(let binding, _):
            cell = tableView.dequeueReusableCell(withIdentifier: toggleCellId, for: indexPath)
            cell.selectionStyle = .none
            let toggleCell = cell as! MenuToggleCell
            toggleCell.binding = binding
        case .detail, .multipleSelect:
            cell = tableView.dequeueReusableCell(withIdentifier: detailCellId, for: indexPath)
        case let .button(key, info):
            cell = tableView.dequeueReusableCell(withIdentifier: buttonCellId, for: indexPath)
            let buttonCell = cell as! MenuButtonCell
            buttonCell.button.setTitle(item.text, for: .normal)
            buttonCell.key = key
            buttonCell.userInfo = info
            buttonCell.handler = { [weak self] key, _ in
                self?.performSelector(onMainThread: Selector(key + ":"), with: info, waitUntilDone: false)
            }
        case let .external(identifier, _):
            if identifier == "location" {
                cell = MenuLocationCell(style: .subtitle, reuseIdentifier: locationCellId)
                let locationCell = cell as! MenuLocationCell
                locationCell.textLabel?.text = cityDescriptiveTitle
                locationCell.detailTextLabel?.text = cityDescriptiveSubtitle
                locationCell.accessoryType = .disclosureIndicator
            } else {
                fatalError("Unrecognized external menu identifier")
            }
        }
        return cell
    }

    override func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = menu[indexPath]
        if case let .detail(submenu) = item.type {
            // transition to submenu
            let subMenuController = ObserverMenuController(style: .plain)
            subMenuController.menu = submenu
            navigationController?.pushViewController(subMenuController, animated: true)
        } else if case let .multipleSelect(mulSel) = item.type {
            // transition to submenu
            let subMenuController = ObserverMenuMultipleSelectController(style: .plain)
            subMenuController.multipleSelect = mulSel
            navigationController?.pushViewController(subMenuController, animated: true)
        } else if case let .external(identifier, _) = item.type, identifier == "location" {
            let subMenuController = ObserverLocationMenuController(style: .plain)
            subMenuController.delegate = self
            subMenuController.selectedCity = selectedCity
            navigationController?.pushViewController(subMenuController, animated: true)
        }
    }

    override func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if menu.sections[section].name != nil {
            return 24
        } else {
            return 0
        }
    }

    override func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HeaderView()
        header.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.3031194982)
        header.textLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        header.textLabel.text = menu.sections[section].name
        return header
    }

    override func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = menu[indexPath]
        switch item.type {
        case let .external(identifier, _) where identifier == "location":
            return 60
        default:
            return 44
        }
    }
}

extension ObserverMenuController: ObserverLocationMenuControllerDelegate {
    func observerLocationMenuController(_: ObserverLocationMenuController, cityDidChange city: City?) {
        selectedCity = city
    }
}

extension ObserverMenuController {
    var cityDescriptiveTitle: String {
        if let city = selectedCity {
            return city.name
        }
        return "Current Location"
    }

    var cityDescriptiveSubtitle: String {
        if let city = selectedCity {
            if city.iso3 == "USA" {
                return "\(city.country), \(city.provinceAbbreviation!)"
            }
            return city.country
        }
        if let coordinate = LocationManager.default.content?.coordinate {
            let coordFormatter = CoordinateFormatter()
            return coordFormatter.string(for: coordinate)!
        }
        return "Unknown"
    }
}
