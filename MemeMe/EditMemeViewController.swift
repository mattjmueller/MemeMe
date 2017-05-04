//*********************************************************
// EditViewController.swift
// MemeMe
//
// Created by Matthew Mueller on 4/4/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit

class EditMemeViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
	//******************************************************
	// MARK: - IB Outlets
	//******************************************************
	
	@IBOutlet weak private var libraryButton: UIBarButtonItem!
	@IBOutlet weak private var cameraButton: UIBarButtonItem!
	@IBOutlet weak private var shareButton: UIBarButtonItem!
	@IBOutlet weak private var cancelButton: UIBarButtonItem!
	
	@IBOutlet weak private var verticalCenterConstraint: NSLayoutConstraint!
	@IBOutlet weak private var imageWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak private var imageHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak private var memeImageView: UIImageView!
	@IBOutlet weak private var topLineTextField: UITextField!
	@IBOutlet weak private var bottomLineTextField: UITextField!
	
	
	//******************************************************
	// MARK: - Private Properties
	//******************************************************

	enum EditorMode {
		case viewing, editingTop, editingBottom
	}
	
	private var memeLayoutService = MemeLayoutService()
	private var keyboardHeight: CGFloat = 0
	private var appearing: Bool = false

	private var mode: EditorMode = .viewing {
		didSet {
			configureUI(memeLayout: memeLayoutService.currentLayout, mode: mode)
		}
	}
	
	
	//******************************************************
	// MARK: - Life Cycle
	//******************************************************
	
	override func viewWillAppear(_ animated: Bool) {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(_:)), name: .UIKeyboardWillChangeFrame, object: nil)
		appearing = true
	}
	
	override func viewDidLayoutSubviews() {
		if appearing {
			appearing = false
			configureUI(memeLayout: memeLayoutService.currentLayout, mode: mode)
			scaleMeme(for: mode)
		}
	}
	
	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		
		coordinator.animate(alongsideTransition: { _ in
			self.scaleMeme(for: self.mode)
		}, completion: nil)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
	}
	
	
	//******************************************************
	// MARK: - Helpers
	//******************************************************
	
	func loadMeme(_ meme: Meme) {
		memeLayoutService.image = meme.image
		memeLayoutService.topText = meme.topText
		memeLayoutService.bottomText = meme.bottomText
	}
	
	func scaleMeme(for mode: EditorMode) {
		let previewSize: CGSize
		if mode != .viewing {
			// show toolbars to calculate meme size that fits
			let topSetting = navigationController!.isNavigationBarHidden
			let bottomSetting = navigationController!.isToolbarHidden
			navigationController?.isNavigationBarHidden = false
			navigationController?.isToolbarHidden = false

			// calculate display size
			previewSize = view.bounds.size
			
			// set back
			navigationController?.isNavigationBarHidden = topSetting
			navigationController?.isToolbarHidden = bottomSetting
		} else {
			previewSize = view.bounds.size
		}
		
		// now size content
		let originalContentSize = memeImageView.image?.size ?? previewSize
		let fitWidth = previewSize.width / originalContentSize.width
		let fitHeight = previewSize.height / originalContentSize.height
		let minScaleFactor = min(fitWidth, fitHeight)
		memeLayoutService.outputScale = minScaleFactor
		
		imageHeightConstraint.constant = originalContentSize.height * minScaleFactor
		imageWidthConstraint.constant = originalContentSize.width * minScaleFactor
		
		if let memeLayout = memeLayoutService.currentLayout {
			styleMemeLine(fromLayout: memeLayout.topLine, in: topLineTextField)
			styleMemeLine(fromLayout: memeLayout.bottomLine, in: bottomLineTextField)
		}
		
		let visualCenter = (topLayoutGuide.length - bottomLayoutGuide.length) / 2
		let verticalPadding = (view.frame.height - topLayoutGuide.length - bottomLayoutGuide.length - memeImageView.frame.height) / 2
		
		switch  mode {
		case .viewing:
			verticalCenterConstraint.constant = visualCenter
		case .editingTop:
			verticalCenterConstraint.constant = visualCenter - min(verticalPadding, keyboardHeight / 2)
		case .editingBottom:
			verticalCenterConstraint.constant = visualCenter - max(keyboardHeight - verticalPadding, keyboardHeight / 2)
		}
		
		view.layoutIfNeeded()
	}
	
	func keyboardWillChangeFrame(_ notification: Notification) {
		var keyboardRect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
		keyboardRect = view.window!.convert(keyboardRect, from: nil)
		let viewRect = view.convert(view.bounds, to: nil)
		let addedkeyboardHeight = viewRect.intersection(keyboardRect).size.height

		keyboardHeight = addedkeyboardHeight
		scaleMeme(for: mode)
	}

	
	//******************************************************
	// MARK: - IB Actions
	//******************************************************
	
	@IBAction func pickImage(_ sender: UIBarButtonItem) {
		var source: UIImagePickerControllerSourceType
		
		switch sender {
		case cameraButton:
			source = .camera
		case libraryButton:
			source = .photoLibrary
		default:
			return
		}
		
		let imagePicker = UIImagePickerController()
		imagePicker.delegate = self
		imagePicker.sourceType = source
		present(imagePicker, animated: true, completion: nil)
	}
	
	@IBAction func shareMeme(_ sender: UIBarButtonItem) {
		guard memeLayoutService.currentLayout != nil else {
			return
		}
		
		var imageLayoutService = memeLayoutService
		imageLayoutService.outputScale = 1.0
		
		let imageRenderer = MemeImageRenderer()
		if let memedImage = imageRenderer.renderMemeLayout(imageLayoutService.currentLayout!) {
			let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
			activityController.completionWithItemsHandler = { activity, success, items, error in
				if success {
					self.saveMeme(memedImage: memedImage)
				}
				self.dismiss(animated: true, completion: nil)
			}
			
			present(activityController, animated: true, completion: nil)
		}
	}
	
	func saveMeme(memedImage: UIImage) {
		guard let memeLayout = memeLayoutService.currentLayout else {
			return
		}
		
		let meme = Meme(image: memeLayout.sourceImage, topText: memeLayout.topLine.text, bottomText: memeLayout.bottomLine.text, memedImage: memedImage)
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		appDelegate.memes.append(meme)
	}
	
	@IBAction func cancel(_ sender: Any) {
		navigationController?.dismiss(animated: true, completion: nil)
	}
	
	
	//**********************************************************
	// Mark: - ImageControllerDelegate Conformance
	//**********************************************************
	
	func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
		if let image =  info["UIImagePickerControllerOriginalImage"] as? UIImage {
			let memeLayout = memeLayoutService.setImage(image)!
			memeImageView.image = memeLayout.sourceImage
			setText(of: topLineTextField, from: memeLayout.topLine)
			setText(of: bottomLineTextField, from: memeLayout.bottomLine)
		}
		
		picker.dismiss(animated: true, completion: nil)
	}
	
	func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
		picker.dismiss(animated: true, completion: nil)
	}
	
	
	//***************************************************************************
	// MARK: - TextField delegate
	//***************************************************************************
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		mode = textField == topLineTextField ? .editingTop : .editingBottom
	}

	func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
		mode = .viewing
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let newString = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
		let newLayout = textField == topLineTextField ? memeLayoutService.setTopText(newString) : memeLayoutService.setBottomText(newString)
		styleMemeLine(fromLayout: newLayout!, in: textField)

		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		mode = .viewing
		textField.resignFirstResponder()
		return true;
	}

	
	//******************************************************
	// MARK: - UI Rendering
	//******************************************************
	
	func configureUI(memeLayout: MemeLayoutService.MemeLayout?, mode: EditorMode) {
		let memeEmpty = memeLayout == nil
		let currentlyEditing = mode != .viewing
		let cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
		let validMeme = memeEmpty ? false : Meme.isValid(image: memeLayout!.sourceImage, topText: memeLayout!.topLine.text, bottomText: memeLayout!.bottomLine.text)
		
		if let memeLayout = memeLayout {
			setText(of: topLineTextField, from: memeLayout.topLine)
			setText(of: bottomLineTextField, from: memeLayout.bottomLine)
		}
		
		navigationController?.isNavigationBarHidden = currentlyEditing
		navigationController?.isToolbarHidden = currentlyEditing
		shareButton.isEnabled = validMeme
		cancelButton.isEnabled = !currentlyEditing
		cameraButton.isEnabled = cameraAvailable && !currentlyEditing
		libraryButton.isEnabled = !currentlyEditing
		memeImageView.isHidden = memeEmpty
	}
	
	func styleMemeLine(fromLayout lineLayout: MemeLayoutService.MemeLayout.MemeLineLayout, in textField: UITextField) {
		textField.defaultTextAttributes = [
			NSStrokeColorAttributeName: lineLayout.fits ? UIColor.black : UIColor.red,
			NSForegroundColorAttributeName: lineLayout.fits ? UIColor.white : UIColor.magenta,
			NSFontAttributeName: lineLayout.font,
			NSStrokeWidthAttributeName: -lineLayout.strokeWidth
		]
		
		textField.alpha = lineLayout.text.isEmpty && !textField.isEditing ? 0.6 : 1.0
		textField.textAlignment = .center
	}
	
	func setText(of textField: UITextField, from memeLineLayout: MemeLayoutService.MemeLayout.MemeLineLayout) {
		if !memeLineLayout.text.isEmpty || textField.isEditing {
			textField.text = memeLineLayout.text
		} else {
			textField.text = memeLineLayout.placeholder
		}
		
		styleMemeLine(fromLayout: memeLineLayout, in: textField)
	}
}
