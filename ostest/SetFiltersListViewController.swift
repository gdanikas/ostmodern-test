//
//  SetFiltersListViewController.swift
//  ostest
//
//  Created by George Danikas on 14/03/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import UIKit
import RealmSwift

final class SetFiltersListViewController: UITableViewController {
    
    fileprivate let filters : List<Divider> = {
        return Database.instance.fetchDividers()
    }()
    
    var viewModelController: SetViewModelController?
    var filterDidChange: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Hide empty cells
        tableView.tableFooterView = UIView.init(frame: CGRect.zero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /// Get the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "SetFilterViewCellID", for: indexPath)
        
        let divider = filters[indexPath.row]
        
        if let label = cell.viewWithTag(1) as? UILabel {
            label.text = divider.title
        }
        
        cell.accessoryType = .none
        
        if let viewModel = viewModelController, let selectedDivider = viewModel.selectedDivider, divider == selectedDivider {
            cell.accessoryType = .checkmark
            
            /// Set row selected
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }

        return cell
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        if cell.accessoryType == .checkmark {
            cell.accessoryType = .none
            tableView.deselectRow(at: indexPath, animated: false)
        } else {
            cell.accessoryType = .checkmark
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        
        cell.accessoryType = .none
    }
    
    // MARK: - Actions
    
    @IBAction func okBtnPressed(_ sender: Any) {
        var selectedDivider: Divider?
        
        /// Get selected filter
        if let indexPath = tableView.indexPathForSelectedRow {
            selectedDivider = filters[indexPath.row]
        }
        
        if let viewModel = viewModelController {
            viewModel.setDivider(divider: selectedDivider)
        }
        
        if let block = filterDidChange {
            block()
        }
        
        dismiss(animated: true, completion: nil)

    }
}
