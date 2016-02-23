//
//  MatesViewController.swift
//  Nooklyn
//
//  Created by Joe Gallo on 9/23/15.
//  Copyright © 2016 Nooklyn. All rights reserved.
//

import UIKit

class MatesViewController: UIViewController, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource,
                           FiltersViewDelegate, SliderTabBarViewDelegate {

    // slider tab bar
    @IBOutlet var sliderTabBarView: SliderTabBarView!
    @IBOutlet var sliderTabBarButton1: UIButton!
    @IBOutlet var sliderTabBarButton2: UIButton!
    @IBOutlet var sliderTabBarInitialConstraint: NSLayoutConstraint!
    
    // grid view
    @IBOutlet var gridCollectionView: UICollectionView!
    @IBOutlet var gridCollectionViewFlowLayout: UICollectionViewFlowLayout!
    var gridCollectionRefreshControl: UIRefreshControl!
    
    // play view
    @IBOutlet var playView: PlayMateView!
    
    // loading view
    @IBOutlet var loadingView: LoadingView!
    
    // login overlay
    @IBOutlet var loginOverlay: UIView!
    @IBOutlet var facebookButton: UIButton!
    
    var mates = [Mate]()
    var lastFetchedMates = [Mate]()
    
    var filters: MateFilters = MateFilters()
    
    // We don't want to get mates from server everytime the view appears, but there's the case
    // where we load the view, user isn't facebook authenticated, and then user goes back to the
    // already loaded view when facebook authenticated, so that's where this variable comes in.
    var matesStillNotLoaded = false
    
    // Use this flag to prevent reloading of play mate when tapping on play view image to go to
    // detail view and then coming back to play view.
    var reloadMates = true
    
    let stopwatch = StopWatch()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // navigation bar
        customizeNavigationBar()
        
        // facebook button
        facebookButton.imageView!.contentMode = UIViewContentMode.ScaleAspectFill
        
        // slider tab bar
        setupSliderTabBarView()
        
        // grid view
        
        // add pull to refresh grid view
        gridCollectionRefreshControl = UIRefreshControl()
        gridCollectionRefreshControl.addTarget(self, action: "getMates", forControlEvents: UIControlEvents.ValueChanged)
        gridCollectionView.addSubview(gridCollectionRefreshControl)
        gridCollectionView.alwaysBounceVertical = true
        
        // play view
        setupPlayView()
        
        // get mates
        if UserData.isFacebookAuthenticated() {
            getMates()
        } else {
            self.matesStillNotLoaded = true
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide/disable bar button items by default
        navigationItem.leftBarButtonItem?.title = ""
        navigationItem.leftBarButtonItem?.enabled = false
        
        navigationItem.rightBarButtonItem?.title = ""
        navigationItem.rightBarButtonItem?.enabled = false
        
        // check if facebook authenticated
        if !UserData.isFacebookAuthenticated() {
            self.loginOverlay.hidden = false
            return
        } else {
            self.loginOverlay.hidden = true
            if self.matesStillNotLoaded {
                self.matesStillNotLoaded = false
                getMates()
            }
        }
        
        // update bar button items
        updateBarButtonItems()
        
        // refresh
        if self.reloadMates {
            applyFilters(self.filters)
        }
        
        self.reloadMates = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        trackViewInGoogleAnalytics("Mates#Grid")
        
        // record initial play view image center
        self.playView.initialImageContainerCenter = self.playView.imageContainerView.center
    }
    
    override func viewDidLayoutSubviews() {
        self.gridCollectionView.reloadData()
        self.playView.layoutIfNeeded()
        self.playView.initialImageContainerCenter = self.playView.imageContainerView.center
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Setup slider tab bar view
    
    func setupSliderTabBarView() {
        self.sliderTabBarView.buttons = [self.sliderTabBarButton1, self.sliderTabBarButton2]
        self.sliderTabBarView.contentViews = [self.gridCollectionView, self.playView]
        self.sliderTabBarView.analyticsViewNames = ["Mates#Grid", "Mates#Play"]
        self.sliderTabBarView.centerConstraints = [sliderTabBarInitialConstraint]
        self.sliderTabBarView.delegate = self
        
        self.sliderTabBarView.initialize()
    }
    
    // MARK: - Setup play view
    
    func setupPlayView() {
        // rotate yay/nay labels
        self.playView.yayLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_4))
        self.playView.nayLabel.transform = CGAffineTransformMakeRotation(CGFloat(M_PI_4))
        
        // adjust position of yay/nay labels
        var yPos: CGFloat!
        if IS_IPHONE4() {
            yPos = CGFloat(10)
        } else if IS_IPHONE5() {
            yPos = CGFloat(30)
        } else if IS_IPHONE6() {
            yPos = CGFloat(53)
        } else {
            yPos = CGFloat(65)
        }
        self.playView.yayLabelY.constant = yPos
        self.playView.nayLabelY.constant = yPos
        self.playView.layoutIfNeeded()
        
        // play view border thickness
        self.playView.borderThickness.constant = 0.5
        
        // adjust play view for smaller screen
        if IS_IPHONE5() || IS_IPHONE4() {
            adjustPlayViewForSmallerScreen()
        }
    }
    
    // MARK: - Adjust play view for smaller screen
    
    func adjustPlayViewForSmallerScreen() {
        var multiplier: CGFloat!
        if IS_IPHONE5() {
            multiplier = 0.45
        } else {
            multiplier = 0.53
        }
        
        // play budget view height
        self.playView.alternateBudgetViewHeight = NSLayoutConstraint(item: self.playView.budgetView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.playView.playBottomView, attribute: NSLayoutAttribute.Height, multiplier:multiplier, constant: 0)
        self.playView.budgetViewHeight.active = false
        self.view.addConstraint(self.playView.alternateBudgetViewHeight)
        
        // play move in view height
        self.playView.alternateMoveInViewHeight = NSLayoutConstraint(item: self.playView.moveInView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.playView.playBottomView, attribute: NSLayoutAttribute.Height, multiplier:multiplier, constant: 0)
        self.playView.moveInViewHeight.active = false
        self.view.addConstraint(self.playView.alternateMoveInViewHeight)
        
        // small button size (ignore/message)
        var smallButtonEdgeLength: CGFloat!
        if IS_IPHONE5() {
            smallButtonEdgeLength = 45
        } else {
            smallButtonEdgeLength = 35
        }
        self.playView.ignoreButtonWidth.constant = smallButtonEdgeLength
        self.playView.ignoreButtonHeight.constant = smallButtonEdgeLength
        
        self.playView.messageButtonWidth.constant = smallButtonEdgeLength
        self.playView.messageButtonHeight.constant = smallButtonEdgeLength
        
        // large button size (favorite)
        var largeButtonEdgeLength: CGFloat!
        if IS_IPHONE5() {
            largeButtonEdgeLength = 90
        } else {
            largeButtonEdgeLength = 70
        }
        self.playView.favoriteButtonWidth.constant = largeButtonEdgeLength
        self.playView.favoriteButtonHeight.constant = largeButtonEdgeLength
    }
    
    // MARK: - Update bar button items
    
    func updateBarButtonItems() {
        // show/enable bar button items
        navigationItem.leftBarButtonItem?.title = "Add"
        navigationItem.leftBarButtonItem?.enabled = true
        
        navigationItem.rightBarButtonItem?.title = "Filter"
        navigationItem.rightBarButtonItem?.enabled = true
        
        navigationItem.titleView?.hidden = false
        
        // change Add button to Update if logged in user has an existing mate post
        if let loggedInAgent = CacheManager.getAgent(UserData.getLoggedInAgentId()!), _ = loggedInAgent.mate {
            navigationItem.leftBarButtonItem?.title = "Update"
        }
    }
    
    // MARK: - Get mates
    
    func getMates() {
        // show loading view
        showLoadingView()
        
        self.stopwatch.start()
        
        ApiManager.getMates() { mates in
            self.mates = mates
            self.lastFetchedMates = mates
            
            // cache mate neighborhoods
            let mateNeighborhoods = Array(Set(mates.map({ $0.neighborhood })))
            CacheManager.saveMateNeighborhoods(mateNeighborhoods)
            
            ApiManager.getMateFavorites(agentId: UserData.getLoggedInAgentId()!) { mateFavorites in
                CacheManager.saveMateFavorites(mateFavorites)
                
                ApiManager.getMateIgnores() { mateIgnores in
                    CacheManager.saveMateIgnores(mateIgnores)
                    
                    self.applyFilters(self.filters)
                    
                    self.stopwatch.stop()
                    self.stopwatch.report(label: "load mates")
                    
                    // remove loading view
                    self.removeLoadingView()
                }
            }
        }
    }
    
    // MARK: - Get mate favorites
    
    func getMateFavorites() -> [MateFavorite] {
        return CacheManager.getMateFavorites()
    }
    
    // MARK: - Get mate ignores
    
    func getMateIgnores() -> [MateIgnore] {
        return CacheManager.getMateIgnores()
    }
    
    // MARK: - Load play mate
    
    func loadPlayMate() {
        // reset play view
        resetPlayView()
        
        // exclude favorited/ignored mates
        let mateFavoriteIds = getMateFavorites().map({ $0.id })
        let mateIgnoreIds = getMateIgnores().map({ $0.id })
        let idsToExclude = mateFavoriteIds + mateIgnoreIds
        
//        print("mate favorite ids: \(mateFavoriteIds)")
//        print("mate ignore ids: \(mateIgnoreIds)")
        
        var subpredicates = [NSPredicate]()
        
        let subpredicate1 = NSPredicate(format: "NOT id IN %@", idsToExclude)
        subpredicates.append(subpredicate1)
        
        // exclude logged in agent's mate post
        let subpredicate2 = NSPredicate(format: "agent.id != %@", UserData.getLoggedInAgentId()!)
        subpredicates.append(subpredicate2)
        
        let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        
        let playMates = self.mates.filter({ predicate.evaluateWithObject($0) })
        
        // do nothing if no remaining mates to play
        if playMates.count == 0 {
            self.playView.outOfMatesLabel?.hidden = false
            return
        }

        let randomMateIndex = Int(arc4random_uniform(UInt32(playMates.count)))
        let playMate = playMates[randomMateIndex]
        self.playView.mate = playMate
        
        let neighborhoodText = playMate.neighborhood != nil ? "(\(playMate.neighborhood.name))" : ""
        
        self.playView.imageView?.setImageWithURL(NSURL(string: playMate.imageURL)!)
        self.playView.imageView?.hidden = false
        self.playView.nameAndNeighborhoodLabel?.text = "\(playMate.firstName) \(neighborhoodText)"
        self.playView.budgetLabel?.text = "\(playMate.formattedPrice)"
        self.playView.moveInLabel?.text = playMate.formattedWhen
    }
    
    // MARK: - Reset play view
    
    func resetPlayView() {
        self.playView.mate = nil
        self.playView.imageView?.image = UIImage(named: "missing")
        self.playView.imageView?.hidden = true
        self.playView.imageContainerView.center = self.playView.initialImageContainerCenter
        self.playView.yayLabel.hidden = true
        self.playView.nayLabel.hidden = true
        self.playView.outOfMatesLabel?.hidden = true
        self.playView.nameAndNeighborhoodLabel?.text = ""
        self.playView.budgetLabel?.text = ""
        self.playView.moveInLabel?.text = ""
        self.playView.favoriteButton.selected = false
    }
    
    // MARK: - Reset play view image
    
    func resetPlayViewImage() {
        // return image to original place
        self.playView.imageContainerView.center = self.playView.initialImageContainerCenter
        
        // reset (hide) yay/nay labels
        self.playView.nayLabel.hidden = true
        self.playView.yayLabel.hidden = true
    }
    
    // MARK: - Tap play view image
    
    @IBAction func tapPlayViewImage(sender: UIGestureRecognizer) {
        if let playViewMate = self.playView.mate {
            self.reloadMates = false
            performSegueWithIdentifier("mateDetail", sender: playViewMate)
        }
    }
    
    // MARK: - Show loading view
    
    func showLoadingView() {
        loadingView.hidden = false
        loadingView.activityIndicatorView.startAnimating()
    }
    
    // MARK: - Remove loading view
    
    func removeLoadingView() {
        if loadingView.imageView.layer.animationForKey("rotate") != nil {
            loadingView.imageView.layer.removeAnimationForKey("rotate")
        }
        loadingView.activityIndicatorView.stopAnimating()
        loadingView.hidden = true
        
        // end collection view refresh control if visible
        gridCollectionRefreshControl.endRefreshing()
    }
    
    // MARK: - Collection view data source
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.mates.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let mate = self.mates[indexPath.item]
        
        let cell = gridCollectionView.dequeueReusableCellWithReuseIdentifier("MateCell", forIndexPath: indexPath)
            as! MateCollectionViewCell
        cell.firstNameLabel?.text = mate.firstName
        cell.mateImageView?.setImageWithURL(NSURL(string: mate.imageURL)!)
        cell.neighborhoodLabel?.text = mate.neighborhood?.name
        cell.budgetLabel?.text = "\(mate.formattedPrice)"
        cell.moveInLabel?.text = mate.formattedWhen
        
        updateMateFavoriteButton(cell.favoriteButton, mate: mate)
        
        cell.border1Thickness.constant = 0.5
        cell.border2Thickness.constant = 0.5
        
        return cell
    }
    
    // MARK: - Collection view delegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let mate = self.mates[indexPath.item]
        performSegueWithIdentifier("mateDetail", sender: mate)
    }
    
    // MARK: - Collection view delegate flow layout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var width = 161
        if IS_IPHONE5() || IS_IPHONE4() {
            width = 142
        }
        return CGSizeMake(CGFloat(width), 300)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return getInset()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return getInset()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        let inset = getInset()
        return UIEdgeInsetsMake(inset, inset, inset, inset)
    }
    
    func getInset() -> CGFloat {
        let viewWidth = self.view.frame.size.width
        let itemSize = self.collectionView(self.gridCollectionView, layout: gridCollectionViewFlowLayout, sizeForItemAtIndexPath:
            NSIndexPath(forItem: 0, inSection: 0))
        let colWidth = itemSize.width
        var numCols = floor(viewWidth / colWidth)
        // ipad screen is kinda cramped so subtract a column
        if IS_IPAD() {
            numCols -= 1
        }
        var inset = (viewWidth - (numCols * colWidth)) / (numCols + 1)
        inset = max(inset, 0)
        
        return CGFloat(inset)
    }
    
    // MARK: - Message (via button on grid/play view)
    
    @IBAction func message(sender: UIButton) {
        // get mate
        var mate: Mate?
        if sender.tag == 1 {
            mate = self.playView.mate
        } else {
            if let mateCell = sender.superview?.superview as? MateCollectionViewCell {
                if let indexPath = gridCollectionView.indexPathForCell(mateCell) {
                    mate = self.mates[indexPath.item]
                }
            }
        }
        
        if mate == nil {
            return
        }
        
        let contextURL = "\(SITE_DOMAIN)/mate_posts/\(mate!.id)"
        messageAgent(agent: mate!.agent, contextURL: contextURL, vc: self)
    }
    
    // MARK: - Favorite (via button on grid/play view or yay)
    
    @IBAction func favorite(sender: UIButton) {
        // check if action is from play view
        var fromPlayView = false
        if sender.tag == 1 || sender.tag == 2 {
            fromPlayView = true
        }
        
        // get mate
        var mate: Mate?
        if fromPlayView {
            mate = self.playView.mate
        } else {
            if let mateCell = sender.superview?.superview as? MateCollectionViewCell {
                if let indexPath = gridCollectionView.indexPathForCell(mateCell) {
                    mate = self.mates[indexPath.item]
                }
            }
        }
        
        if mate == nil {
            return
        }
        
        sender.selected = !sender.selected
        favoriteMateAction(mate!, favorite: sender.selected)
        
        // update views
        updateMateViews()
    }
    
    // MARK: - Yay
    
    func yay() {
        let button = UIButton()
        button.tag = 2
        favorite(button)
    }
    
    // MARK: - Ignore (via button on play view or nay)
    
    @IBAction func ignore(sender: UIButton) {
        let mate = self.playView.mate
        if mate == nil {
            return
        }
        ignoreMateAction(mate!)
        
        // reapply filters (The reason Ignore has to reapply filters and Favorite doesn't is due to the way
        //                  the filter predicates are written for excluding ids and the fact that Ignore
        //                  needs to remove cells from the grid view while Favorite just has to update existing
        //                  grid view cells.)
        applyFilters(self.filters)
    }
    
    // MARK: - Nay
    
    func nay() {
        let button = UIButton()
        ignore(button)
    }
    
    // MARK: - Play view image drag
    
    @IBAction func playViewImageDrag(recognizer: UIPanGestureRecognizer) {
        if recognizer.state != UIGestureRecognizerState.Ended {
            let translation = recognizer.translationInView(self.view)
            let currentCenter = self.playView.imageContainerCenter
            self.playView.imageContainerView.center = CGPointMake(currentCenter.x + translation.x, currentCenter.y + translation.y)
            
            // show yay/nay depending on how far to the right/left
            if isNay() {
                self.playView.nayLabel.hidden = false
            } else if isYay() {
                self.playView.yayLabel.hidden = false
            } else {
                self.playView.nayLabel.hidden = true
                self.playView.yayLabel.hidden = true
            }
        } else {
            // play view image pan ended (yay/nay drop action)
            
            // check if yay/nay
            if isYay() {
                if isFirstFavoriteMateDrop() {
                    showFavoriteConfirmAlert()
                    return
                } else {
                    yay()
                }
            } else if isNay() {
                if isFirstIgnoreMateDrop() {
                    showIgnoreConfirmAlert()
                    return
                } else {
                    nay()
                }
            }
            resetPlayViewImage()
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.playView.imageContainerCenter = self.playView.imageContainerView.center
    }
    
    // MARK: - Yay/Nay check
    
    func isNay() -> Bool {
        let centerPct = self.playView.imageContainerView.center.x / self.view.frame.size.width
        return centerPct < 0.35
    }
    
    func isYay() -> Bool {
        let centerPct = self.playView.imageContainerView.center.x / self.view.frame.size.width
        return centerPct > 0.65
    }
    
    // MARK: - Show favorite confirm alert
    
    func showFavoriteConfirmAlert() {
        let alert = UIAlertController(title: "Favorite?", message: "Dragging a mate's picture to the right will favorite them.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { action in
            self.resetPlayViewImage()
        })
        alert.addAction(UIAlertAction(title: "Favorite", style: UIAlertActionStyle.Default) { action in
            self.yay()
        })
        self.presentViewController(alert, animated: true, completion: nil)
        
        markFirstFavoriteMateDrop()
    }
    
    // MARK: - Show ignore confirm alert
    
    func showIgnoreConfirmAlert() {
        let alert = UIAlertController(title: "Hide?", message: "Dragging a mate's picture to the left will remove them from the grid view.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { action in
            self.resetPlayViewImage()
        })
        alert.addAction(UIAlertAction(title: "Hide", style: UIAlertActionStyle.Default) { action in
            self.nay()
        })
        self.presentViewController(alert, animated: true, completion: nil)
        
        markFirstIgnoreMateDrop()
    }
    
    // MARK: - Facebook login
    
    @IBAction func facebookLogin(sender: UIButton) {
        facebookAuth(vc: self) { facebookAuthSucceeded in
            if facebookAuthSucceeded {
                self.advanceFromLogin()
            } else {
                showErrorAlert(message: "We were unable to connect to your Facebook account.", vc: self)
            }
        }
    }
    
    func advanceFromLogin() {
        self.loginOverlay.hidden = true
        getMates()
        updateBarButtonItems()
    }
    
    // MARK: - Filters delegate
    
    func applyFilters(filters: Filters) {
        self.filters = filters as! MateFilters
        
        // if logged in agent has a mate post, include it
        if let loggedInAgent = UserData.getLoggedInAgent(), loggedInAgentMate = loggedInAgent.mate {
            self.lastFetchedMates.removeObject(loggedInAgentMate)
            if !self.lastFetchedMates.contains(loggedInAgentMate) {
                self.lastFetchedMates.append(loggedInAgentMate)
            }
        }
        
        var subpredicates = [NSPredicate]()
        
        // price
        let subpredicate1 = NSPredicate(format: "price BETWEEN %@", [self.filters.startPrice ?? 0, self.filters.endPrice ?? Int.max])
        subpredicates.append(subpredicate1)
        
        // move in date
        let subpredicate2 = NSPredicate(format: "when BETWEEN %@", [self.filters.startDate ?? NSDate.distantPast(), self.filters.endDate ?? NSDate.distantFuture()])
        subpredicates.append(subpredicate2)
        
        // neighborhoods
        if self.filters.neighborhoodIds.count > 0 {
            let subpredicate3 = NSPredicate(format: "neighborhood.id IN %@", self.filters.neighborhoodIds)
            subpredicates.append(subpredicate3)
        }
        
        // visible
        let subpredicate4 = NSPredicate(format: "visible == true")
        subpredicates.append(subpredicate4)
        
        // restrictions (default is whatever's returned by api minus ignored)
        if !self.filters.restrictions.isEmpty {
            var restrictionSubpredicates = [NSPredicate]()
            
            // favorited
            if self.filters.restrictions.contains(.Favorited) {
                let mateFavoriteIds = getMateFavorites().map({ $0.id })
                let favoriteSubpredicate = NSPredicate(format: "id IN %@", mateFavoriteIds)
                restrictionSubpredicates.append(favoriteSubpredicate)
            }
            
            // ignored
            if self.filters.restrictions.contains(.Ignored) {
                let mateIgnoreIds = getMateIgnores().map({ $0.id })
                let ignoreSubpredicate = NSPredicate(format: "id IN %@", mateIgnoreIds)
                restrictionSubpredicates.append(ignoreSubpredicate)
            }
            
            let restrictionPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: restrictionSubpredicates)
            subpredicates.append(restrictionPredicate)
        } else {
            // exclude ignored
            let mateIgnoreIds = getMateIgnores().map({ $0.id })
            let ignoreSubpredicate = NSPredicate(format: "NOT id IN %@", mateIgnoreIds)
            subpredicates.append(ignoreSubpredicate)
        }
        
        let finalPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicates)
        
        self.mates = self.lastFetchedMates.filter({ finalPredicate.evaluateWithObject($0) }).sort({
            $0.when.compare($1.when) == NSComparisonResult.OrderedAscending
        })
        
        print("mates: \(self.mates.count)")
        
        updateMateViews()
    }
    
    func resetGridScroll() {
        gridCollectionView.setContentOffset(CGPointZero, animated: false)
    }
    
    // MARK: - Update mate views
    
    func updateMateViews() {
        // grid
        gridCollectionView.reloadData()
        
        // play
        loadPlayMate()
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "filter" {
            let nc = segue.destinationViewController as! UINavigationController
            let filterViewController = nc.viewControllers[0] as! FiltersViewController
            filterViewController.delegate = self
            filterViewController.type = FilterType.Mates
            filterViewController.filters = filters
            
            // the filter segue overlaps navigation bar so hide titleView and Filter button
            navigationItem.rightBarButtonItem?.title = ""
            navigationItem.titleView?.hidden = true
        } else if segue.identifier == "mateDetail" {
            let vc = segue.destinationViewController as! MateDetailTableViewController
            let mate = sender as! Mate
            vc.mate = mate
        }
    }
}

class MateCollectionViewCell: UICollectionViewCell {
    @IBOutlet var firstNameLabel: UILabel!
    @IBOutlet var messageButton: UIButton!
    @IBOutlet var mateImageView: UIImageView!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var neighborhoodView: UIView!
    @IBOutlet var neighborhoodLabel: UILabel!
    @IBOutlet var budgetMoveInView: UIView!
    @IBOutlet var budgetView: UIView!
    @IBOutlet var budgetLabel: UILabel!
    @IBOutlet var moveInView: UIView!
    @IBOutlet var moveInLabel: UILabel!
    @IBOutlet var border1Thickness: NSLayoutConstraint!
    @IBOutlet var border2Thickness: NSLayoutConstraint!
}

class PlayMateView: UIView {
    // mate
    var mate: Mate!
    
    // top view
    @IBOutlet var playTopView: UIView!
    @IBOutlet var imageContainerView: UIView!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var yayLabel: UILabel!
    @IBOutlet var nayLabel: UILabel!
    @IBOutlet var outOfMatesLabel: UILabel!
    @IBOutlet var nameAndNeighborhoodLabel: UILabel!
    
    @IBOutlet var borderThickness: NSLayoutConstraint!
    @IBOutlet var yayLabelY: NSLayoutConstraint!
    @IBOutlet var nayLabelY: NSLayoutConstraint!
    var imageContainerCenter = CGPointMake(0, 0)
    var initialImageContainerCenter = CGPointMake(0, 0)
    
    // bottom view
    @IBOutlet var playBottomView: UIView!
    @IBOutlet var budgetView: UIView!
    @IBOutlet var budgetLabel: UILabel!
    @IBOutlet var moveInView: UIView!
    @IBOutlet var moveInLabel: UILabel!
    
    @IBOutlet var ignoreButton: UIButton!
    @IBOutlet var favoriteButton: UIButton!
    @IBOutlet var messageButton: UIButton!
    
    // budget view height
    @IBOutlet var budgetViewHeight: NSLayoutConstraint!
    var alternateBudgetViewHeight: NSLayoutConstraint!
    
    // move in view height
    @IBOutlet var moveInViewHeight: NSLayoutConstraint!
    var alternateMoveInViewHeight: NSLayoutConstraint!
    
    // button sizes
    @IBOutlet var ignoreButtonWidth: NSLayoutConstraint!
    @IBOutlet var ignoreButtonHeight: NSLayoutConstraint!
    
    @IBOutlet var favoriteButtonWidth: NSLayoutConstraint!
    @IBOutlet var favoriteButtonHeight: NSLayoutConstraint!
    
    @IBOutlet var messageButtonWidth: NSLayoutConstraint!
    @IBOutlet var messageButtonHeight: NSLayoutConstraint!
}
