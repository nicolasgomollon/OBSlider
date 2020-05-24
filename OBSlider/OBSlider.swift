//
//  OBSlider.swift
//  OBSlider
//
//  Objective-C code Copyright (c) 2011 Ole Begemann. All rights reserved.
//  Swift adaptation Copyright (c) 2014 Nicolas Gomollon. All rights reserved.
//

import Foundation
import UIKit

/** Protocol to listen for slider changes. */
@objc
public protocol OBSliderDelegate: NSObjectProtocol {
	
	@objc optional func sliderDidBeginScrubbing(_ slider: OBSlider)
	
	@objc optional func sliderDidEndScrubbing(_ slider: OBSlider)
	
	@objc optional func slider(_ slider: OBSlider, didChangeScrubbingSpeed speed: Float)
	
}

open class OBSlider: UISlider, UIGestureRecognizerDelegate {
	
	open var scrubbingSpeed: Float = 1.0
	open var scrubbingSpeeds: [Float] = [1.0, 0.5, 0.25, 0.1]
	open var scrubbingSpeedChangePositions: [Float] = [0.0, 50.0, 100.0, 150.0]
	
	open weak var delegate: OBSliderDelegate!
	
	fileprivate var realPositionValue: Float = 0.0
	fileprivate var beganTrackingLocation: CGPoint = .zero
	fileprivate var panGestureRecognizer: UIPanGestureRecognizer!
	
	public convenience init() {
		self.init(frame: .zero)
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		if aDecoder.containsValue(forKey: "scrubbingSpeeds") {
			scrubbingSpeeds = aDecoder.decodeObject(forKey: "scrubbingSpeeds") as! [Float]
		}
		if aDecoder.containsValue(forKey: "scrubbingSpeedChangePositions") {
			scrubbingSpeedChangePositions = aDecoder.decodeObject(forKey: "scrubbingSpeedChangePositions") as! [Float]
		}
		if !scrubbingSpeeds.isEmpty {
			scrubbingSpeed = scrubbingSpeeds[0]
		}
		commonInit()
	}
	
	open override func encode(with aCoder: NSCoder) {
		super.encode(with: aCoder)
		aCoder.encode(scrubbingSpeeds, forKey: "scrubbingSpeeds")
		aCoder.encode(scrubbingSpeedChangePositions, forKey: "scrubbingSpeedChangePositions")
	}
	
	fileprivate func commonInit() {
		panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(OBSlider.handlePan(_:)))
		panGestureRecognizer.delegate = self
		panGestureRecognizer.minimumNumberOfTouches = 1
		panGestureRecognizer.maximumNumberOfTouches = 1
		if #available(iOS 13.4, *) {
			panGestureRecognizer.allowedTouchTypes = [NSNumber(integerLiteral: UITouch.TouchType.indirectPointer.rawValue)]
			panGestureRecognizer.allowedScrollTypesMask = [.continuous]
		}
		addGestureRecognizer(panGestureRecognizer)
	}
	
	open override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		let beginTracking: Bool = super.beginTracking(touch, with: event)
		if beginTracking {
			// Set the beginning tracking location to the center of the current
			// position of the thumb. This ensures that the thumb is correctly re-positioned
			// when the touch position moves back to the track after tracking in one
			// of the slower tracking zones.
			let thumbRect: CGRect = self.thumbRect(forBounds: bounds, trackRect: trackRect(forBounds: bounds), value: value)
			beganTrackingLocation = CGPoint(x: thumbRect.origin.x + thumbRect.size.width / 2.0, y: thumbRect.origin.y + thumbRect.size.height / 2.0)
			realPositionValue = value
			
			delegate?.sliderDidBeginScrubbing?(self)
			delegate?.slider?(self, didChangeScrubbingSpeed: scrubbingSpeed)
		}
		return beginTracking
	}
	
	open override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
		if isTracking {
			let previousLocation: CGPoint = touch.previousLocation(in: self)
			let currentLocation: CGPoint = touch.location(in: self)
			let trackingOffset: CGFloat = currentLocation.x - previousLocation.x
			
			// Find the scrubbing speed that corresponds to the touch's vertical offset.
			let verticalOffset: CGFloat = abs(currentLocation.y - beganTrackingLocation.y)
			var scrubbingSpeedChangePosIndex: Int = indexOfLower(scrubbingSpeed: scrubbingSpeedChangePositions, forOffset: Float(verticalOffset))
			if scrubbingSpeedChangePosIndex == NSNotFound {
				scrubbingSpeedChangePosIndex = scrubbingSpeeds.count
			}
			
			let newScrubbingSpeed: Float = scrubbingSpeeds[scrubbingSpeedChangePosIndex - 1]
			if (newScrubbingSpeed != scrubbingSpeed) {
				delegate?.slider?(self, didChangeScrubbingSpeed: newScrubbingSpeed)
			}
			scrubbingSpeed = newScrubbingSpeed
			
			let trackRect: CGRect = self.trackRect(forBounds: bounds)
			realPositionValue = realPositionValue + Float(maximumValue - minimumValue) * Float(trackingOffset / trackRect.size.width)
			
			let valueAdjustment: Float = scrubbingSpeed * Float(maximumValue - minimumValue) * Float(trackingOffset / trackRect.size.width)
			var thumbAdjustment: Float = 0.0
			if (((beganTrackingLocation.y < currentLocation.y) && (currentLocation.y < previousLocation.y)) ||
				((beganTrackingLocation.y > currentLocation.y) && (currentLocation.y > previousLocation.y))) {
					// We are getting closer to the slider, go closer to the real location.
					thumbAdjustment = (realPositionValue - value) / Float(1.0 + abs(currentLocation.y - beganTrackingLocation.y))
			}
			value += valueAdjustment + thumbAdjustment
			
			if isContinuous {
				sendActions(for: .valueChanged)
			}
		}
		return isTracking
	}
	
	open override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
		if isTracking {
			scrubbingSpeed = scrubbingSpeeds[0]
			sendActions(for: .valueChanged)
			delegate?.sliderDidEndScrubbing?(self)
		}
	}
	
	fileprivate func indexOfLower(scrubbingSpeed scrubbingSpeedPositions: [Float], forOffset verticalOffset: Float) -> Int {
		for (i, scrubbingSpeedOffset) in scrubbingSpeedPositions.enumerated() {
			if verticalOffset < scrubbingSpeedOffset {
				return i
			}
		}
		return NSNotFound
	}
	
	open override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
		guard let panRecognizer: UIPanGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else { return true }
		guard panRecognizer == panGestureRecognizer else { return false }
		let velocity: CGPoint = panRecognizer.velocity(in: self)
		let horizontalPanning: Bool = abs(velocity.x) > abs(velocity.y)
		return horizontalPanning
	}
	
	@objc fileprivate func handlePan(_ panGesture: UIPanGestureRecognizer) {
		switch panGesture.state {
		case .began:
			delegate?.sliderDidBeginScrubbing?(self)
			delegate?.slider?(self, didChangeScrubbingSpeed: scrubbingSpeed)
		case .changed:
			let translation: CGPoint = panGesture.translation(in: self)
			
			var scrubbingSpeedChangePosIndex: Int = indexOfLower(scrubbingSpeed: scrubbingSpeedChangePositions, forOffset: Float(abs(translation.y)))
			if scrubbingSpeedChangePosIndex == NSNotFound {
				scrubbingSpeedChangePosIndex = scrubbingSpeeds.count
			}
			
			let newScrubbingSpeed: Float = scrubbingSpeeds[scrubbingSpeedChangePosIndex - 1]
			if (newScrubbingSpeed != scrubbingSpeed) {
				delegate?.slider?(self, didChangeScrubbingSpeed: newScrubbingSpeed)
			}
			scrubbingSpeed = newScrubbingSpeed
			
			let trackRect: CGRect = self.trackRect(forBounds: bounds)
			let valueAdjustment: Float = scrubbingSpeed * Float(maximumValue - minimumValue) * Float(translation.x / trackRect.size.width)
			value += valueAdjustment
			
			if isContinuous {
				sendActions(for: .valueChanged)
			}
			
			panGesture.setTranslation(CGPoint(x: 0.0, y: translation.y), in: self)
		case .ended,
			 .cancelled,
			 .failed:
			scrubbingSpeed = scrubbingSpeeds[0]
			sendActions(for: .valueChanged)
			delegate?.sliderDidEndScrubbing?(self)
		default:
			break
		}
	}
	
}
