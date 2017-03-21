//
//  SetViewController.swift
//  ostest
//
//  Created by Maninder Soor on 28/02/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import Foundation
import AlamofireImage

/**
 Shows the list of Sets
 */
final class SetViewController : UIViewController {
    
    /// Table View
    @IBOutlet private weak var tblView : UITableView?
    
    /// Activity loader for the table vie
    @IBOutlet private weak var activity : UIActivityIndicatorView?
    
    @IBOutlet private weak var filterBarBtn: UIBarButtonItem!
    
    let viewModelController = SetViewModelController()
    
    fileprivate var isDataLoading = true
    fileprivate var footerView: UIView?

    /**
     Setup the view
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Setup view for loading
        self.setupLoading(isLoading: true, withDuration: 0)
        
        /// Hide empty cells
        self.tblView?.tableFooterView = UIView.init(frame: CGRect.zero)
        
        /// Create table footer view
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 44.0))
        footerView?.addSubview(activityIndicator)
        
        activityIndicator.center = (footerView?.center)!
        
        /// Show or Hide Filter bar button
        showFilterButton()
        
        /// Call to setup the data
        self.setupData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /// Set view title
        self.title = NSLocalizedString("Home", comment: "Set VC")
    }
    
    /**
     Setup loading
     
     - parameter isLoading
     */
    func setupLoading (isLoading : Bool, withDuration duration: TimeInterval) {
        UIView.animate(withDuration: duration, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.activity?.alpha = isLoading ? 1.0 : 0.0
            self.tblView?.alpha = isLoading ? 0.0 : 1.0
        }) { (_) in }
    }
    
    
    /**
     Show filter br button
     */
    func showFilterButton() {
        let episodesCount = viewModelController.episodesCount
        let dividersCount = viewModelController.dividersCount
        
        if episodesCount > 0 && dividersCount > 0 {
            /// Show Filter bar button
            filterBarBtn.tintColor = .white
            filterBarBtn.isEnabled = true
        } else {
            /// Hide Filter bar button
            filterBarBtn.tintColor = .clear
            filterBarBtn.isEnabled = false
        }
    }
    
    /**
     Set's up the data for the table view
     */
    func setupData () {
        guard let tableView = tblView else {
            isDataLoading = false
            return
        }
        
        viewModelController.loadHomeSet({ [weak self] (isLoading, insertions, modifications, deletions) in

            /// Show or Hide loading
            self?.setupLoading(isLoading: isLoading, withDuration: 0.3)
            self?.showFilterButton()
            
            guard let _ = insertions, let _ = modifications, let _ = deletions else {
                /// Reload table data
                tableView.reloadData()
                
                return
            }
            
            self?.isDataLoading = isLoading

            /// Update table view rows
            tableView.beginUpdates()
            
            if let insertions = insertions, insertions.count > 0  {
                tableView.insertRows(at: insertions, with: .none)
            }
            
            if let deletions = deletions, deletions.count > 0  {
                tableView.deleteRows(at: deletions, with: .none)
            }
            
            if let modifications = modifications, modifications.count > 0  {
                tableView.reloadRows(at: modifications, with: .none)
            }
            
            tableView.endUpdates()
            
        }) { [weak self] (errorMessage) in
            /// Hide loading
            self?.setupLoading(isLoading: false, withDuration: 0.3)
            self?.isDataLoading = false
            
            self?.showFilterButton()
            
            /// Display an error message
            if let errorMessage = errorMessage {
                /// By alert view (if there are data)
                if self?.viewModelController.episodesCount ?? 0 > 0 {
                    let alertVC = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: errorMessage, preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertVC.addAction(okAction)
                    
                    self?.present(alertVC, animated: true, completion: nil)
                }
                /// By 'No Data' custom label view (if no data)
                else {
                    let lblRect = CGRect(
                        origin: CGPoint(x: 0, y: 0),
                        size: tableView.bounds.size
                    )
                    
                    let errorMsgLbl = NoDataLabel.init(withFrame: lblRect, message: errorMessage)
                    tableView.backgroundView = errorMsgLbl
                    tableView.separatorStyle = .none
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFilterOptions" {
            
            if let nc = segue.destination as? UINavigationController, let vc = nc.viewControllers[0] as? SetFiltersListViewController {
                vc.viewModelController = viewModelController
                vc.filterDidChange = { [weak self] () in
                    guard let tableView = self?.tblView else { return }
                    tableView.reloadData()
                    tableView.setContentOffset(.zero, animated: false)
                }
            }
            
        } else if segue.identifier == "showEpisodeDetails" {
            
            if let vc = segue.destination as? EpisodeDetailsViewController {
                var episode: Episode?
                
                /// Get selected episode
                if let indexPath = tblView?.indexPathForSelectedRow {
                    episode = viewModelController.viewModel(at: (indexPath as NSIndexPath).row)
                    vc.theEpisode = episode
                }
                
            }
            
        }
    }
    
    /**
     Show activity indicator view when data is still fetching from API
     */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if isDataLoading {
            tblView?.tableFooterView = footerView
        } else {
            tblView?.tableFooterView = nil
        }
    }
}


/**
 Table View datasource
 */
extension SetViewController : UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numOfRows = viewModelController.episodesCount
        
        if numOfRows == 0 && !isDataLoading {
            /// Display an empty message
            let lblRect = CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: view.bounds.size
            )
            
            let emptyMsgLbl = NoDataLabel.init(withFrame: lblRect, message: NSLocalizedString("No episodes found", comment: "Set VC"))
            tableView.backgroundView = emptyMsgLbl
            tableView.separatorStyle = .none
        } else {
            tableView.backgroundView = nil
            tableView.separatorStyle = .singleLine
        }
        
        return numOfRows
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        /// Remove seperator inset
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = .zero
        }
        
        /// Prevent the cell from inheriting the table view's margin settings
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        /// Explictly set your cell's layout margins
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = .zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// Get the cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SetViewCell.identifier) as? SetViewCell else {
            return UITableViewCell()
        }
        
        let episode = viewModelController.viewModel(at: (indexPath as NSIndexPath).row)
        cell.viewModel = episode
        
        cell.btnnFavouriteTapBlock = {(isFavorite) in
            if let isFavorite = isFavorite {
                self.viewModelController.addToFavorite(for: episode, isFavorite: isFavorite)
            }
        }
        
        /// Return the cell
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        /// Default
        return 180.0
    }
}


/**
 Table view delegate
 */
extension SetViewController : UITableViewDelegate {
    
}
