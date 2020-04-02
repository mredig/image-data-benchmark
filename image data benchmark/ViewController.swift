//
//  ViewController.swift
//  image data benchmark
//
//  Created by Michael Redig on 4/1/20.
//  Copyright © 2020 Red_Egg Productions. All rights reserved.
//

import UIKit

struct RGBColor {
	let red: UInt8
	let green: UInt8
	let blue: UInt8
	let alpha: UInt8
}

class ViewController: UIViewController {

	var imageArray: [RGBColor]?
	var rawImageData: Data?

	var theImage: UIImage!

	let iterations = 9999

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		guard let url = Bundle.main.url(forResource: "Lenna", withExtension: "png") else { return }
		guard let sourcePngData = try? Data(contentsOf: url) else { return }
		guard let lena = UIImage(data: sourcePngData) else { return }
		theImage = lena
	}

	func benchmark1() {
		rawImageData = nil
		guard let image = theImage!.cgImage else { return }

//		let width = Int(image.size.width)
//		let height = Int(image.size.height)
//
//		let bytesPerPixel = image.bitsPerPixel / image.bitsPerComponent

		guard let rawData = image.dataProvider?.data as Data? else { return }

		rawImageData = rawData
//		for row in 0..<height {
//			let offsetStart = image.bytesPerRow * row
//			for xOffset in 0..<width {
//				let pixelOffset = offsetStart + (xOffset + bytesPerPixel)
//				guard pixelOffset < rawData.count else { break }
//
//			}
//		}
	}

	func benchmark2() {
		rawImageData = nil
		guard let image = theImage!.cgImage else { return }
		let size = image.size
		UIGraphicsBeginImageContext(size)

		guard let context = UIGraphicsGetCurrentContext() else { print("No graphics context"); return }
		context.draw(image, in: CGRect(origin: .zero, size: size))

//		let width = Int(size.width)
		let height = Int(size.height)

		guard let data1 = context.data?.assumingMemoryBound(to: UInt8.self) else { print("No data"); return }
		let data2 = UnsafeBufferPointer(start: data1, count: height * context.bytesPerRow)
		let rData = Data(buffer: data2)
		UIGraphicsEndImageContext()
		rawImageData = rData
	}

	func runBenchmark(label: String?, benchmark: () -> Void) {
		let theLabel = label ?? "an unlabelled benchmark"
		let startTime = CFAbsoluteTimeGetCurrent()
		NSLog("Starting \(iterations) iterations of \(theLabel)")
		for _ in 0..<iterations {
			autoreleasepool {
				benchmark()
			}
		}
		let endTime = CFAbsoluteTimeGetCurrent()
		let total = endTime - startTime
		NSLog("Finished \(theLabel) in \(total) seconds")
	}

	@IBAction func benchmarkOnePressed(_ sender: UIButton) {
		runBenchmark(label: "Direct data", benchmark: benchmark1)
	}

	@IBAction func benchmarkTwoPressed(_ sender: UIButton) {
		runBenchmark(label: "Context data", benchmark: benchmark2)
	}
}

internal extension CGImage {
	var size: CGSize {
		CGSize(width: width, height: height)
	}

	var bounds: CGRect {
		CGRect(origin: .zero, size: size)
	}
}
