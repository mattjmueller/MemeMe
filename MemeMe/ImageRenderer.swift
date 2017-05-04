//*********************************************************
// ImageRenderer.swift
// MemeMe
//
// Created by Matthew Mueller on 4/5/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit

struct MemeImageRenderer {
	func renderMemeLayout(_ layout: MemeLayoutService.MemeLayout) -> UIImage? {
		guard layout.topLine.fits && layout.bottomLine.fits else {
			return nil
		}
		
		let scale = UIScreen.main.scale
		let memeSize = layout.sourceImage.size
		UIGraphicsBeginImageContextWithOptions(memeSize, false, scale)
		layout.sourceImage.draw(in: CGRect(origin: CGPoint.zero, size: memeSize))
		
		let topRect: CGRect = CGRect(x: (memeSize.width - layout.topLine.size.width) / 2,
		                             y: 0,
		                             width: layout.topLine.size.width,
		                             height: layout.topLine.size.height)
		let bottomRect: CGRect = CGRect(x: (memeSize.width - layout.bottomLine.size.width) / 2,
		                                y: memeSize.height - layout.bottomLine.size.height,
		                                width: layout.bottomLine.size.width,
		                                height: layout.bottomLine.size.height)
		
		renderMemeLine(layout.topLine, in: topRect)
		renderMemeLine(layout.bottomLine, in: bottomRect)

		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return newImage
	}
	
	func renderMemeLine(_ layout: MemeLayoutService.MemeLayout.MemeLineLayout, in rect: CGRect) {
		let text = !layout.text.isEmpty ? layout.text : ""
		let attributes: [String:Any] = [
			NSStrokeColorAttributeName: layout.fits ? UIColor.black : UIColor.red,
			NSForegroundColorAttributeName: layout.fits ? UIColor.white : UIColor.magenta,
			NSFontAttributeName: layout.font,
			NSStrokeWidthAttributeName: -layout.strokeWidth
		]

		text.draw(in: rect, withAttributes: attributes)
	}
}
