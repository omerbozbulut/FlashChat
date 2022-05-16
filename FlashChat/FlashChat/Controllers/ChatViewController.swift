//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase


class ChatViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages : [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        title = K.appName
        navigationItem.hidesBackButton = true
        
        tableView.register(UINib(nibName: K.cellNibName, bundle: nil), forCellReuseIdentifier: K.cellIdentifier)
        loadMessages()
    }
    
    func loadMessages(){
        
        db.collection(K.FStore.collectionName).order(by: K.FStore.dateField).addSnapshotListener{ (querySnapshot, err) in
            self.messages = []
            if let e = err {
                print("Error getting documents: \(e)")
            } else {
                if let snapshotDoc = querySnapshot?.documents{
                    for doc in snapshotDoc{
                        let data = doc.data()
                        
                        if let body = data[K.FStore.bodyField] as? String,
                           let sender = data[K.FStore.senderField] as? String{
                            let message = Message(sender: sender, body: body)
                            self.messages.append(message)
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            
                                // scroll
                                let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                            }
                        }
                    }
                }
            }
        }

    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        if let messageBody = messageTextfield.text,
           let messageSenderEmail = Auth.auth().currentUser?.email{
            db.collection(K.FStore.collectionName).addDocument(data: [
                K.FStore.bodyField: messageBody,
                K.FStore.senderField: messageSenderEmail,
                K.FStore.dateField: Date().timeIntervalSince1970
            ]) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                }else{
                    // closure içinde view güncellediğimiz için main thread
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
            }

        }
         
        
    }
    

    @IBAction func LogOutPressed(_ sender: UIBarButtonItem) {
        do {
          try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
          
    }
}

extension ChatViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        
        if message.sender == Auth.auth().currentUser?.email{
            cell.leftImageView.isHidden = true
            cell.rightImageView.isHidden = false
            cell.messageBubble.backgroundColor = UIColorFromRGB(rgbValue: 0x92B4EC)
        }else{
            cell.leftImageView.isHidden = false
            cell.rightImageView.isHidden = true
        }
        
        cell.label.text = message.body
        return cell
    }
    
    func UIColorFromRGB(rgbValue: UInt) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
}

