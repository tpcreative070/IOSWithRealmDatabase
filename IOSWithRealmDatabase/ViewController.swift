//
//  ViewController.swift
//  IOSWithRealmDatabase
//
//  Created by Mac10 on 6/15/18.
//  Copyright © 2018 Mac10. All rights reserved.
//

import UIKit

class ViewController: UIViewController ,UITextFieldDelegate{
    
    @IBOutlet weak var textFieldInput: UITextField!
    @IBOutlet weak var tbView: UITableView!
    var mList = [TaskManager]()
    var task : TaskManager!
    var isEdit : Bool = false
    var isShow : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.textFieldInput.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateView()
    }
    
    func updateView(){
        TaskManager.shared.getAll{ [weak self] list in
            self?.mList = list
            self?.tbView.reloadData()
            self?.textFieldInput.text = ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func btnSend(_ sender: UIButton) {
        if !(textFieldInput.text?.isEmpty)! {
            if isEdit{
                if let mTask  = task {
                    let task = TaskManager()
                    task.key = mTask.key
                    task.task = textFieldInput.text!
                    task.date = TaskManager.shared.getCurrentDateTime()
                    TaskManager.shared.created(task: task)
                }
            }else{
                let task = TaskManager()
                task.task = textFieldInput.text!
                task.key = String(TaskManager.shared.currentTimeInMiliseconds())
                task.date = TaskManager.shared.getCurrentDateTime()
                TaskManager.shared.created(task: task)
            }
            updateView()
        }
        isEdit = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textFieldInput.resignFirstResponder()
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        // let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey]
        // print("duration",duration)
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight : Int = Int(keyboardSize.height)
            if let height = UserDefaults.standard.value(forKey: "keyboardHeight") as? (Int) {
                if(!isShow){
                      moveTextField(textFieldInput, moveDistance: -height as Int, moveDuration: 0.43, up:true)
                    isShow = true
                }

            }else{
                UserDefaults.standard.set(keyboardHeight, forKey: "keyboardHeight")
                moveTextField(textFieldInput, moveDistance: -keyboardHeight, moveDuration: 0.43, up: true)
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        if let height = UserDefaults.standard.value(forKey: "keyboardHeight") as? (Int) {
            isShow = false
            moveTextField(textFieldInput, moveDistance: -height as Int, moveDuration: 0.25, up: false)
        }
    }

    func moveTextField(_ textField: UITextField, moveDistance: Int, moveDuration: Double, up: Bool) {
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}

extension ViewController : UITableViewDelegate {
    
}

extension ViewController : UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "identifier")
        let staff = mList[indexPath.row]
        cell.textLabel?.text = staff.task
        cell.detailTextLabel?.text = "\(staff.date)"
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let moreRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Edit", handler:{action, indexpath in
            self.task = self.mList[indexPath.row]
            self.isEdit = true
            self.textFieldInput.text = self.task.task
            print("MORE•ACTION")
        });
        moreRowAction.backgroundColor = UIColor(red: 0.298, green: 0.851, blue: 0.3922, alpha: 1.0);
        let deleteRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "Delete", handler:{action, indexpath in
            self.isEdit = false
            print("DELETE•ACTION")
            TaskManager.shared.delete(task : self.mList[indexPath.row])
            self.updateView()
        });
        return [deleteRowAction, moreRowAction]
    }
    
}




