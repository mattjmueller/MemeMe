//*********************************************************
// SentMemesTableViewController.swift
// MemeMe
//
// Created by Matthew Mueller on 4/15/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit

class SentMemesTableViewController: UITableViewController {
	//******************************************************
	// MARK: - Private Properties
	//******************************************************
	
	private var memes: [Meme]! {
		didSet {
			let appDelegate = UIApplication.shared.delegate as! AppDelegate
			if memes != appDelegate.memes {
				appDelegate.memes = memes
			}
		}
	}
	

	//******************************************************
	// MARK: - Life Cycle
	//******************************************************
	
	override func viewDidLoad() {
		super.viewDidLoad()
		navigationItem.leftBarButtonItem = self.editButtonItem
	}
	
	override func viewWillAppear(_ animated: Bool) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		memes = appDelegate.memes
		tableView!.reloadData()
	}
	
	
	//******************************************************
	// MARK: - Table View Data Source
	//******************************************************
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return memes.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "SentMemeTableViewCell")! as! SentMemeTableViewCell
		let memeForCell = memes[(indexPath as NSIndexPath).row]
		cell.memePreviewImageView.image = memeForCell.memedImage
		cell.topLineLabel.text = memeForCell.topText
		cell.bottomLineLabel.text = memeForCell.bottomText
		return cell
	}
	
	
	//******************************************************
	// MARK: - Table View Delegate
	//******************************************************
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if !tableView.isEditing {
			let displayMemeController = self.storyboard!.instantiateViewController(withIdentifier: "DisplayMemeViewController") as! DisplayMemeViewController
			let memeToDisplay = memes[(indexPath as NSIndexPath).row]
			displayMemeController.meme = memeToDisplay
			navigationController!.pushViewController(displayMemeController, animated: true)
		} else {
			tableView.deselectRow(at: indexPath, animated: false)
		}
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			memes.remove(at: indexPath.row)
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}
}
