//
//  CommentViewController.swift
//  NowYou
//
//  Created by Apple on 12/28/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import LocalizedTimeAgo
import IQKeyboardManagerSwift

class CommentViewController: BaseViewController {

    @IBOutlet weak var tblComments: UITableView!
    @IBOutlet weak var inputViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnProfile: UIImageView!
    
    @IBOutlet weak var tblBottomOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    
    fileprivate var textViewHeightConstraintValue: CGFloat!
    
    var media: Media!
    
    var comments = [Comment]()
    var mediaRef: DatabaseReference!

    var parentId: String = ""
    var parentName: String = ""
    
    var selectedCell: MessageTableViewCell!
    var selectedComment: Comment!
    
    var isLike : Bool = false
    var isDelete : Bool = false
    var isCommentInComment : Bool = false
    let identifier1 = "messageCell"
    let identifier2 = "replyCell"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IQKeyboardManager.shared.enable = false
        
        btnSend.setCircular()
        btnProfile.setCircular()
        
        textViewHeightConstraintValue = inputViewHeightConstraint.constant
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = UIColor(hexValue: 0x979797).cgColor
        textView.setRoundCorner(radius: textView.frame.height / 2)
        textView.clipsToBounds = true
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
        textView.font = UIFont.systemFont(ofSize: 17)
        btnProfile.sd_setImage(with: URL(string: Utils.getFullPath(path: (UserManager.currentUser()?.userPhoto)!)), placeholderImage: PLACEHOLDER_IMG, options: .lowPriority, completed: nil)
            
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIWindow.keyboardDidShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIWindow.keyboardWillHideNotification, object: nil)
        addRigthSwipe()
        joinMedia()
        textView.becomeFirstResponder()
        updateDeletedComment()
        updateComment()
        loadComments()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        view.endEditing(true)
        IQKeyboardManager.shared.enable = true
    }
    
    func addRigthSwipe(){
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
       if (sender.direction == .right) {
           dismiss(animated: true, completion: nil)
           print("Swipe right")
       }
    }
    // MARK: - Notifications
    @objc func keyboardWasShown(notification: Notification) {
        print ("keyboard was shown")
        if let keyboardSize = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            print("keyboard height = \(keyboardSize.height)")
            updateUIWithKeyboardHeight(keyboardHeight: keyboardSize.height - view.safeAreaInsets.bottom, duration: 0.3)
        }
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        print ("keyboard was hidden")
        updateUIWithKeyboardHeight(keyboardHeight: 0.0, duration: 0.3)
    }
    
    func updateUIWithKeyboardHeight (keyboardHeight: CGFloat, duration: CGFloat) {
        if keyboardHeight == self.tblBottomOffsetConstraint.constant {
            return
        }
        
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.tblBottomOffsetConstraint.constant = keyboardHeight
            
            DispatchQueue.main.async {
                if self.comments.count > 0 {
                    self.tblComments.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .bottom, animated: true)
                }
            }
        }
    }
    
    
    fileprivate func setTextViewHeight(_ textView: UITextView, height: CGFloat) {
        if inputViewHeightConstraint.constant != height {
            if ( height <= 100 ) {
                inputViewHeightConstraint.constant = height
            }
            textView.contentSize = CGSize(width: textView.bounds.width, height: height)
        }
    }

    func resetTextViewNotes() {
        DispatchQueue.main.async {
            self.textView.text = ""
            
            self.setTextViewHeight(self.textView, height: self.textViewHeightConstraintValue)
            
            self.textView.selectedTextRange = self.textView.textRange(from: self.textView.beginningOfDocument, to: self.textView.beginningOfDocument)
        }
    }
    
    @IBAction func onPost(_ sender: Any) {
        guard let text = textView.text else {
            return
        }
        guard text.count > 0 else {
            return
        }
        sendComment()
    }
    
    @IBAction func onBack(_ sender: Any) {
       dismiss(animated: true, completion: nil)
    }
    @IBAction func onLike(_ sender: UIButton) {
        isLike = true
        let index = sender.tag - 1000
        if comments.count > 0
        {
            let comment = comments[index]
            onShowCommentThread(comment)
        }
    }
    @IBAction func onCommentInComment(_ sender: UIButton) {
        isCommentInComment = true
        textView.text = ""
        let index = sender.tag - 2000
        if comments.count > 0
        {
           let comment = comments[index]
           textView.text = "@\(comment.username) "
           onShowCommentThread(comment)

        }
    }
    @IBAction func onDelete(_ sender: UIButton) {
        isDelete = true
        let index = sender.tag - 3000
        if comments.count > 0
        {
            let comment = comments[index]
            if comment.userId == UserManager.currentUser()?.userID {
                onShowCommentThread(comment)
            }
        }
    }
}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let comment = comments[indexPath.row]
        let cellId =  comment.parentId == "" ? identifier1 : identifier2
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MessageTableViewCell
        cell.avatarImg.tag = indexPath.row
        cell.senderLbl.text = comment.username
        if comment.parentName == "" {
            cell.msgLbl.text = comment.comment
        }else{
            cell.msgLbl.text = comment.comment
        }
        
        cell.likeCountLbl.text = "\(comment.likeCount)" + " likes"
        print (Utils.getFullPath(path: comment.photo))
        cell.avatarImg.sd_setImage(with: URL(string: Utils.getFullPath(path: comment.photo)), placeholderImage: PLACEHOLDER_IMG, options: .refreshCached, completed: nil)

        cell.timeLbl.text = comment.created_at.timeAgo()
        cell.likeBtn.tag = 1000 + indexPath.row
        cell.commentBtn.tag = 2000 + indexPath.row
        if comment.userId == UserManager.currentUser()?.userID {
            cell.deleteBtn.tag = 3000 + indexPath.row
            cell.deleteBtn.alpha = 1.0
        }else{
            cell.deleteBtn.alpha = 0.0
        }
        // -----comment thread
        if comment.like == 1 {
            cell.likeBtn.setImage(UIImage(named: "NY_post_like"), for: .normal)
        }else{
            cell.likeBtn.setImage(UIImage(named: "NY_post_dislike"), for: .normal)
        }
        return cell
    }
    
    //------Comment Thread
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CommentViewController {
    
    func joinMedia(){
          guard let currentUser = UserManager.currentUser() else {
              return
          }
        mediaRef = Database.database().reference().child("Media").child("\(String(describing: media.id))").child("MediaViewer")
      }
    
    func onShowCommentThread( _ comment: Comment) {
        // show picker
        if isLike == true {
            if comment.like == 1 {
                self.sendUnlikeComment( comment)
            }else{
                self.sendLikeComment( comment)
            }
            self.isLike = false
        } else if isCommentInComment == true {
            self.sendCommentInComment( comment)
            self.isCommentInComment = false
        } else if isDelete == true {
            self.sendDeleteComment( comment)
            self.isDelete = false
        }
    }
    
    func sendLikeComment( _ comment : Comment){
        mediaRef.child("\(comment.commentId)").updateChildValues(["like":1, "likeCount": comment.likeCount + 1])
    }
    func sendUnlikeComment( _ comment : Comment){
        mediaRef.child("\(comment.commentId)").updateChildValues(["like":0, "likeCount": comment.likeCount - 1])
    }
    func sendCommentInComment( _ comment : Comment){
        textView.becomeFirstResponder()
        parentId = comment.commentId
        parentName = comment.username
    }
    func sendDeleteComment( _ comment : Comment){
        mediaRef.child("\(comment.commentId)").removeValue()
        for commentMember in self.comments {
            if commentMember.parentId == comment.commentId {
                sendDeleteComment(commentMember)
            }
        }
    }
    func sendComment(){
        let user = UserManager.currentUser()!
        let data : [String: Any] = ["comment": textView.text ?? "", "username": user.username ?? "", "photo": user.userPhoto!, "timestamp": Date().timeIntervalSince1970, "userId": user.userID ?? "", "parentId": parentId, "parentName": parentName, "like": 0, "likeCount": 0]
        mediaRef.childByAutoId().setValue(data)
        textView.text = ""
        parentId = ""
        parentName = ""
    }
    
    private func loadComments(){
        // load comments
        comments.removeAll()
        mediaRef.observe(.childAdded, with: { (snapshot) in
            if snapshot.exists() {
                if let value = snapshot.value as? [String: Any]{
                    let key = snapshot.key
                    let comment = Comment(json: value)
                        if key != ""{
                            comment.commentId = key
                            if let index = self.comments.firstIndex(where: {$0.commentId == comment.parentId}) {
                                self.comments.insert(comment, at: index + 1)
                            }else{
                                self.comments.append(comment)
                            }
                        }
                }
                if self.comments.count == 0 {
                    self.tblComments.reloadData()
                } else {
                    self.tblComments.reloadData()
                    // scroll to bottom
                    self.tblComments.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .top, animated: true)
                }
            } else {
            }
        })
    }
    
    private func updateComment(){
        // load comments
        self.mediaRef.observe(.childChanged, with: { (snapshot) in
            if snapshot.exists() {
                if let value = snapshot.value as? [String: Any]{
                    let key = snapshot.key
                    let comment = Comment(json: value)
                    if comment.userId != 0 {
                        comment.commentId = key
                        if let index = self.comments.firstIndex(where: {$0.commentId == key}) {
                            self.comments[index].like = comment.like
                            self.comments[index].likeCount = comment.likeCount
                        }
                    }
                }
                if self.comments.count == 0 {
                    self.tblComments.reloadData()
                } else {
                    self.tblComments.reloadData()
                    self.tblComments.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .top, animated: true)
                }
            } else {
            }
        })
    }
    
    private func updateDeletedComment(){
        // load comments
        self.comments.removeAll()
        mediaRef.observe(.childRemoved, with: { (snapshot) in
            if snapshot.exists() {
                if let value = snapshot.value as? [String: Any]{
                    let key = snapshot.key
                    let comment = Comment(json: value)
                    if comment.userId != 0 {
                        comment.commentId = key
                        if let index = self.comments.firstIndex(where: {$0.commentId == key})
                        {
                            self.comments.remove(at: index)
                        }
                    }
                }
                if self.comments.count == 0 {
                    self.tblComments.reloadData()
                } else {
                    self.tblComments.reloadData()
                    self.tblComments.scrollToRow(at: IndexPath(row: self.comments.count - 1, section: 0), at: .top, animated: true)
                }
            } else {
            }
        })
    }
}
