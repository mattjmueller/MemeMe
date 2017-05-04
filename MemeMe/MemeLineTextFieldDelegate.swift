//
//  MemeLineTextFieldDelegate.swift
//  MemeMe
//
//  Created by Matthew Mueller on 4/10/17.
//  Copyright © 2017 Matthew Mueller. All rights reserved.
//

import UIKit

class MemeLineTextFieldDelegate: UITextFieldDelegate {
	private var layoutService: MemeLayoutService
	private var placeholder: String
	
	init(layoutService: MemeLayoutService, placeholder: String) {
		self.layoutService = layoutService
		self.placeholder = placeholder
	}
	
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		if topLineTextField.isEditing {
			mode = .editingTop
		} else {
			mode = .editingBottom
		}
	}
	
	func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
		mode = .viewing
	}
	
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		let newString = NSString(string: textField.text ?? "").replacingCharacters(in: range, with: string)
		styleMemeLine(for: newString, in: textField)
		return true
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true;
	}
	
	
	func styleMemeLine(for text: String, in textField: UITextField) {
		let lineLayout = layoutService.layoutMemeLine(text: text, inImageSize: memeImageView.image!.size, placeholder: "Top")
		textField.defaultTextAttributes = [
			NSStrokeColorAttributeName: lineLayout.fits ? UIColor.black : UIColor.red,
			NSForegroundColorAttributeName: lineLayout.fits ? UIColor.white : UIColor.magenta,
			NSFontAttributeName: lineLayout.font,
			NSStrokeWidthAttributeName: -lineLayout.strokeWidth
		]
		textField.alpha = lineLayout.text.isEmpty && !textField.isEditing ? 0.5 : 1.0
		textField.textAlignment = .center
	}
}
