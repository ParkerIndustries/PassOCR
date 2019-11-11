//
//  StringTools.swift
//  PassOCR
//
//  Created by Marcus Florentin on 11/11/2019.
//  Copyright © 2019 Marcus Florentin. All rights reserved.
//

import Foundation

func CSV(_ users: [User]) -> Data {
	var file = String()

	// CSV header line
	file += "Name, SURNAME\n"

	for user in users {
		// Add user row
		file += "\(user.name), \(user.surname)\n"
	}

	return file.data(using: .utf8)!
}


class StringTracker {
	var frameIndex: Int64 = 0

	typealias StringObservation = (lastSeen: Int64, count: Int64)

	// Dictionary of seen strings. Used to get stable recognition before
	// displaying anything.
	var seenStrings = [String: StringObservation]()
	var bestString : [String] = []

	func logFrame(strings: [String]) {

		for value in strings {
			let string = value.lowercased(with: .autoupdatingCurrent)

			if seenStrings[string] == nil {
				seenStrings[string] = (lastSeen: Int64(0), count: Int64(-1))
			}
			seenStrings[string]?.lastSeen = frameIndex
			seenStrings[string]?.count += 1
			print("Seen \(string) \(seenStrings[string]?.count ?? 0) times")
		}

		var obsoleteStrings = [String]()

		// Go through strings and prune any that have not been seen in while.
		// Also find the (non-pruned) string with the greatest count.
		for (string, obs) in seenStrings {
			// Remove previously seen text after 30 frames (~1s).
			if obs.lastSeen < frameIndex - 30 {
				obsoleteStrings.append(string)
				bestString.removeAll(where: { $0 == string })

			} else if obs.count > 30, !bestString.contains(string) {
				// If the string as been seen more than 10 times
				bestString.append(string)
			}
		}

		// Remove old strings.
		for string in obsoleteStrings {
			seenStrings.removeValue(forKey: string)
		}

		frameIndex += 1
	}

	func reset(string: String) {
		seenStrings.removeValue(forKey: string)
		bestString = []
	}
}
