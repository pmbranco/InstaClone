//
//  FeedVC.swift
//  Social_App
//
//  Created by Gabriel Benbow on 1/25/16.
//  Copyright © 2016 Gabriel Benbow. All rights reserved.
//

import UIKit
import Firebase


class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

	
	@IBOutlet weak var feedTV: UITableView!
	
	var posts = [Post]()
	static var imageCache = NSCache()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		feedTV.delegate = self
		feedTV.dataSource = self
		DataService.ds.REF_POSTS.observeEventType(.Value, withBlock: { snapShot in
			print(snapShot.value)
			
			if let snapshots = snapShot.children.allObjects as? [FDataSnapshot] {
				self.posts = []
				for snap in snapshots {
					
					
					if let postDict = snap.value as? Dictionary<String,AnyObject> {
						let key = snap.key
						let post = Post(postKey: key, dictionary: postDict)
						self.posts.append(post)
					}
				}
			}
			
			self.feedTV.reloadData()
		})
	}
	
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return posts.count
		
	}
	
	func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
		
	}
	
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let post = posts[indexPath.row]
		
		
		if let cell = feedTV.dequeueReusableCellWithIdentifier("PostCell") as? PostCell {
			cell.request?.cancel()
			var img: UIImage?
			
			if let url = post.imageURL {
				img = FeedVC.imageCache.objectForKey(url) as? UIImage
				
			}
			
			cell.configureCell(post, img: img)
			return cell
		} else {
			return PostCell()
		}
	}
}
