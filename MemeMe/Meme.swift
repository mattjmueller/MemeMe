//*********************************************************
// Meme.swift
// MemeMe
//
// Created by Matthew Mueller on 4/9/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit

struct Meme: Equatable {
	let image: UIImage
	let topText: String
	let bottomText: String
	let memedImage: UIImage
	
	static func isValid(image: UIImage, topText: String, bottomText: String) -> Bool {
		return !(topText.isEmpty && bottomText.isEmpty)
	}
}

func ==(lhs: Meme, rhs: Meme) -> Bool {
	return lhs.image.isEqual(rhs.image) &&
			 lhs.topText == rhs.topText &&
			 lhs.bottomText == rhs.bottomText &&
			 lhs.memedImage == rhs.memedImage
}
