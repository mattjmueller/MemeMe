//*********************************************************
// AppDelegate.swift
// MemeMe
//
// Created by Matthew Mueller on 4/4/17.
// Copyright © 2017 Matthew Mueller. All rights reserved.
//*********************************************************

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	var memes = [Meme]()
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}
}

