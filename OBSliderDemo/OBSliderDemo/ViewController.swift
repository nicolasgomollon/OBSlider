//
//  ViewController.swift
//  OBSliderDemo
//
//  Objective-C code Copyright (c) 2011 Ole Begemann. All rights reserved.
//  Swift adaptation Copyright (c) 2014 Nicolas Gomollon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	var slider = OBSlider(frame: CGRectMake(18.0, 138.0, UIScreen.mainScreen().bounds.size.width - (18.0 * 2.0), 31.0))
	var sliderValueLabel: UILabel!
	var scrubbingSpeedLabel: UILabel!
	
	var titleLabel: UILabel {
		var titleLabel = UILabel(frame: CGRectZero)
		titleLabel.backgroundColor = UIColor.clearColor()
		titleLabel.font = UIFont.boldSystemFontOfSize(17.0)
		titleLabel.textAlignment = .Left
		titleLabel.textColor = UIColor.blackColor()
		return titleLabel
	}
	
	var detailLabel: UILabel {
		var detailLabel = UILabel(frame: CGRectZero)
		detailLabel.backgroundColor = UIColor.clearColor()
		detailLabel.font = UIFont.systemFontOfSize(17.0)
		detailLabel.textAlignment = .Center
		detailLabel.textColor = UIColor.blackColor()
		return detailLabel
	}
	
	convenience override init() {
		self.init(nibName: nil, bundle: nil)
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		initialize()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	private func initialize() {
		let paddedWidth = UIScreen.mainScreen().bounds.size.width - (20.0 * 2.0)
		
		var titleLabelOB = titleLabel
		titleLabelOB.frame = CGRectMake(20.0, 109.0, paddedWidth, 21.0)
		titleLabelOB.text = "OBSlider"
		view.addSubview(titleLabelOB)
		
		var titleLabelUI = titleLabel
		titleLabelUI.frame = CGRectMake(20.0, 190.0, paddedWidth, 21.0)
		titleLabelUI.text = "UISlider"
		view.addSubview(titleLabelUI)
		
		sliderValueLabel = detailLabel
		sliderValueLabel.frame = CGRectMake(20.0, 40.0, paddedWidth, 21.0)
		view.addSubview(sliderValueLabel)
		
		scrubbingSpeedLabel = detailLabel
		scrubbingSpeedLabel.frame = CGRectMake(20.0, 69.0, paddedWidth, 21.0)
		view.addSubview(scrubbingSpeedLabel)
		
		slider.addTarget(self, action: "updateUI", forControlEvents: .ValueChanged)
		slider.maximumValue = 1000.0
		slider.value = 500.0
		view.addSubview(slider)
		
		var standardSlider = UISlider(frame: CGRectMake(18.0, 219.0, UIScreen.mainScreen().bounds.size.width - (18.0 * 2.0), 31.0))
		standardSlider.maximumValue = 1000.0
		standardSlider.value = 500.0
		view.addSubview(standardSlider)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		updateUI()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func updateUI() {
		var percentFormatter = NSNumberFormatter()
		percentFormatter.numberStyle = .PercentStyle
		
		sliderValueLabel.text = String(format: "Value: %.0f", slider.value)
		scrubbingSpeedLabel.text = "Scrubbing Speed: \(percentFormatter.stringFromNumber(slider.scrubbingSpeed)!)"
	}
	
}

