//
//  SwiftUIView.swift
//  CarPlatesScanner
//
//  Created by Shoxrux Khodjaev on 27/10/2025.
//

import SwiftUI

public extension String {
    func isValidNumberPlates() -> Bool {
//        #"^[0-9][0-9O](?:[A-Z][0-9]{3}[A-Z]{2}|[0-9]{3}[A-Z]{3}| ?[A-Z] ?[0-9]{5,6})$"#
        let patt = #"^(?:[0-9][0-9O](?:[A-Z][0-9]{3}[A-Z]{2}|[0-9]{3}[A-Z]{3}| ?[A-Z] ?[0-9]{5,6})|[A-Z]{2}[0-9]{4}|[A-Z]{3}[0-9]{3})$"#
        do {
            let regex = try NSRegularExpression(pattern: patt)
            let range = NSRange(location: 0, length: self.utf16.count)
            return regex.firstMatch(in: self, options: [], range: range) != nil
        } catch {
            print("Regex error: ", error)
            return false
        }
    }
}
