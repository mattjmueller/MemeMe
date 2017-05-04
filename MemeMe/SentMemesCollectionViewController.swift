//*********************************************************
// SentMemesCollectionViewController.swift
// MemeMe
//
// Created by Matthew Mueller on 4/15/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit

class SentMemesCollectionCollectionViewController: UICollectionViewController {
	//******************************************************
	// MARK: - Private Properties
	//******************************************************
	
	@IBOutlet weak private var flowLayout: UICollectionViewFlowLayout!
	private var memes: [Meme]!
	
	//******************************************************
	// MARK: - Life Cycle
	//******************************************************
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		memes = appDelegate.memes
		collectionView!.reloadData()
		reflowCollectionCells()
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animate(alongsideTransition: { _ in
			self.reflowCollectionCells()
		}, completion: nil)
	}
	
	func reflowCollectionCells() {
		let space:CGFloat = 3.0
		let memesPerRow: CGFloat =  traitCollection.horizontalSizeClass == .compact ? 3 : 5
		
		let dimension = (view.frame.size.width - ((memesPerRow - 1) * space)) / memesPerRow
		flowLayout.minimumInteritemSpacing = space
		flowLayout.minimumLineSpacing = space
		flowLayout.itemSize = CGSize(width: dimension, height: dimension)
	}
	
	
	//******************************************************
	// MARK: - Collection View Data Source
	//******************************************************
	
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return memes.count
	}

	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SentMemeCollectionViewCell", for: indexPath) as! SentMemeCollectionViewCell
		cell.memePreviewImageView.image = memes[(indexPath as NSIndexPath).row].memedImage
		return cell
	}

	
	//******************************************************
	// MARK: - Collection View Delegate
	//******************************************************
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let displayMemeController = self.storyboard!.instantiateViewController(withIdentifier: "DisplayMemeViewController") as! DisplayMemeViewController
		let memeToDisplay = memes[(indexPath as NSIndexPath).row]
		displayMemeController.meme = memeToDisplay
		navigationController!.pushViewController(displayMemeController, animated: true)
	}
}
