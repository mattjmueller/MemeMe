//*********************************************************
// MemeLayoutService.swift
// MemeMe
//
// Created by Matthew Mueller on 4/4/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import  UIKit

struct MemeLayoutService {
	//***************************************************************************
	// MARK: - Types
	//***************************************************************************
	
	struct MemeLayout {
		var sourceImage: UIImage
		var topLine: MemeLineLayout
		var bottomLine: MemeLineLayout
		
		struct MemeLineLayout {
			let text: String
			let placeholder: String
			private(set) var font: UIFont
			let strokeWidth: CGFloat
			let fits: Bool
			let size: CGSize
			
			fileprivate init(text: String, placeholder: String, font: UIFont, strokeWidth: CGFloat, fits: Bool, size: CGSize) {
				self.text = text
				self.placeholder = placeholder
				self.font = font
				self.strokeWidth = strokeWidth
				self.fits = fits
				self.size = size
			}
		}
	}
	
	
	//***************************************************************************
	// MARK: - Fields
	//***************************************************************************
	
	private let defaultFont: UIFont =  UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!
	private let defaultStrokeWidth: CGFloat = 4.0
	private let defaultHorizontalPaddingPercent: CGFloat = 0.02
	private let minimumLineHeight: CGFloat = 0.08
	private let maximumLineHeight: CGFloat = 0.19
	private var topPlaceholder: String = "TOP"
	private var bottomPlaceholder: String = "BOTTOM"

	private(set) var currentLayout: MemeLayout?

	var image: UIImage? {
		didSet {
			if image != nil {
				currentLayout = layoutMeme()
			} else {
				currentLayout = nil
			}
		}
	}
	
	var topText: String = "" {
		didSet {
			if currentLayout != nil {
				currentLayout?.topLine = layoutMemeLine(text: topText, memeSize: image!.size, placeholder: topPlaceholder)
			}
		}
	}
	
	var bottomText: String = "" {
		didSet {
			if currentLayout != nil {
				currentLayout?.bottomLine = layoutMemeLine(text: bottomText, memeSize: image!.size, placeholder: bottomPlaceholder)
			}
		}
	}
	
	var outputScale: CGFloat = 1.0 {
		didSet {
			if image != nil {
				currentLayout = layoutMeme()
			} else {
				currentLayout = nil
			}
		}
	}
	
	
	//***************************************************************************
	// MARK: - Public Methods
	//***************************************************************************
	
	mutating func setImage(_ image: UIImage) -> MemeLayout? {
		self.image = image
		return currentLayout
	}
	
	mutating func setTopText(_ text: String) -> MemeLayout.MemeLineLayout? {
		topText = text
		return currentLayout?.topLine
	}
	
	mutating func setBottomText(_ text: String) -> MemeLayout.MemeLineLayout? {
		bottomText = text
		return currentLayout?.bottomLine
	}
	
	mutating func clear() {
		self.image = nil
		self.topText = ""
		self.bottomText = ""
	}
	
	
	//***************************************************************************
	// MARK: - Meme Layout
	//***************************************************************************
	
	private func layoutMeme() -> MemeLayout? {
		guard let image = image else { return nil }

		return MemeLayout(
			sourceImage: image,
			topLine: layoutMemeLine(text: topText, memeSize: image.size, placeholder: topPlaceholder),
			bottomLine: layoutMemeLine(text: bottomText, memeSize: image.size, placeholder: bottomPlaceholder)
		)
	}
	
	private func layoutMemeLine(text: String, memeSize: CGSize, placeholder: String) -> MemeLayout.MemeLineLayout {
		var fits: Bool
		var nsText = (!text.isEmpty ? text : placeholder) as NSString
		var font = defaultFont
		var attributes: [String:Any] {
			return [NSFontAttributeName: font,
			        NSStrokeWidthAttributeName: -defaultStrokeWidth]
		}

		let currentSize = nsText.size(attributes: attributes)
		let usableWidth = memeSize.width - (memeSize.width * defaultHorizontalPaddingPercent * 2)
		let widthRatio = currentSize.width / usableWidth
		let minHeightRatio = currentSize.height / (memeSize.height * minimumLineHeight)
		let maxHeightRatio = currentSize.height / (memeSize.height * maximumLineHeight)
		
		if widthRatio > minHeightRatio {
			font = font.withSize(font.pointSize / minHeightRatio)
			fits = false
		} else if widthRatio < maxHeightRatio {
			font = font.withSize(font.pointSize / maxHeightRatio)
			fits = true
		} else {
			font = font.withSize(font.pointSize / widthRatio)
			fits = true
		}
		
		return MemeLayout.MemeLineLayout(
			text: text,
			placeholder: placeholder,
			font: font.withSize(font.pointSize * outputScale),
			strokeWidth: defaultStrokeWidth,
			fits: fits,
			size: nsText.size(attributes: attributes)
		)
	}
}

