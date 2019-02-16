//
//  ViewController.swift
//  Meme 1.0
//
//  Created by Ahmed Alsamani on 13/11/2018.
//  Copyright © 2018 Ahmed Alsamani. All rights reserved.
//

import UIKit


struct Meme {
    let topText: String
    let bottomText: String
    let originalImage: UIImage
    let memedImage: UIImage
}

class ViewController: UIViewController , UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var ButtomTextField: UITextField!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var toolBar: UIToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetUIConfig()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool)  {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        setupTextFieldStyle(topTextField)
        setupTextFieldStyle(ButtomTextField)
        subscribeToKeyboardNotifications()
      }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    // MARK: reset UI Config
    
    func resetUIConfig() {
        imagePickerView.image = nil
        shareButton.isEnabled = false
        topTextField.text = "TOP"
        ButtomTextField.text = "BOTTOM"
    }
    
    // MARK: Pick Meme Image
    
    var memedImage = UIImage()
    
    func save(memedImage: UIImage?) {
        // Create the meme
        let _ = Meme(topText: topTextField.text!, bottomText: ButtomTextField.text!, originalImage:  imagePickerView.image!, memedImage: memedImage!)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imagePickerView.image = image
            shareButton.isEnabled = true
        }
        
        imagePickerView.contentMode = .scaleAspectFit
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Make Meme Image
    
    func barView( hidden: Bool) {
        navigationController?.isNavigationBarHidden  = hidden
        toolBar.isHidden = hidden
    }
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        barView(hidden: true)
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        //  Show toolbar and navbar
        barView(hidden: false)
        return memedImage
    }
    
    func pickAnImage(_ isFromCamera: Bool) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = isFromCamera ? .camera : .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    // MARK: @IBAction
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImage(true)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickAnImage(false)
    }
    
    @IBAction func cancelButton(_ sender: Any) {
        resetUIConfig()
    }
    
    // MARK: shareButton
    @IBAction func shareButton(_ sender: UIBarButtonItem) {
        
        let memedImage: UIImage = self.generateMemedImage()
        let controller = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        controller.completionWithItemsHandler = {
            (activityType, complete, returnedItems, activityError ) in
            if complete {
                self.save(memedImage: memedImage)
            }
        }
        present(controller, animated: true, completion: nil)
        
    }
    
    
    // MARK: Keyboard notifications
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if ButtomTextField.isFirstResponder {
        view.frame.origin.y -= view.frame.origin.y == 0 ? getKeyboardHeight(notification) : 0
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
}
    // MARK: TextField
extension ViewController :UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if(textField.text == "TOP" || textField.text == "BOTTOM") {
            textField.text = ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func setupTextFieldStyle(_ textField: UITextField) {
        
        let memeTextAttributes: [NSAttributedString.Key: Any] = [
            .strokeColor: UIColor.black,
            .foregroundColor: UIColor.white,
            .font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            .strokeWidth: -4
        ]
        
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        textField.borderStyle = .none
        
    }
}

