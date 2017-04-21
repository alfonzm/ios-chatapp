//
//  BorderedTopView.swift
//  LIGChatApp
//
//  Created by Alfonz Montelibano on 4/22/17.
//  Copyright © 2017 alphonsus. All rights reserved.
//

import Foundation
import UIKit

class BorderedTopView: UIView {
	override func draw(_ rect: CGRect) {
		// add top border
		let context = UIGraphicsGetCurrentContext()
		context?.move(to: CGPoint(x: rect.minX, y: rect.minY))
		context?.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
		context?.setStrokeColor(UIColor(hexString: "#ccd6dd").cgColor)
		context?.setLineWidth(1)
		context?.strokePath()
	}
}
