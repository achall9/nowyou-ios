//
//  HomeViewController.swift
//  NowYou
//
//  Created by Apple on 12/26/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

enum ActivePanDirection {
    case Undefined
    case Horizontal
    case Vertical
}

class HomeViewController: BaseViewController {

    // Mark: - Properties
    /*
     * The whole magic to this implementation:
     * manipulation of the x & y constraints of the center container view wrt the BaseViewController's
     *
     * The other (top, bottom, left, right) simply constrain themselves wrt to the center container
     */
    
    @IBOutlet weak var currentXOffset: NSLayoutConstraint!
    @IBOutlet weak var currentYOffset: NSLayoutConstraint!
    @IBOutlet weak var btnCloseTutor: UIButton!
    // pan gesture recognizer related
    @IBOutlet var mainPanGesture: UIPanGestureRecognizer!
    
    // Mark: View controllers
    private(set) var centerViewController: UIViewController!
    private var photoEditState : Bool = false
    
    // Append embedded view to container view's view hierachy
    var topViewController: RadioViewController? {
        willSet(newValue) {
            self.shouldshowTopViewController = newValue != nil
            topViewController?.view.removeFromSuperview()
            guard let viewController = newValue else {
                return
            }
            addEmbeddedViewController(viewController: viewController, position: .Top)
        }
    }
    
    var bottomViewController: MetricsViewController? {
        willSet(newValue) {
            self.shouldShowBottomViewController = newValue != nil
            bottomViewController?.view.removeFromSuperview()
            guard let viewController = newValue else {
                return
            }
            addEmbeddedViewController(viewController: viewController, position: .Bottom)
        }
    }
    var leftViewController: ProfileViewController? {
        willSet(newValue) {
            self.shouldShowLeftViewController = newValue != nil
            leftViewController?.view.removeFromSuperview()
            guard let viewController = newValue else {
                return
            }
            addEmbeddedViewController(viewController: viewController, position: .Left)
        }
    }
    var rightViewController: PlayViewController?
    
    var focusViewController:UIViewController?
    
    private var previousNonZeroDirectionChange = CGVector(dx: 0.0, dy: 0.0)// CGVectorMake(0.0, 0.0)
    private var activePanDirection = ActivePanDirection.Undefined
    private let verticalSnapThresholdFraction: CGFloat = 0.15
    private let horizontalSnapThresholdFraction: CGFloat = 0.15
    
    // do not modify them, unfortunately they can't be declared with let due to value available only in viewDidLoad
    // implicitly unwrapped because they WILL be initialized during viewDidLoad
    private var centerContainerOffset: CGVector!
    private var topContainerOffset: CGVector!
    private var bottomContainerOffset: CGVector!
    private var leftContainerOffset: CGVector!
    private var rightContainerOffset: CGVector!
    
    @IBOutlet weak var introIV: UIImageView!
    // setting them to NO disables swiping to the view controller, try it!
    var shouldshowTopViewController = true
    var shouldShowBottomViewController = true
    var shouldShowLeftViewController = true
    var shouldShowRightviewController = true
    
    var swipeFromPlayEnable = true
    private let swipeAnimateDuration = 0.2

    // Mark: - Initializers
    // Use this initializer if you are not using storyboard
    init(centerViewController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        shouldshowTopViewController = false
        shouldShowBottomViewController = false
        shouldShowLeftViewController = false
        shouldShowRightviewController = false
        self.centerViewController = centerViewController
        self.focusViewController = centerViewController
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        if currentXOffset == nil || currentYOffset == nil {
            view.addSubview(centerViewController.view)
            centerViewController.view.translatesAutoresizingMaskIntoConstraints = false
            centerViewController.view.backgroundColor = UIColor.blue
            self.currentXOffset = alignCenterXConstraint(forItem: centerViewController.view, toItem: view, position: .Center)
            self.currentYOffset = alignCenterYConstraint(forItem: centerViewController.view, toItem: view, position: .Center)
            view.addConstraints([self.currentXOffset, self.currentYOffset])
            view.addConstraints(sizeConstraints(forItem: centerViewController.view, toItem: view))
        }
        
        if mainPanGesture == nil {
            
            mainPanGesture = UIPanGestureRecognizer(target: self, action: #selector(self.onPanGestureTriggered(_:)))
            mainPanGesture.delegate = self
            view.addGestureRecognizer(mainPanGesture)
        }
        
        // embedded containers offset
        let frameWidth = view.frame.size.width
        let frameHeight = view.frame.size.height
        // bookmark the offsets to specific positions
        centerContainerOffset = CGVector(dx:currentXOffset.constant, dy:currentYOffset.constant)
        topContainerOffset = CGVector(dx:centerContainerOffset.dx, dy:centerContainerOffset.dy + frameHeight)
        bottomContainerOffset = CGVector(dx:centerContainerOffset.dx, dy:centerContainerOffset.dy - frameHeight)
        leftContainerOffset = CGVector(dx:centerContainerOffset.dx + frameWidth, dy:centerContainerOffset.dy)
        rightContainerOffset = CGVector(dx:centerContainerOffset.dx - frameWidth, dy:centerContainerOffset.dy)
        
        NotificationCenter.default.addObserver(self, selector: #selector(photoEditDontHasSwipe(_:)), name: .photoEditViewEnable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(photoEditHasSwipe(_:)), name: .photoEditViewDisable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(photoEditDontHasSwipe(_:)), name: .searchViewEnable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(photoEditHasSwipe(_:)), name: .searchViewDisable, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(openTutor(notification:)), name: .openTutorboardNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeTutor(notification:)), name: .closeTutorboardNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(swipeToHomeFromPlayViewEnable(_:)), name: .goToHomeFromPlayViewEnable, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(swipeToHomeFromPlayViewDisable(_:)), name: .goToHomeFromPlayViewDisable, object: nil)
        }
    @objc func swipeToHomeFromPlayViewEnable(_ notification: Notification){
        swipeFromPlayEnable = true
    }
    @objc func swipeToHomeFromPlayViewDisable(_ notification: Notification){
        swipeFromPlayEnable = false
    }
    
    @objc func openTutor(notification: Notification){
        UserDefaults.standard.set(true, forKey: "welcomeShown")
        introIV.alpha = 1.0
        btnCloseTutor.alpha = 1.0
        btnCloseTutor.isEnabled = true
    }
    @objc func closeTutor(notification: Notification){

        introIV.alpha = 0.0
        btnCloseTutor.alpha = 0.0
        btnCloseTutor.isEnabled = false
    }
    @objc func photoEditDontHasSwipe(_ notification: Notification) {
        photoEditState = true
    }
    @objc func photoEditHasSwipe(_ notification: Notification) {
        photoEditState = false
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigation bar when navigating into this view controller
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Disable "Back" title on the navigation bar in child view controller.
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        introIV.alpha = 0.0
             let welcomeShown = UserDefaults.standard.bool(forKey: "welcomeShown")
             btnCloseTutor.isEnabled = false
             btnCloseTutor.alpha = 0.0
             if !welcomeShown {
                 introIV.alpha = 1.0
                 btnCloseTutor.alpha = 1.0
                 UserDefaults.standard.set(true, forKey: "welcomeShown")
                btnCloseTutor.isEnabled = true
             }
    }
    @IBAction func closeTutorBoard(_ sender: Any) {
        tutorClosePostNotification()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show navigation bar when navigating away from this view controller.
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Containers
    private func showContainer(position: Position) {
        let targetOffset: CGVector
        switch position {
        case .Center:
            targetOffset = centerContainerOffset
        case .Top:
            targetOffset = topContainerOffset
        case .Bottom:
            targetOffset = bottomContainerOffset
        case .Left:
            targetOffset = leftContainerOffset
        case .Right:
            targetOffset = rightContainerOffset
        }
        
        currentXOffset.constant = targetOffset.dx
        currentYOffset.constant = targetOffset.dy
        
        view.endEditing(true)
        
        UIView.animate(withDuration: swipeAnimateDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @IBAction func onPanGestureTriggered(_ sender: UIPanGestureRecognizer) {
        
        if let leftNav = leftViewController?.navigationController {
            let vcs = leftNav.viewControllers
            
            if vcs.count > 1 {
                return
            }
        }
        
        if let topNav = topViewController?.navigationController {
            
            let vcs = topNav.viewControllers
            if vcs.count > 1 {
                return
            }
        }
        
        switch sender.state {
        case .began:
            /* Restrict pan movement
             * - top/bottom not allowed to pan horizontally
             * - left/right not allowed to pan vertically
             
             * Buttons may cause other containers to become active (don't rely on UIGestureRecognizerStateBegan to set direction)
             * - either set _activePanDirection in showXXXContainers or set it here
             */
            
            if isContainerActive(position: .Top) || isContainerActive(position: .Bottom) {
                activePanDirection = .Vertical
            } else if isContainerActive(position: .Left) || isContainerActive(position: .Right) {
                activePanDirection = .Horizontal
            } else {
                activePanDirection = .Undefined
            }
        case .changed:
            /* Determine active direction if undefined
             * let horizontal take precedence in the case of equality
             * let direction be the more travelled one regardless of direction
             */
            // Update translation details
            let translationInMainView = sender.translation(in: view)
            
            // NOTE: x and y should be isolated
            if translationInMainView.x != 0 {
                previousNonZeroDirectionChange.dx = translationInMainView.x
            }
            
            if translationInMainView.y != 0 {
                previousNonZeroDirectionChange.dy = translationInMainView.y
            }
            
            switch activePanDirection {
            case .Undefined:
                activePanDirection = abs(translationInMainView.x) >= abs(translationInMainView.y) ? .Horizontal : .Vertical
                
            case .Horizontal:
                // restraint accordingly to state
                // show container according to state OR if it's already showing through some other means (eg. button, etc)
                let isCurrentlyShowingRightViewController = currentXOffset.constant < centerContainerOffset.dx
                let isCurrentlyShowingLeftViewController = currentXOffset.constant > centerContainerOffset.dx
                let minX = isCurrentlyShowingRightViewController || shouldShowRightviewController ? rightContainerOffset.dx : centerContainerOffset.dx
                let maxX = isCurrentlyShowingLeftViewController || shouldShowLeftViewController ? leftContainerOffset.dx : centerContainerOffset.dx
                
                currentXOffset.constant = min(max(minX, currentXOffset.constant + translationInMainView.x), maxX)
                
            case .Vertical:
                // restraint accordingly to state
                // show container according to state OR if it's already showing through some other means (eg. button, etc)
                let isCurrentlyShowingBottomViewController = currentYOffset.constant < centerContainerOffset.dy
                let isCurrentlyShowingTopViewController = currentYOffset.constant > centerContainerOffset.dy
                let minY = isCurrentlyShowingBottomViewController || shouldShowBottomViewController ? bottomContainerOffset.dy : centerContainerOffset.dy
                let maxY = isCurrentlyShowingTopViewController || shouldshowTopViewController ? topContainerOffset.dy : centerContainerOffset.dy
                
                currentYOffset.constant = min(max(minY, currentYOffset.constant + translationInMainView.y), maxY)
            }
            
            // reset translation for next iteration
            sender.setTranslation(CGPoint.zero, in: view)
            
        case .ended:
            /*
             * Handle snapping here
             */
            switch activePanDirection {
            case .Horizontal:
                /* Snap to LEFT container  (positive x offset)
                 *
                 *      x0       x1
                 * 0----+--------+---->1
                 *  xxxx|        |xxx
                 *
                 * snap to 0 when < x0, snap to 1 when > x1
                 * center region: check previous pan vector's direction
                 *
                 */
                if currentXOffset.constant > 0.0 {
                    
                    // within range of center container
                    if currentXOffset.constant < (horizontalSnapThresholdFraction * view.frame.size.width) {
                        showContainer(position: .Center)
                    }
                        
                        // within range of left container
                    else if currentXOffset.constant > ((1.0 - horizontalSnapThresholdFraction) * view.frame.size.width) {
                        showContainer(position: .Left)
                    }
                        
                        // center region: depends on inertia direction
                    else {
                        // pulled right
                        if previousNonZeroDirectionChange.dx > 0.0 {
                            showContainer(position: .Left)
                        }
                            
                            // pulled left
                        else {
                            showContainer(position: .Center)
                        }
                    }
                }
                    /* Snap to RIGHT container (negative x offset)
                     *
                     *        x1       x0
                     * -1<----+--------+----0
                     *    xxxx|        |xxx
                     *
                     * snap to 0 when > x0, snap to 1 when < x1
                     * center region: check previous pan vector's direction
                     *
                     */
                else if currentXOffset.constant < 0.0 {
                    
                    // within range of center container
                    if currentXOffset.constant > (horizontalSnapThresholdFraction * -view.frame.size.width) {
                        showContainer(position: .Center)
                    }
                        
                        // within range of right container
                    else if currentXOffset.constant < ((1.0 - horizontalSnapThresholdFraction) * -view.frame.size.width) {
                        showContainer(position: .Right)
                    }
                        
                        // center region: depends on inertia direction
                    else {
                        // pulled left
                        if previousNonZeroDirectionChange.dx < 0.0 {
                            showContainer(position: .Right)
                            
                            NotificationCenter.default.post(name: .gotoPlayViewController, object: nil)

                        }
                            
                            // pulled right
                        else {
                            showContainer(position: .Center)
                        }
                    }
                }
                
            case .Vertical:
                /* Snap to TOP container (positive y offset)
                 *
                 *      y0       y1
                 * 0----+--------+---->1
                 *  xxxx|        |xxx
                 *
                 * snap to 0 when < y0, snap to 1 when > y1
                 * center region: check previous pan vector's direction
                 *
                 */
                if currentYOffset.constant > 0.0 {
                    
                    // within range of center container
                    if currentYOffset.constant < (verticalSnapThresholdFraction * view.frame.size.height) {
                        showContainer(position: .Center)
                    }
                        
                        // within range of top container
                    else if currentYOffset.constant > ((1.0 - verticalSnapThresholdFraction) * view.frame.size.height) {
                        showContainer(position: .Top)
                    }
                        
                        // center region: depends on inertia direction
                    else {
                        // pulled down
                        if previousNonZeroDirectionChange.dy > 0.0 {
                            showContainer(position: .Top)
                        }
                            
                            // pulled up
                        else {
                            showContainer(position: .Center)
                        }
                    }
                }
                    
                    /* Snap to BOTTOM container (negative y offset)
                     *
                     *        y1       y0
                     * -1<----+--------+----0
                     *    xxxx|        |xxx
                     *
                     * snap to 0 when > y0, snap to 1 when < y1
                     * center region: check previous pan vector's direction
                     *
                     */
                else if currentYOffset.constant < 0.0 {
                    
                    // within range of center container
                    if currentYOffset.constant > (verticalSnapThresholdFraction * -view.frame.size.height) {
                        showContainer(position: .Center)
                    }
                        
                        // within range of bottom container
                    else if currentYOffset.constant < ((1.0 - verticalSnapThresholdFraction) * -view.frame.size.height) {
                        showContainer(position: .Bottom)
                    }
                        
                        // center region: depends on inertia direction
                    else {
                        // pulled up
                        if previousNonZeroDirectionChange.dy < 0.0 {
                            showContainer(position: .Bottom)
                        }
                            
                            // pulled down
                        else {
                            showContainer(position: .Center)
                        }
                    }
                }
                
            case .Undefined:
                // do nothing
                break
            }
        default:
            break
        }
    }
    
    // Append embedded view to container view's view hierachy
    func addEmbeddedViewController(viewController: UIViewController, position: Position) {
        
        return
        if centerViewController == nil {
            return
        }
        if viewController.view != nil {
            
        } else {
            print ("view is nil")
        }
        
        (viewController as? EmbeddedViewController)?.delegate = self
        view.addSubview(viewController.view)
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(alignCenterXConstraint(forItem: viewController.view, toItem: centerViewController.view, position: position))
        view.addConstraint(alignCenterYConstraint(forItem: viewController.view, toItem: centerViewController.view, position: position))
        view.addConstraints(sizeConstraints(forItem: viewController.view, toItem: centerViewController.view))
        view.layoutIfNeeded()
    }
    
    // MARK: - Layout Constraints
    // Create a layout constraint that make view item to align center x to the respective item with offset according to the position
    // For view item that is positioned on the left will offset by -toItem.width, and +toItem.width if it's positioned on the right
    func alignCenterXConstraint(forItem item: UIView, toItem: UIView, position: Position) -> NSLayoutConstraint {
        let offset = position == .Left ? -self.view.frame.width : position == .Right ? toItem.frame.width : 0
        return NSLayoutConstraint(item: item, attribute: .centerX, relatedBy: .equal, toItem: toItem, attribute: .centerX, multiplier: 1, constant: offset)
    }
    
    // Create a layout constraint that make view item to align center y to the respective item height offset according to the position
    // For view item that is positioned on the top will offset by -toItem.height, and +toItem.height if it's positioned on the right
    func alignCenterYConstraint(forItem item: UIView, toItem: UIView, position: Position) -> NSLayoutConstraint {
        let offset = position == .Top ? -self.view.frame.height : position == .Bottom ? toItem.frame.height : 0
        return NSLayoutConstraint(item: item, attribute: .centerY, relatedBy: .equal, toItem: toItem, attribute: .centerY, multiplier: 1, constant: offset)
    }
    
    // Create width and height layout constraints that make make the item.size same as the toItem.size
    func sizeConstraints(forItem item: UIView, toItem: UIView) -> [NSLayoutConstraint] {
        let widthConstraint = NSLayoutConstraint(item: item, attribute: .width, relatedBy: .equal, toItem: toItem, attribute: .width, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: item, attribute: .height, relatedBy: .equal, toItem: toItem, attribute: .height, multiplier: 1, constant: 0)
        return [widthConstraint, heightConstraint]
    }
    
    /*
     * MARK: - Navigation
     *
     * - in a storyboard-based application, you will often want to do a little preparation before navigation
     * - in this case, prepareForSegue will be triggered on load due to embedded segues
     */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // for EmbeddedViewControllers are embedded in UINavigationControllers
        if segue.identifier == "toFeedNav" {
            let feedNav = segue.destination as! UINavigationController
            if let feedVC = feedNav.topViewController as? PlayViewController {
                rightViewController = feedVC
                self.focusViewController = rightViewController
            }
       } else if segue.identifier == "toProfile" {
            let profileNav = segue.destination as! UINavigationController
            
            if let profileVc = profileNav.topViewController as? ProfileViewController {
                leftViewController = profileVc
                self.focusViewController = leftViewController
            }
        } else if segue.identifier == "toCam" {
            let camNav = segue.destination as! UINavigationController
            
            if let camVc = camNav.topViewController as? CameraViewController {
                centerViewController = camVc
                self.focusViewController = centerViewController
            }
        } else if segue.identifier == "toRadio" {
            let radioNav = segue.destination as! UINavigationController
            
            if let radioVc = radioNav.topViewController as? RadioViewController {
                topViewController = radioVc
                self.focusViewController = topViewController
            }
        }
        
        let nav = segue.destination as! UINavigationController
        
        if let vc = nav.topViewController as? EmbeddedViewController {
            vc.delegate = self
        }
    }

}

// MARK: - Pan Gestures
extension HomeViewController : UIGestureRecognizerDelegate{
        // called before touchesBegan:withEvent: is called on the gesture recognizer for a new touch. return NO to prevent the gesture recognizer from seeing this touch
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
            if gestureRecognizer.view?.parentViewController is CreateRadioViewController {
                return false
            }else if gestureRecognizer.view?.parentViewController is HomeViewController {
                
                if photoEditState{
                    return false
                }else if !swipeFromPlayEnable {
                    return false
                }
                else {
                    return true
                }
                
            }
            return true
        }
        
        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            
            if otherGestureRecognizer is UISwipeGestureRecognizer {
                return true
            }
            
            if let tableView = otherGestureRecognizer.view as? UITableView {
                if tableView.parentContainerViewController() is SearchViewController {
                    return false
                }
                
                if tableView.parentViewController is SearchViewController {
                    return false
                }

                if tableView.parentViewController is CategoryViewController ||
                    tableView.parentViewController is PopularRadioStationViewController {
                    return false
                }
                
                if tableView.contentOffset.y >= tableView.contentSize.height - tableView.frame.size.height - 10 {
                    return true
                }
            }else if otherGestureRecognizer.view?.parentViewController is PhotoEditorViewController {
                return false
            }

            return false
        }
        
    //    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //        if let tableView = otherGestureRecognizer.view as? UITableView {
    //
    //            if gestureRecognizer == mainPanGesture && otherGestureRecognizer == tableView.panGestureRecognizer {
    //                return true
    //            }
    //        }
    //
    //        return false
    //    }
    //    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    //
    //        if let tableView = gestureRecognizer.view as? UITableView {
    //            if gestureRecognizer == tableView.panGestureRecognizer && otherGestureRecognizer == mainPanGesture {
    //                return true
    //            }
    //        }
    //
    //        return false
    //    }
        
}

// MARK: - EmbeddedViewcontrollerDelegate Conformance
extension HomeViewController: EmbeddedViewControllerDelegate{
    
    func isContainerActive(position: Position) -> Bool {
        let targetOffset: CGVector
        switch position {
        case .Center:
            targetOffset = centerContainerOffset
        case .Top:
            targetOffset = topContainerOffset
        case .Bottom:
            targetOffset = bottomContainerOffset
        case .Left:
            targetOffset = leftContainerOffset
           
        case .Right:
            targetOffset = rightContainerOffset
        }
        
        return (currentXOffset.constant, currentYOffset.constant) == (targetOffset.dx, targetOffset.dy)
    }
    
    func onProfile(sender: AnyObject) {
        showContainer(position: .Left)
    }
    
    func onDone(sender: AnyObject) {
        showContainer(position: .Center)
    }
    
    func onShowContainer(position: Position, sender: AnyObject) {
        showContainer(position: position)
    }
}

extension Notification.Name {
    static let gotoPlayViewController = Notification.Name("GoToPlayVCFromCameraVC")
}

