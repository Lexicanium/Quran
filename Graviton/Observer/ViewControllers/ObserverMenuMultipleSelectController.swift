//
//  ObserverMenuMultipleSelectController.swift
//  Graviton
//
//  Created by Sihao Lu on 6/10/17.
//  Copyright © 2017 Ben Lu. All rights reserved.
//

import UIKit

private let checkableCellId = "checkableCell"
class ObserverMenuMultipleSelectController: ObserverTableViewController {
    var multipleSelect: MultipleSelect!

    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
        setUpBlurredBackground()
        title = multipleSelect.text
        tableView.register(MenuCell.self, forCellReuseIdentifier: checkableCellId)
        Settings.default.subscribe(settings: [.groundTexture, .antialiasingMode], object: self) { [weak self] _, _ in
            self!.tableView.reloadData()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Settings.default.unsubscribe(object: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return multipleSelect.options.count
    }

    override func tableView(_: UITableView, willDisplay cell: UITableViewCell, forRowAt _: IndexPath) {
        if let menuCell = cell as? MenuCell {
            menuCell.textLabelLeftInset = 21
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: checkableCellId, for: indexPath)
        cell.backgroundColor = UIColor.clear
        let selection = multipleSelect.options[indexPath.row]
        cell.textLabel?.text = selection.1
        if multipleSelect.selectedIndex == indexPath.row {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selection = multipleSelect.options[indexPath.row]
        Settings.default[multipleSelect.setting] = selection.0
    }
}
