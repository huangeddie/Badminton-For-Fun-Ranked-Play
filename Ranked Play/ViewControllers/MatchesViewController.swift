//
//  SecondViewController.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/8/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class MatchesViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Watch for any changes to the context
        NotificationCenter.default.addObserver(self, selector: #selector(receivedContextChangedNotification), name: .NSManagedObjectContextDidSave, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBAction
    @IBAction func newMatch(_ sender: Any) {
        let activePlayers = PlayerRecorder.getAllPlayers(active: true)
        let count = activePlayers.count
        if count >= 2 {
            
            // Get two random people
            let p1 = Int(arc4random_uniform(UInt32(count)))
            var p2 = Int(arc4random_uniform(UInt32(count)))
            while p2 == p1 {
                p2 = Int(arc4random_uniform(UInt32(count)))
            }
            
            let playerOne = activePlayers[p1]
            let playerTwo = activePlayers[p2]
            
            guard let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "new_match_nav") as? UINavigationController else {
                fatalError()
            }
            guard let newMatchVC = navVC.topViewController as? EditMatchViewController else {
                fatalError()
            }
            
            
            newMatchVC.playerOne = playerOne
            newMatchVC.playerTwo = playerTwo
            
            present(navVC, animated: true)
        }
    }
    
    // MARK: Private Functions
    @objc
    private func receivedContextChangedNotification() {
        tableView.reloadData()
    }
}


extension MatchesViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let matches = MatchRecorder.getAllMatches()
            return matches.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "match_cell") as? MatchTableViewCell else {
            fatalError()
        }
        
        let matches = MatchRecorder.getAllMatches()
        let row = indexPath.row
        let match = matches[row]
        
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        
        var playerOne: Player?
        var playerTwo: Player?
        
        if let idOne = match.playerOneID {
            playerOne = PlayerRecorder.getPlayer(withID: idOne)
        }
        if let idTwo = match.playerTwoID {
            playerTwo = PlayerRecorder.getPlayer(withID: idTwo)
        }
        
        guard let date = match.date else {
            fatalError()
        }
        cell.date.text = df.string(from: date)
        cell.nameOne.text = playerOne?.name
        cell.nameTwo.text = playerTwo?.name
        cell.scoreOne.text = "\(match.scoreOne)"
        cell.scoreTwo.text = "\(match.scoreTwo)"
        
        return cell
    }
}
