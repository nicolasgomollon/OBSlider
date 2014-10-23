//
//  OBSlider.swift
//  OBSlider
//
//  Objective-C code Copyright (c) 2011 Ole Begemann. All rights reserved.
//  Swift adaptation Copyright (c) 2014 Nicolas Gomollon. All rights reserved.
//

import Foundation
import UIKit

class OBSlider: UISlider {
	
	var scrubbingSpeed: Float = 1.0
	var scrubbingSpeeds: Array<Float> = [1.0, 0.5, 0.25, 0.1]
	var scrubbingSpeedChangePositions: Array<Float> = [0.0, 50.0, 100.0, 150.0]
	
	private var realPositionValue: Float = 0.0
	private var beganTrackingLocation = CGPointZero
	
	convenience override init() {
		self.init(frame: CGRectZero)
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		if aDecoder.containsValueForKey("scrubbingSpeeds") {
			scrubbingSpeeds = aDecoder.decodeObjectForKey("scrubbingSpeeds") as Array<Float>
		}
		if aDecoder.containsValueForKey("scrubbingSpeedChangePositions") {
			scrubbingSpeedChangePositions = aDecoder.decodeObjectForKey("scrubbingSpeedChangePositions") as Array<Float>
		}
		if scrubbingSpeeds.count > 0 {
			scrubbingSpeed = scrubbingSpeeds[0]
		}
	}
	
	override func encodeWithCoder(aCoder: NSCoder) {
		super.encodeWithCoder(aCoder)
		aCoder.encodeObject(scrubbingSpeeds, forKey: "scrubbingSpeeds")
		aCoder.encodeObject(scrubbingSpeedChangePositions, forKey: "scrubbingSpeedChangePositions")
	}
	
	override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
		let beginTracking = super.beginTrackingWithTouch(touch, withEvent: event)
		if beginTracking {
			// Set the beginning tracking location to the center of the current
			// position of the thumb. This ensures that the thumb is correctly re-positioned
			// when the touch position moves back to the track after tracking in one
			// of the slower tracking zones.
			let thumbRect = thumbRectForBounds(bounds, trackRect: trackRectForBounds(bounds), value: value)
			beganTrackingLocation = CGPointMake(thumbRect.origin.x + thumbRect.size.width / 2.0, thumbRect.origin.y + thumbRect.size.height / 2.0)
			realPositionValue = value
		}
		return beginTracking
	}
	
	override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) -> Bool {
		if tracking {
			let previousLocation = touch.previousLocationInView(self)
			let currentLocation = touch.locationInView(self)
			let trackingOffset = currentLocation.x - previousLocation.x
			
			// Find the scrubbing speed that corresponds to the touch's vertical offset.
			let verticalOffset = abs(currentLocation.y - beganTrackingLocation.y)
			var scrubbingSpeedChangePosIndex = indexOfLower(scrubbingSpeed: scrubbingSpeedChangePositions, forOffset: Float(verticalOffset))
			if scrubbingSpeedChangePosIndex == NSNotFound {
				scrubbingSpeedChangePosIndex = scrubbingSpeeds.count
			}
			scrubbingSpeed = scrubbingSpeeds[scrubbingSpeedChangePosIndex - 1]
			
			let trackRect = trackRectForBounds(bounds)
			realPositionValue = realPositionValue + Float(maximumValue - minimumValue) * Float(trackingOffset / trackRect.size.width)
			
			let valueAdjustment = scrubbingSpeed * Float(maximumValue - minimumValue) * Float(trackingOffset / trackRect.size.width)
			var thumbAdjustment: Float = 0.0
			if (((beganTrackingLocation.y < currentLocation.y) && (currentLocation.y < previousLocation.y)) ||
				((beganTrackingLocation.y > currentLocation.y) && (currentLocation.y > previousLocation.y))) {
					// We are getting closer to the slider, go closer to the real location.
					thumbAdjustment = (realPositionValue - value) / Float(1.0 + abs(currentLocation.y - beganTrackingLocation.y))
			}
			value += valueAdjustment + thumbAdjustment
			
			if continuous {
				sendActionsForControlEvents(.ValueChanged)
			}
		}
		return tracking
	}
	
	override func endTrackingWithTouch(touch: UITouch, withEvent event: UIEvent) {
		if tracking {
			scrubbingSpeed = scrubbingSpeeds[0]
			sendActionsForControlEvents(.ValueChanged)
		}
	}
	
	func indexOfLower(scrubbingSpeed scrubbingSpeedPositions: Array<Float>, forOffset verticalOffset: Float) -> Int {
		for (i, scrubbingSpeedOffset) in enumerate(scrubbingSpeedPositions) {
			if verticalOffset < scrubbingSpeedOffset {
				return i
			}
		}
		return NSNotFound
	}
	
}
