//
//  HashtagViewController.swift
//  Trilly
//
//  Created by Daniel Soto on 10/5/17.
//  Copyright © 2017 Tres Astronautas. All rights reserved.
//

import UIKit
import MBProgressHUD

class HashtagViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var backB: UIButton!
    @IBOutlet weak var stickyGradient: UIView!
    @IBOutlet weak var stickyBackground: UIView!
    @IBOutlet weak var stickyLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var hashtagPointsLabel: UILabel!
    @IBOutlet weak var myPointsLabel: UILabel!
    @IBOutlet weak var myKMLabel: UILabel!
    @IBOutlet weak var goalTable: UITableView!
    @IBOutlet weak var goalsB: UIButton!
    @IBOutlet weak var rankingB: UIButton!
    @IBOutlet weak var tabBackground: UIView!
    
    @IBOutlet weak var mainHeigth: NSLayoutConstraint!
    @IBOutlet weak var goalHeigth: NSLayoutConstraint!
    
    private var currentTab = 0
    
    // Ranking only
    @IBOutlet weak var userRankingCell: UIView!
    
    
    // Data
    private var hashtag: Hashtag!
    private var userRanking: Int = Int.max
    private var count = 0
    
    public class func showHashtag(hashtag: String, parent: UIViewController) {
        let st = UIStoryboard(name: "Hashtag", bundle: nil)
        let hashView = st.instantiateViewController(withIdentifier: "Hashtag") as! HashtagViewController
        Hashtag.withID(id: hashtag) { (ht) in
            guard ht != nil else { return }
            hashView.hashtag = ht!
            parent.showDetailViewController(hashView, sender: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = self.view.addGradientBackground(Trilly.UI.mainColor, .white, start: 0.4, end: 0.6)
        tabBackground.backgroundColor = Trilly.UI.secondColor
        adjustConstraints()
        
        self.mainLabel.text = "#\(self.hashtag.name!.lowercased())"
        self.stickyLabel.text = "#\(self.hashtag.name!.lowercased())"
        self.hashtagPointsLabel.text = String(format: "%.0f pts.", self.hashtag.points ?? 0)
        
        let _ = hashtag.goals(callback: { (done) in
            if done {
                self.count = self.hashtag.goals()?.count ?? 0
                self.goalTable.reloadData()
            }
        })
        let _ = hashtag.users(callback: { (done) in
            if done {
                for (index, user) in (self.hashtag.users() ?? []).enumerated() {
                    if user.name ?? "" == User.current!.name! {
                        self.userRanking = index
                        (self.userRankingCell.viewWithTag(11) as? UILabel)?.text = "#\(self.userRanking + 1)"
                        self.myPointsLabel.text = String(format: "%.0f pts.", user.points ?? 0)
                        self.myKMLabel.text = String(format: "%.0f Km", user.km ?? 0)
                        (self.userRankingCell.viewWithTag(12) as? UILabel)?.text = "\(user.name!) (Tú)"
                        
                    }
                }
            }
        })
        
        if Trilly.Network.offline {
            self.showAlert(title: "Sin conexión", message: "Algunos datos pueden estar desactualizados o no mostrarse porque estás sin conexión.", closeButtonTitle: "Entendido.")
        }
        // Load user ranking
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .lightContent
        self.adjustConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIApplication.shared.statusBarStyle = .default
    }
    
    
    func adjustConstraints() {
        switch self.currentTab {
        case 0:
            let exceded = CGFloat((count * 250))
            mainHeigth.constant = max(330 + exceded, self.view.bounds.height)
            goalHeigth.constant = exceded
        case 1:
            let exceded = CGFloat((count * 100))
            mainHeigth.constant = max(330 + exceded, self.view.bounds.height)
            goalHeigth.constant = exceded
        default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        stickyBackground.addGradientBackground(Trilly.UI.mainColor, Trilly.UI.secondColor)
        stickyGradient.addGradientBackground(Trilly.UI.mainColor, Trilly.UI.secondColor)
        userRankingCell.addGradientBackground(UIColor.init(white: 1, alpha: 0), .white, end: 0.5)
        userRankingCell.viewWithTag(1)?.addNormalShadow()
        userRankingCell.viewWithTag(2)?.backgroundColor = Trilly.UI.contrastColor
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // Table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch currentTab {
        case 0:
            return 250
        case 1:
            return 100
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch currentTab {
        case 0:
            let cellUI = tableView.dequeueReusableCell(withIdentifier: "GoalCell", for: indexPath) as! TrillyCell
            let goal = (self.hashtag.goals() ?? [])[indexPath.row]
            cellUI.uiUpdates = {(cell) in
                cell.viewWithTag(1)?.addNormalShadow()
                (cell.viewWithTag(21) as? UILabel)?.text = "\(goal.name!)"
                let dif = (goal.points ?? 0) - (self.hashtag.points ?? 0)
                if dif < 0 {
                    // Reto logrado Gold
                    (cell.viewWithTag(20) as? UIImageView)?.image = UIImage(named: "GoalGreen")
                    (cell.viewWithTag(31) as? UILabel)?.text = "¡Premio redimido!"
                    (cell.viewWithTag(30) as? UIImageView)?.image = UIImage(named: "TrophyGold")
                } else {
                    // Reto por logar Gray
                    (cell.viewWithTag(20) as? UIImageView)?.image = UIImage(named: "GoalGray")
                    (cell.viewWithTag(31) as? UILabel)?.text = String(format: "%.0f pts. para redimir el premio", dif)
                    (cell.viewWithTag(30) as? UIImageView)?.image = UIImage(named: "TrophyGray")
                }
            }
            return cellUI
        case 1:
            let cellUI = tableView.dequeueReusableCell(withIdentifier: "RankingCell", for: indexPath) as! TrillyCell
            cellUI.uiUpdates = {(cell) in
                cell.viewWithTag(1)?.addNormalShadow()
                cell.viewWithTag(2)?.addGradientBackground(Trilly.UI.secondColor, Trilly.UI.mainColor, horizontal: true, diagonal: true)
                let rank = (self.hashtag.users() ?? [])[indexPath.row]
                (cell.viewWithTag(11) as? UILabel)?.text = "#\(indexPath.row + 1)"
                (cell.viewWithTag(21) as? UILabel)?.text = "\(rank.name!)"
                (cell.viewWithTag(22) as? UILabel)?.text = String(format: "%.0f", rank.points ?? 0)
                if indexPath.row == self.userRanking {
                    cell.viewWithTag(3)?.backgroundColor = Trilly.UI.contrastColor
                } else {
                    cell.viewWithTag(3)?.backgroundColor = .clear
                }
            }
            return cellUI
        default:
            return UITableViewCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if currentTab == 1 {
            // Users
            MBProgressHUD.showAdded(to: self.view, animated: true)
            if let user = (self.hashtag.users() ?? [])[indexPath.row].uid {
                MBProgressHUD.hide(for: self.view, animated: true)
                User.withID(id: user, callback: { (u) in
                    if u != nil {
                        ProfileViewController.showProfile(user: u!, onViewController: self)
                    }
                })
            }
        } else {
            // Info Goal
            let goal = self.hashtag.goals()![indexPath.row]
            self.showAlert(title: goal.name ?? "Meta Trilly", message: goal.descriptionT ?? "No hemos podido cargar la descripción de esta meta.", closeButtonTitle: "Genial")
        }
    }
    
    // Scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let stickiness = scrollView.contentOffset.y / 100
        let revealing = stickiness > 1 ? 1 : stickiness
        self.stickyLabel.alpha = revealing
        self.mainLabel.alpha = 1 - revealing
        self.hashtagPointsLabel.alpha = 1 - revealing
        
        if (revealing == 1) {
            let gradientness = (scrollView.contentOffset.y - 120) / 50
            let gradient = gradientness > 1 ? 1 : gradientness
            self.stickyGradient.alpha = gradient
        } else {
            self.stickyGradient.alpha = 0
        }
        
        if currentTab == 1 {
            loadUserRankingUI()
        }
        
    }
    
    // Tabbing
    @IBAction func loadGoals(_ sender: Any) {
        if currentTab != 0 {
            currentTab = 0
            self.goalsB.isSelected = true
            self.rankingB.isSelected = false
            self.count = self.hashtag.goals()?.count ?? 0
            self.adjustConstraints()
            self.view.layoutIfNeeded()
            self.goalTable.reloadSections(IndexSet(integer: 0), with: .right)
            UIView.animate(withDuration: 0.1, animations: {
                self.userRankingCell.alpha = 0
            })
        }
    }
    
    @IBAction func loadRanking(_ sender: Any) {
        if currentTab != 1 {
            currentTab = 1
            self.goalsB.isSelected = false
            self.rankingB.isSelected = true
            self.count = self.hashtag.users()?.count ?? 0
            self.adjustConstraints()
            self.view.layoutIfNeeded()
            self.goalTable.reloadSections(IndexSet(integer: 0), with: .left)
            loadUserRankingUI()
        }
    }
    
    // Ranking animation:
    func loadUserRankingUI() {
        guard userRanking != Int.max else { return }
        let needed = CGFloat(295 + (userRanking + 1)*100)
        if needed > scrollView.contentOffset.y + scrollView.bounds.height {
            UIView.animate(withDuration: 0.1, animations: {
                self.userRankingCell.alpha = 1
            })
        } else {
            UIView.animate(withDuration: 0.1, animations: {
                self.userRankingCell.alpha = 0
            })
        }
    }
    
}
