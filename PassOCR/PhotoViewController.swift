//
//  PhotoViewController.swift
//  PassOCR
//
//  Created by Marcus Florentin on 08/11/2019.
//  Copyright © 2019 Marcus Florentin. All rights reserved.
//

import UIKit
import Vision
import AVFoundation
import Foundation


class PhotoViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate,
							UIDocumentInteractionControllerDelegate {

	var request: VNRecognizeTextRequest!


	// MARK: - AV Foundation

	private let captureSession = AVCaptureSession()
	let captureSessionQueue = DispatchQueue(label: "com.example.apple-samplecode.CaptureSessionQueue")

	var captureDevice: AVCaptureDevice?

	var videoDataOutput = AVCaptureVideoDataOutput()
	let videoDataOutputQueue = DispatchQueue(label: "com.example.apple-samplecode.VideoDataOutputQueue")

	var bufferAspectRatio: Double!

	var cameraPosition : AVCaptureDevice.Position = .front

	func setupCaptureSession() -> Void {

		previewView.session = captureSession

		// Configure the the front camera
		guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
														  for: .video,
														  position: cameraPosition) else { fatalError("Can't create capture device") }


		self.captureDevice = captureDevice


		// Configure the back camera
		if captureDevice.supportsSessionPreset(.iFrame1280x720) {
			captureSession.sessionPreset = .iFrame1280x720
			bufferAspectRatio = 1280 / 2160
		} else {
			captureSession.sessionPreset = .vga640x480
			bufferAspectRatio = 640 / 480
		}


		guard let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
			print("Could not create device input.")
			return
		}

		// Clear the session

		// Removing the last camera use
		captureSession.inputs.forEach({ captureSession.removeInput($0) })

		if captureSession.canAddInput(deviceInput) {
			captureSession.addInput(deviceInput)
		}

		videoDataOutput.alwaysDiscardsLateVideoFrames = true
		videoDataOutput.setSampleBufferDelegate(self, queue: videoDataOutputQueue)
		videoDataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]

		// Remove camera output
		captureSession.outputs.forEach({ captureSession.removeOutput($0) })

		if captureSession.canAddOutput(videoDataOutput) {
			captureSession.addOutput(videoDataOutput)
			// NOTE:
			// There is a trade-off to be made here. Enabling stabilization will
			// give temporally more stable results and should help the recognizer
			// converge. But if it's enabled the VideoDataOutput buffers don't
			// match what's displayed on screen, which makes drawing bounding
			// boxes very hard. Disable it in this app to allow drawing detected
			// bounding boxes on screen.
			videoDataOutput.connection(with: AVMediaType.video)?.preferredVideoStabilizationMode = .off
		} else {
			print("Could not add VDO output")
			return
		}

		// Set zoom and autofocus to help focus on very small text.
		do {
			try captureDevice.lockForConfiguration()
			captureDevice.videoZoomFactor = 1
			captureDevice.unlockForConfiguration()
		} catch {
			print("Could not set zoom level due to error: \(error)")
			return
		}

		captureSession.startRunning()
	}

	func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
			// Configure for running in real-time.
			request.recognitionLevel = .fast
			// Language correction won't help recognizing phone numbers. It also
			// makes recognition slower.
			request.usesLanguageCorrection = true
			request.recognitionLanguages = ["fr"]
			// Only run on the region of interest for maximum speed.
//			request.regionOfInterest = regionOfInterest

			let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .right, options: [:])
			do {
				try requestHandler.perform([request])
			} catch {
				print(error)
			}
		}
	}


	// MARK: - Vision

	private let tracker = StringTracker()

	// Vision recognition handler.
	func recognizeTextHandler(request: VNRequest, error: Error?) {
		// TODO: Get result from Vision

		guard let results = request.results as? [VNRecognizedTextObservation] else { return }

		let maximumCandidates = 1

		for visionResult in results {
			guard let candidate = visionResult.topCandidates(maximumCandidates).first else { continue }

			// Draw red boxes around any detected text, and green boxes around
			// any detected phone numbers. The phone number may be a substring
			// of the visionResult. If a substring, draw a green box around the
			// number and a red box around the full string. If the number covers
			// the full result only draw the green box.

			tracker.logFrame(strings: [candidate.string])
		}

		if tracker.bestString.count >= 3 {
            let bests = tracker.bestString.prefix(3)

            let bestTwo = bests.drop { string -> Bool in
                return string.rangeOfCharacter(from: .decimalDigits) != nil
            }
            
			if createUser(name: bestTwo.last!.capitalized(with: .autoupdatingCurrent),
						  surname: bestTwo.first!.uppercased(with: .autoupdatingCurrent)) {
				print("Find \(bestTwo.first!), \(bestTwo.last!)")
			}
		}
	}


    // MARK: - Storyboard

	@IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var actionLabel: UILabel!
	@IBOutlet weak var usersItem: UIBarButtonItem!
	@IBOutlet weak var shareItem: UIBarButtonItem!
    
    // MARK: Card
    
    @IBOutlet weak var cardView: CardView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var surnameLabel: UILabel!
    

	@IBAction func changeCamera(_ sender: Any) {

		cameraPosition = cameraPosition == .front ? .back : .front
		setupCaptureSession()
		// TODO: Animate
	}

    // MARK: - Photo View Controller
    /// Tous les utilisateurs scannés
	var users: [User] = [] {
		didSet {

			DispatchQueue.main.async {
				self.usersItem.isEnabled = !self.users.isEmpty
				self.shareItem.isEnabled = !self.users.isEmpty

				guard !self.users.isEmpty else {
					self.usersItem.title = "0 Personne"
					return
				}

				self.usersItem.title = "\(self.users.count) Personne\(self.users.count > 1 ? "s" : "")"
			}
		}

	}
    
    /// Utilisateur actuellement en train de reconnaître
    var currentUser: User? = nil
    // MARK: Recognition
    
    private var presentCard: Bool = false
    private var cardValid: Bool = false
    
    func createUser(name: String, surname: String) -> Bool {
        let new = User(name: name, surname: surname)

		guard !users.contains(new) else { return false }

		users.append(new)
        presentCard = true
		
        DispatchQueue.main.async {
            
            self.nameLabel.text = new.name
            self.nameLabel.isHidden = false
            self.surnameLabel.text = new.surname
            self.surnameLabel.isHidden = false
            self.cardView.isHidden = false
        }
        

        // TODO: Create timer

		return true
    }
    
	@IBAction func save(_ sender: UIBarButtonItem) {

		guard !users.isEmpty else { return }
		// Continue if we had scan users

		let peoples = users

		// Create CSV
		let csv = CSV(peoples)

		// Presente CSV

		// Saving file on disk temporaly
		var link = FileManager.default.temporaryDirectory
		link.appendPathComponent("Peoples")
		link.appendPathExtension("csv")

		do {
			try csv.write(to: link)

			let documentInteraction = UIDocumentInteractionController(url: link)
			documentInteraction.name = "Peoples"
			documentInteraction.uti = "csv"
			documentInteraction.annotation = "\(users.count) passed."
			documentInteraction.delegate = self

			documentInteraction.presentOptionsMenu(from: sender, animated: true)

		} catch {
			// TODO: display error
			print(error)
		}

	}
	// MARK: - View Controller

	var maskLayer = CAShapeLayer()

    override func viewDidLoad() {
		request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)

		super.viewDidLoad()

		setupCaptureSession()

        // Do any additional setup after loading the view.


    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

	// MARK: - UI Document Interaction Controller Delegate

	func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {

		return self
	}

}
