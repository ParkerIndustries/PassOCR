//
//  PreviewView.swift
//  PassOCR
//
//  Created by Marcus Florentin on 10/11/2019.
//  Copyright © 2019 Marcus Florentin. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {

	var videoPreviewLayer: AVCaptureVideoPreviewLayer {
		guard let layer = layer as? AVCaptureVideoPreviewLayer else {
			fatalError("Expected `AVCaptureVideoPreviewLayer` type for layer. Check PreviewView.layerClass implementation.")
		}

		return layer
	}

	var session: AVCaptureSession? {
		get {
			return videoPreviewLayer.session
		}
		set {
			videoPreviewLayer.session = newValue
		}
	}

	// MARK: UIView

	override class var layerClass: AnyClass {
		return AVCaptureVideoPreviewLayer.self
	}

}
