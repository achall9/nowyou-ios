//
//  SearchViewController.swift
//  NowYou
//
//  Created by Apple on 2/19/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import UIKit

enum SearchMode {
    case People
    case Tag
}


class SearchViewController: BaseViewController, UIViewControllerTransitioningDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var searchTxt: UITextField!
    @IBOutlet weak var searchTypeView: UIView!
    @IBOutlet weak var peopleTypeView: NYView!
    @IBOutlet weak var tagTypeView: NYView!
    @IBOutlet weak var searchResultTbl: UITableView!
    
    @IBOutlet weak var btnTag: UIButton!
    @IBOutlet weak var btnPeople: UIButton!
    @IBOutlet weak var tagPlaceHolderLbl: UILabel!
    
    var tagSearchResult     = [SearchTag]()
    var peopleSearchResult  = [SearchUser]()
    var isSearchDone : Bool = false
    var searchMode: SearchMode = .People {
        didSet {
//            switch searchMode {
//            case .People:
//                onPeopleType(btnPeople)
//            case .Tag:
//                onTagType(btnTag)
//            }
            
            DispatchQueue.main.async {
                self.searchResultTbl.reloadData()
            }            
        }
    }
    
    var interactor: Interactor? = nil
    let transition = CATransition()
    var isFollowing : Bool!
    override func viewDidLoad() {
        super.viewDidLoad()

        let recognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(gesture(_:)))
        recognizer.delegate = self
        view.addGestureRecognizer(recognizer)
        
        setupUI()
        observeNotifications()
        NotificationCenter.default.post(name: .searchViewEnable, object: self)
        isSearchDone = false
         self.tagPlaceHolderLbl.alpha = 1.0
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    
        initSearchBar()
    }
    
    
    fileprivate func observeNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(searchUpdated(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.SEARCH_PEOPLE_RESULT_UPDATED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(searchUpdated(notification:)),
                                               name: NSNotification.Name(rawValue: NOTIFICATION.SEARCH_TAG_RESULT_UPDATED), object: nil)
    }
    
    fileprivate func initSearchBarListner() {
        let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        searchTxt.leftView = paddingView
        searchTxt.leftViewMode = .always
        
        searchTxt.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEnd)
        searchTxt.addTarget(self, action: #selector(textFieldDidChangedEditing(_:)), for: .editingChanged)
        searchTxt.placeholder = "Search"
        searchTxt.becomeFirstResponder()
    }
    
    fileprivate func setupUI() {
        initSearchTypeView()
        initSearchBarListner()
        
        onPeopleType(btnPeople)
        
        searchResultTbl.tableFooterView = UIView()
    }
    
    fileprivate func initSearchBar() {
        searchTxt.layer.borderWidth = 1
        searchTxt.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
        searchTxt.layer.cornerRadius = searchTxt.frame.height / 2
        searchTxt.clipsToBounds = true
    }
    
    private func initSearchTypeView() {
        searchTypeView.layer.borderWidth = 1
        searchTypeView.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
        searchTypeView.layer.cornerRadius = 6
        searchTypeView.clipsToBounds = true
        
        peopleTypeView.layer.cornerRadius = 6
        peopleTypeView.clipsToBounds = true
        
        tagTypeView.layer.cornerRadius = 6
        tagTypeView.clipsToBounds = true
    }
    
    private func setSearchMode(searchMode: SearchMode) {
        self.searchMode = searchMode
    }
    
//    @objc func text
    @objc func textFieldDidEndEditing(_ textField: UITextField) {
//        if textField.text == nil || textField.text?.count == 0 {
//            peopleSearchResult.removeAll()
//            tagSearchResult.removeAll()
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.SEARCH_PEOPLE_RESULT_UPDATED), object: nil, userInfo: nil)
//            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.SEARCH_TAG_RESULT_UPDATED), object: nil, userInfo: nil)
//
//            return
//        }else{
//            print (textField.text!)
//            self.search(keyword: textField.text!)
//        }
//        isSearchDone = true
    }
    @objc func textFieldDidChangedEditing(_ textField: UITextField) {
        isSearchDone = false
        if textField.text == nil || textField.text?.count == 0 {
            peopleSearchResult.removeAll()
            tagSearchResult.removeAll()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.SEARCH_PEOPLE_RESULT_UPDATED), object: nil, userInfo: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.SEARCH_TAG_RESULT_UPDATED), object: nil, userInfo: nil)
            return
        }else {
            print(textField.text!)
            
            self.search(keyword: textField.text!)
        }
//        isSearchDone = true
    }
    func search(keyword: String) {
        DispatchQueue.main.async {
            Utils.showSpinner()
        }
        NetworkManager.shared.search(keyword: keyword) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .error(let error):
                    if self.isSearchDone == true{
//                        Utils.hideSpinner()
                    }
                    print (error.localizedDescription)
                case .success(let data):
                     Utils.hideSpinner()
                    do {
                        let jsonRes = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                        
                        if let json = jsonRes as? [String: Any] {
                            self.peopleSearchResult.removeAll()
                            self.tagSearchResult.removeAll()
                            
                            if let tagRes = json["tags"] as? [[String: Any]] {
                                for tag in tagRes {
                                    if tag["is_following"] as! Int == 1{
                                        self.isFollowing = true
                                    }
                                    else{
                                        self.isFollowing = false
                                    }
                                   
                                    var tagMedias = [Media]()
                                    if let jsonValue = tag["feeds"] as? [[String: Any]] {
                                        for tagMedia in jsonValue {
                                            let media = Media(json: tagMedia)
                                            tagMedias.append(media)
                                        }
                                    }
                                    let tagId = tag["id"] as! Int
                                    let tagName = tag["name"] as! String
                                    let feedObj = SearchTag(searchTag: tagName, tagId: tagId ,following: self.isFollowing, searchPosts: tagMedias)
                                    self.tagSearchResult.append(feedObj)
                                }
                                let userInfo = ["tags": self.tagSearchResult]
                                
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.SEARCH_TAG_RESULT_UPDATED), object: nil, userInfo: userInfo)
                            }
                            
                            if let userRes = json["users"] as? [[String: Any]] {
                                for user in userRes {
                                    
                                    let userJson = user["user"] as! [String: Any]
                                    let userObj = User(json: userJson)
                                    
                                    if userObj.userID == UserManager.currentUser()?.userID {
                                        continue
                                    }
                                    
                                    var postsSeenIds = [Int]()
                                    if let postsSeen = userJson["posts_seen"] as? [[String: Any]] {
                                        for post in postsSeen {
                                            let post = Media(json: post)
                                            postsSeenIds.append(post.id!)
                                        }
                                    }
                                    
                                    var userPosts = [Media]()
                                    if let posts = userJson["posts"] as? [[String: Any]] {
                                        for post in posts {
                                            let post = Media(json: post)
                                            if postsSeenIds.contains(post.id!) {
                                                post.isSeen = true
                                            }
                                            userPosts.append(post)

                                        }
                                    }
                                    if user["is_following"] as! Int == 1{
                                        self.isFollowing = true
                                    }
                                    else{
                                        self.isFollowing = false
                                    }
                                                                    
                                    self.peopleSearchResult.append(SearchUser(searchUser: userObj, following: self.isFollowing, posts: userPosts))
                                }
                                
                                let userInfo = ["users": self.peopleSearchResult]
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.SEARCH_PEOPLE_RESULT_UPDATED), object: nil, userInfo: userInfo)
                            }
                        }
                        
                    } catch {
                        
                    }
                    
                    break
                }
            }
        }
    }
    
    @objc func searchUpdated(notification: Notification) {
        if let userInfo = notification.userInfo as? [String: Any] {
            if let tags = userInfo["tags"] as? [SearchTag] {
                tagSearchResult = tags
                
            } else if let users = userInfo["users"] as? [SearchUser] {
                peopleSearchResult = users
            }
        }
        DispatchQueue.main.async {
             self.searchResultTbl.reloadData()
        }
    }
    
    // MARK: - Private
    
    func transitionDismissal() {
        transition.duration = 0.2
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        view.window?.layer.add(transition, forKey: nil)
        
        if let homeVc = presentingViewController {
            homeVc.view.alpha = 1.0
        }
        navigationController?.popViewController(animated: false)
//        dismiss(animated: false, completion: nil)
    }
    
    @objc func gesture(_ sender: UIPanGestureRecognizer) {
        
        let percentThreshold: CGFloat = 0.15
        let translation = sender.translation(in: view)
        let fingerMovement = translation.x / view.bounds.width
        let rightMovement = fmaxf(Float(fingerMovement), 0.0)
        let rightMovementPercent = fminf(rightMovement, 1.0)
        let progress = CGFloat(rightMovementPercent)
        
        switch sender.state {
        case .began:
            
            interactor?.hasStarted = true
            dismiss(animated: true)
            
        case .changed:
            
            interactor?.shouldFinish = progress > percentThreshold
            interactor?.update(progress)
            
        case .cancelled:
            
            interactor?.hasStarted = false
            interactor?.cancel()
            
        case .ended:
            
            guard let interactor = interactor else { return }
            interactor.hasStarted = false
            
            interactor.shouldFinish
                ? interactor.finish()
                : interactor.cancel()
            
        default:
            break
        }
    }
    // MARK: - Actions
    
    @IBAction func onPeopleType(_ sender: Any) {
        Utils.shared.setNYViewActive(nyView: peopleTypeView, color: UIColor(hexValue: 0x60DF76))
        Utils.shared.setNYViewActive(nyView: tagTypeView, color: UIColor.clear)
        
        btnPeople.setTitleColor(UIColor.white, for: .normal)
        btnTag.setTitleColor(UIColor.black, for: .normal)
        
        searchMode = .People
    }
    
    @IBAction func onTagType(_ sender: Any) {
        Utils.shared.setNYViewActive(nyView: peopleTypeView, color: UIColor.clear)
        Utils.shared.setNYViewActive(nyView: tagTypeView, color: UIColor(hexValue: 0x60DF76))
        
        btnPeople.setTitleColor(UIColor.black, for: .normal)
        btnTag.setTitleColor(UIColor.white, for: .normal)
        
        searchMode = .Tag
    }
    
    @IBAction func onCancelSearch(_ sender: Any) {
        searchTxt.text = ""
        tagSearchResult.removeAll()
        peopleSearchResult.removeAll()
        
        DispatchQueue.main.async {
            self.searchResultTbl.reloadData()
        }
    }
    
    @objc func tagFollow(sender: UIButton) {
        let index = sender.tag - 100
        let tag = tagSearchResult[index]
        
        if tag.isFollowing {
            DataBaseManager.shared.unfollowHashTag(tagId: tag.tag_id){(result, error) in
                if error == "" {
                    tag.isFollowing = false
                    let indexPath = IndexPath(row: index, section: 0)
                    DispatchQueue.main.async {
                        self.searchResultTbl.reloadRows(at: [indexPath], with: .automatic)
                    }
                }else{
                    print(error)
                }
            }
        }else{
            DataBaseManager.shared.followHashTag(tagId: tag.tag_id){(result, error) in
                if error == "" {
                    tag.isFollowing = true
                    let indexPath = IndexPath(row: index, section: 0)
                    DispatchQueue.main.async {
                        self.searchResultTbl.reloadRows(at: [indexPath], with: .automatic)
                    }
                }else{
                    print(error)
                }
            }
        }
    }
    
    @objc func follow(sender: UIButton) {
        let index = sender.tag - 100
        let user = peopleSearchResult[index]
        
        if user.isFollowing {
            NetworkManager.shared.unfollow(userId: (user.user?.userID)!) { (response) in
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                case .success(_):
                    user.isFollowing = false
                    let indexPath = IndexPath(row: index, section: 0)
                    
                    let user = UserManager.currentUser()
                    
                    user?.followers_count -= 1
                    
                    UserManager.updateUser(user: user!)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_INFO_UPDATED), object: nil, userInfo: nil)
                    
                    DispatchQueue.main.async {
                        self.searchResultTbl.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        } else {
            NetworkManager.shared.follow(userId: (user.user?.userID)!) { (response) in
                switch response {
                case .error(let error):
                    print (error.localizedDescription)
                case .success(_):
                    user.isFollowing = true
                    
                    let user = UserManager.currentUser()
                    
                    user?.followers_count += 1
                    
                    UserManager.updateUser(user: user!)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: NOTIFICATION.USER_INFO_UPDATED), object: nil, userInfo: nil)
                    
                    let indexPath = IndexPath(row: index, section: 0)
                    DispatchQueue.main.async {
                        self.searchResultTbl.reloadRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
    
    // MARK: - Private
    
    func transition(to controller: UIViewController) {
        transition.duration = 0.1
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromTop
        view.window?.layer.add(transition, forKey: kCATransition)
        present(controller, animated: false)
    }
    func transitionNavMode(to controller: UIViewController) {
        transition.duration = 0.1
        transition.type = CATransitionType.fade
        transition.subtype = CATransitionSubtype.fromTop
        view.window?.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(controller, animated: false)
    }
    
    // MARK: - Animation
    
    func animationController(
        forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
            
            if dismissed is OtherProfileViewController {
                return DismissAnimator()
            }
            return VerticalDismissAnimator()
    }
    
    func interactionControllerForDismissal(
        using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            
            return interactor!.hasStarted
                ? interactor
                : nil
    }
    
    @IBAction func onBack(_ sender: Any) {
        NotificationCenter.default.post(name: .searchViewDisable, object: self)
        transitionDismissal()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if searchResultTbl.contentOffset.y < 5 {
            return true
        }
        
        return false
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch searchMode {
        case .People:
            self.tagPlaceHolderLbl.text = "No Users"
            if peopleSearchResult.count == 0{
                self.tagPlaceHolderLbl.alpha = 1.0
            }else{
                self.tagPlaceHolderLbl.alpha = 0.0
            }
            return peopleSearchResult.count
        case .Tag:
            self.tagPlaceHolderLbl.text = "No Tags"
            if tagSearchResult.count == 0{
               self.tagPlaceHolderLbl.alpha = 1.0
           }else{
               self.tagPlaceHolderLbl.alpha = 0.0
           }
            return tagSearchResult.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if searchMode == .People {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleSearchCell") as! PeopleSearchCell
            
            let user = peopleSearchResult[indexPath.row]
            cell.profileImg.layer.borderWidth = 3
            cell.profileImg.layer.borderColor = UIColor.white.cgColor
            cell.profileImg.setCircular()
            
            cell.followBtn.layer.cornerRadius = 6
            cell.followBtn.layer.masksToBounds = true
            cell.followBtn.layer.borderWidth = 1
            cell.followBtn.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
            
            if user.isFollowing {
                cell.followBtn.setTitle("Unfollow", for: .normal)
                
                cell.followBtn.backgroundColor = UIColor(hexValue: 0x60DF76)
                cell.followBtn.setTitleColor(UIColor.white, for: .normal)
            } else {
                cell.followBtn.setTitle("Follow", for: .normal)
                cell.followBtn.backgroundColor = UIColor.clear
                cell.followBtn.setTitleColor(UIColor.black, for: .normal)
            }
            
            cell.followBtn.tag = 100 + indexPath.row
            
            cell.followBtn.addTarget(self, action: #selector(follow(sender:)), for: .touchUpInside)
            
            cell.profileImg.sd_setImage(with: URL(string: Utils.getFullPath(path: (user.user?.userPhoto)!)), placeholderImage: PLACEHOLDER_IMG, options: .refreshCached, completed: nil)
            cell.fullNameLbl.text = user.user?.fullname
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TagSearchCell") as! TagSearchCell
            
            let tag = tagSearchResult[indexPath.row]
            
            cell.imageBorderView.layer.borderWidth = 1
            cell.imageBorderView.layer.borderColor = UIColor.darkGray.cgColor
            cell.imageBorderView.setCircular()
            
            cell.followBtn.layer.cornerRadius = 6
            cell.followBtn.layer.masksToBounds = true
            cell.followBtn.layer.borderWidth = 1
            cell.followBtn.layer.borderColor = UIColor(hexValue: 0x979797).withAlphaComponent(0.2).cgColor
            
            if tag.isFollowing {
                cell.followBtn.setTitle("Unfollow", for: .normal)
                
                cell.followBtn.backgroundColor = UIColor(hexValue: 0x60DF76)
                cell.followBtn.setTitleColor(UIColor.white, for: .normal)
            } else {
                cell.followBtn.setTitle("Follow", for: .normal)
                cell.followBtn.backgroundColor = UIColor.clear
                cell.followBtn.setTitleColor(UIColor.black, for: .normal)
            }
        
            cell.followBtn.tag = 100 + indexPath.row
            cell.followBtn.addTarget(self, action: #selector(tagFollow(sender:)), for: .touchUpInside)
            
            cell.tagLbl.text = tag.tag
            
            if tag.posts.count < 2 {
                cell.postsCountLbl.text = "\(tag.posts.count) post"
            } else {
                cell.postsCountLbl.text = "\(tag.posts.count) posts"
            }
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if searchMode == .People {
            let profileVC = Utils.viewControllerWith("OtherProfileViewController") as! OtherProfileViewController
            
            profileVC.user = peopleSearchResult[indexPath.row]
            profileVC.blockerTap = false
            profileVC.transitioningDelegate = self
            profileVC.interactor = interactor ?? Interactor()
            
            transitionNavMode(to: profileVC)
        } else {
            if tagSearchResult[indexPath.row].posts.count > 0 {
                let playVC = Utils.viewControllerWith("PostPlayVC") as! PostPlayVC
                playVC.medias = tagSearchResult[indexPath.row].posts
                
                playVC.transitioningDelegate = self
                playVC.interactor = interactor
                
                transitionNavMode(to: playVC)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84.0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -10 {
            scrollView.contentOffset = CGPoint(x: 0, y: -10)
        }
    }
}
extension Notification.Name {
    static let searchViewEnable = Notification.Name("SearchViewEnable")
    static let searchViewDisable = Notification.Name("SearchViewDisable")
}
