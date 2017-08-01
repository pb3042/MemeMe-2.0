//
//  ViewController.swift
//  MemeMe 2.0
//
//  Created by Paul Brann on 7/20/17.
//  Copyright © 2017 Paul Brann. All rights reserved.
//
// MemeMe 2.0

import UIKit

class MemeEditorViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {
    
    let memeTextAttributes = [
        NSStrokeWidthAttributeName: -3.0,
        NSForegroundColorAttributeName: UIColor.white,
        NSStrokeColorAttributeName: UIColor.black,
        NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 35)!] as [String : Any]
    
    var memes: [Meme]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        memes = appDelegate.memes
        
        initialize(topTextBox, with: topTextDefaultValue)
        initialize(bottomTextBox, with: bottomTextDefaultValue)
        
        
        memeImageView.contentMode = .scaleAspectFit
    }
    
    @IBOutlet weak var memeImageView: UIImageView!
    
    @IBOutlet weak var albumPicker: UIBarButtonItem!
    
    @IBOutlet weak var cameraPicker: UIBarButtonItem!
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var bottomToolBar: UIToolbar!
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var bottomTextBox: UITextField!
    
    @IBOutlet weak var topTextBox: UITextField!
    
    @IBAction func albumPicker(_ sender: UIBarButtonItem) {
        pickImageFromAlbumOrCamera(source: UIImagePickerControllerSourceType.photoLibrary)
    }
    
    @IBAction func cameraPicker(_ sender: UIBarButtonItem) {
        pickImageFromAlbumOrCamera(source: UIImagePickerControllerSourceType.camera)
    }
    
    func pickImageFromAlbumOrCamera (source:UIImagePickerControllerSourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            memeImageView.image = image
            dismiss(animated: true, completion: nil)
        }
    }
    
    func initialize(_ textField:UITextField, with defaultText: String) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self
        textField.text = defaultText
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM" {
            textField.text = ""
        }
    }
    
    func toolNavbarVisibility(hide: Bool) {
        navigationBar.isHidden = hide
        bottomToolBar.isHidden = hide
    }
    
    func generateMemedImage() -> UIImage {
        
        toolNavbarVisibility(hide: true)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame,afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolNavbarVisibility(hide: false)
        
        return memedImage
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        view.frame.origin.y = 0
        if textField == topTextBox && topTextBox.text == "" {
            topTextBox.text = "TOP"
        }
            
        else if textField == bottomTextBox && bottomTextBox.text == "" {
            bottomTextBox.text = "BOTTOM"
        }
    }
    
    
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        let memedImage = generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [memedImage],applicationActivities: nil)
        
        activityViewController.completionWithItemsHandler = {
            activity,completed, items, error in
            if completed {
                
                self.save(memedImage: memedImage)
                
                self.dismiss(animated: true, completion: nil)
                
                self.navigationController!.popToRootViewController(animated: true)
                
            }
        }
        
        present(activityViewController, animated: true, completion: nil)
    }
    
    func save(memedImage: UIImage) {
        
        let memedImage = generateMemedImage()
        
        let meme = Meme(topText: topTextBox.text!, bottomText: bottomTextBox.text!, originalImage: memeImageView.image, memedImage:memedImage)
        
        let object = UIApplication.shared.delegate
        
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
        
        
    }
    
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        memeImageView.image = nil
        topTextBox.text = topTextDefaultValue
        bottomTextBox.text = bottomTextDefaultValue
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraPicker.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        subscribeToKeyboardNotifications()
        
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func keyboardWillShow(_ notification:Notification) {
        if bottomTextBox.isFirstResponder {
            self.view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification:Notification) {
        if bottomTextBox.isFirstResponder {
        view.frame.origin.y = 0
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
    }
    
    func getKeyboardHeight(_ notificaion: Notification) -> CGFloat {
        let userInfo = notificaion.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    }



let topTextDefaultValue = "TOP"
let bottomTextDefaultValue = "BOTTOM"
