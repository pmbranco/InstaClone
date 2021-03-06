//
//  photoVC.swift
//  Social_App
//
//  Created by Gabriel Benbow on 1/29/16.
//  Copyright © 2016 Gabriel Benbow. All rights reserved.
//

import UIKit
import Alamofire
import Firebase


class UploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	
	var imagePicker: UIImagePickerController!
	var imageSelected = false
	var postRef: Firebase!
	var _post: Post!
	
	@IBOutlet weak var imagelabel: UILabel!
	
	@IBOutlet weak var imageSelectorBG: UIImageView!
	@IBOutlet weak var postField: materialTextField!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		imagePicker = UIImagePickerController()
		imagePicker.delegate = self
	}
	
	@IBAction func selectImage(sender: UITapGestureRecognizer) {
		presentViewController(imagePicker, animated: true, completion: nil)
		
	}
	
	@IBAction func makePost(sender: AnyObject) {
		
		if let txt = postField.text where txt != "" {
			
			if let img = imageSelectorBG.image where imageSelected == true {
				
				let urlStr = "https://api.imageshack.com/v2/images"
				let url = NSURL(string: urlStr)!
				let imgData = UIImageJPEGRepresentation(img, 0.2)!
				let keyData = "12DJKPSU5fc3afbd01b1630cc718cae3043220f3".dataUsingEncoding(NSUTF8StringEncoding)!
				let keyJSON = "json".dataUsingEncoding(NSUTF8StringEncoding)!
				
				Alamofire.upload(.POST, url, multipartFormData: { multipartFormData in
					
					multipartFormData.appendBodyPart(data: imgData, name: "fileupload", fileName: "image", mimeType: "image/jgp")
					multipartFormData.appendBodyPart(data: keyData, name: "key")
					multipartFormData.appendBodyPart(data: keyJSON, name: "formart")
					
					}, encodingCompletion: { encodingResult in
						
						switch encodingResult {
							
						case .Success(let upload, _, _):
							
							
							upload.responseJSON { response in
								if let info = response.result.value as? Dictionary<String, AnyObject> {
									if let dict = info["result"] as? Dictionary<String,AnyObject> {
										if let images = dict["images"]?[0] as? Dictionary<String,AnyObject> {
											if let imgLink = images["direct_link"] as? String {
												let finalLink = "http://\(imgLink)"
												self.postToFirebase(finalLink)
											}
										}
									}
								}
							}
						case .Failure(let error):
							print(error)
						}
				})
				
			} else {
				self.postToFirebase(nil)
			}
		}
		
	}


	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
		imagePicker.dismissViewControllerAnimated(true, completion: nil)
		imageSelectorBG.image = image
		imagelabel.hidden = true
		imageSelected = true
		
	}
	
	
	
	func postToFirebase(imgUrl: String?)  {
		let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as! String
		let now = NSDate()
		var post: Dictionary<String, AnyObject> = [
			"description": postField.text!,
			"likes": 0,
			"date": "\(now)",
			"userKey": "\(uid)"
		]
		
		
		if imgUrl != nil {
			post["imageURL"] = imgUrl!
		}
		
		let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
			firebasePost.setValue(post) { Err, FireBase in
				FireBase.observeEventType(.Value, withBlock: { snapshot in
					if snapshot.exists() {
					self.addPost(snapshot.key)
				}
			})
		}

		postField.text = ""
		imageSelectorBG.image = nil
		imagelabel.hidden = false
		imageSelected = false
	}
	
	func addPost(post:String) {
		let post = post
		postRef = DataService.ds.REF_USER_CURRENT.childByAppendingPath("posts").childByAppendingPath(post)
		postRef.setValue(true)
		
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		view.endEditing(true)
	}
	
	
	
	
}
