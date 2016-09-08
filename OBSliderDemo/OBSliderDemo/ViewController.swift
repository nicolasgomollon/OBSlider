//
//  ViewController.swift
//  OBSliderDemo
//
//  Objective-C code Copyright (c) 2011 Ole Begemann. All rights reserved.
//  Swift adaptation Copyright (c) 2014 Nicolas Gomollon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
	
	var slider = OBSlider(frame: CGRect(x: 18.0, y: 138.0, width: UIScreen.main.bounds.size.width - (18.0 * 2.0), height: 31.0))
	var sliderValueLabel: UILabel!
	var scrubbingSpeedLabel: UILabel!
	
	var titleLabel: UILabel {
		let titleLabel = UILabel(frame: CGRect.zero)
		titleLabel.backgroundColor = .clear
		titleLabel.font = .boldSystemFont(ofSize: 17.0)
		titleLabel.textAlignment = .left
		titleLabel.textColor = .black
		return titleLabel
	}
	
	var detailLabel: UILabel {
		let detailLabel = UILabel(frame: CGRect.zero)
		detailLabel.backgroundColor = .clear
		detailLabel.font = .systemFont(ofSize: 17.0)
		detailLabel.textAlignment = .center
		detailLabel.textColor = .black
		return detailLabel
	}
	
	convenience init() {
		self.init(nibName: nil, bundle: nil)
	}
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		initialize()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		initialize()
	}
	
	private func initialize() {
		let paddedWidth = UIScreen.main.bounds.size.width - (20.0 * 2.0)
		
		let titleLabelOB = titleLabel
		titleLabelOB.frame = CGRect(x: 20.0, y: 109.0, width: paddedWidth, height: 21.0)
		titleLabelOB.text = "OBSlider"
		view.addSubview(titleLabelOB)
		
		let titleLabelUI = titleLabel
		titleLabelUI.frame = CGRect(x: 20.0, y: 190.0, width: paddedWidth, height: 21.0)
		titleLabelUI.text = "UISlider"
		view.addSubview(titleLabelUI)
		
		sliderValueLabel = detailLabel
		sliderValueLabel.frame = CGRect(x: 20.0, y: 40.0, width: paddedWidth, height: 21.0)
		view.addSubview(sliderValueLabel)
		
		scrubbingSpeedLabel = detailLabel
		scrubbingSpeedLabel.frame = CGRect(x: 20.0, y: 69.0, width: paddedWidth, height: 21.0)
		view.addSubview(scrubbingSpeedLabel)
		
		slider.addTarget(self, action: #selector(ViewController.updateUI), for: .valueChanged)
		slider.maximumValue = 1000.0
		slider.value = 500.0
		view.addSubview(slider)
		
		let standardSlider = UISlider(frame: CGRect(x: 18.0, y: 219.0, width: UIScreen.main.bounds.size.width - (18.0 * 2.0), height: 31.0))
		standardSlider.maximumValue = 1000.0
		standardSlider.value = 500.0
		view.addSubview(standardSlider)
	}
	
	override func viewWillAppear(_ animated: Bool) {
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
		let percentFormatter = NumberFormatter()
		percentFormatter.numberStyle = .percent
		
		sliderValueLabel.text = String(format: "Value: %.0f", slider.value)
		scrubbingSpeedLabel.text = "Scrubbing Speed: \(percentFormatter.string(from: NSNumber(value: slider.scrubbingSpeed))!)"
	}
	
}

