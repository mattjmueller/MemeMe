//*********************************************************
// DisplayMemeViewController.swift
// MemeMe
//
// Created by Matthew Mueller on 4/15/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit

class DisplayMemeViewController: UIViewController, UIScrollViewDelegate {
	//******************************************************
	// MARK: - Private/Public Properties
	//******************************************************
	
	@IBOutlet weak private var scrollView: UIScrollView!
	@IBOutlet weak private var memeImageView: UIImageView!
	private var appearing: Bool = false
	
	var meme: Meme!
	
	
	//******************************************************
	// MARK: - Life Cycle
	//******************************************************
	
	override func viewDidLoad() {
		super.viewDidLoad()
		memeImageView.image = meme.memedImage
	}
	
	override func viewWillAppear(_ animated: Bool) {
		appearing = true
		tabBarController?.tabBar.isHidden = true
	}
	
	override func viewDidLayoutSubviews() {
		if appearing {
			appearing = false
			memeImageView.layoutIfNeeded()
			setZoomLimits()
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animate(alongsideTransition: { _ in
			self.setZoomLimits()
		}, completion: nil)
	}
	
	
	//******************************************************
	// MARK: - Scroll View Delegate
	//******************************************************
	
	func viewForZooming(in scrollView: UIScrollView) -> UIView? {
		return memeImageView
	}
	
	func scrollViewDidZoom(_ scrollView: UIScrollView) {
		let verticalPadding = (scrollView.frame.height - scrollView.contentSize.height) / 2
		let horizontalPadding = (scrollView.frame.width - scrollView.contentSize.width) / 2
		
		scrollView.contentInset.top = max(0, verticalPadding)
		scrollView.contentInset.bottom = max(0, verticalPadding)
		scrollView.contentInset.left = max(0, horizontalPadding)
		scrollView.contentInset.right = max(0, horizontalPadding)
	}
	
	func setZoomLimits() {
		if let imageSize = memeImageView.image?.size {
			let fitHeight = scrollView.frame.height / imageSize.height
			let fitWidth = scrollView.frame.width / imageSize.width
			scrollView.minimumZoomScale = min(fitHeight, fitWidth)
			scrollView.zoomScale = scrollView.minimumZoomScale
		}
	}
}
