//
//  EpisodeDetailsViewController.swift
//  ostest
//
//  Created by George Danikas on 15/03/2017.
//  Copyright © 2017 Maninder Soor. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

final class EpisodeDetailsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView?
    
    var theEpisode: Episode!
    fileprivate var isVideoShown: Bool = false
    fileprivate var tableHeaderView: EpisodeDetailsHeaderView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// Self-sizing cell
        tableView?.estimatedRowHeight = 80
        tableView?.rowHeight = UITableViewAutomaticDimension
        
        /// Set view title
        self.title = theEpisode.title
        
        /// Hide back button title
        navigationController?.navigationBar.topItem?.title = ""
        
        /// Register table header
        tableView?.register(UINib(nibName: "EpisodeDetailsHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: EpisodeDetailsHeaderView.identifier)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        guard let tableView = self.tableView else {
            return
        }
        
        /// Disable tableView scroll when its content fits on the screen
        if tableView.contentSize.height < tableView.frame.size.height {
            tableView.isScrollEnabled = false
        }
        else {
            tableView.isScrollEnabled = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}


/**
 Table View datasource
 */
extension EpisodeDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: EpisodeDetailsHeaderView.identifier) as? EpisodeDetailsHeaderView else {
            return UIView()
        }
        
        tableHeaderView = headerView
        
        headerView.delegate = self
        headerView.viewModel = theEpisode
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /// Get the cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "EpisodeDetailsViewCellID", for: indexPath)
        
        if let titlbl = cell.viewWithTag(1) as? UILabel {
            titlbl.text = theEpisode.title
        }
        
        if let summaryLbl = cell.viewWithTag(2) as? UILabel {
            summaryLbl.text = theEpisode.summary
        }
        
        /// Return the cell
        return cell
    }
}

/**
 Table view delegate
 */
extension EpisodeDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let aspectRatio = 220.0 / 667.0
        let size = CGFloat(aspectRatio) * UIScreen.main.bounds.size.height
        
        return size
    }
}

/**
 Header view delegate
 */

extension EpisodeDetailsViewController: EpisodeDetailsHeaderViewDelegate {
    func imageFetchedWithSuccess() {
        guard let headerView = tableHeaderView else {
            return
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.playVideo))
        headerView.isUserInteractionEnabled = true
        headerView.addGestureRecognizer(tap)
    }
    
    func playVideo() {
        isVideoShown = false
        
        if !isVideoShown {
            isVideoShown = true
            
            let avPlayer = AVPlayer(url: URL(string: theEpisode.imageURL)!)
            let avPlayerVC = AVPlayerViewController()
            avPlayerVC.player = avPlayer
            
            
            self.present(avPlayerVC, animated: false) {
                avPlayerVC.player?.play()
            }
        }
    }
}
