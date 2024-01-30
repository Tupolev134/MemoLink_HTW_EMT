//
//  AppDelegate.swift
//  MemoLink
//
//  Created by Jonas Glöckner on 26.01.24.
//

import Foundation

import UIKit
import CoreNFC
import os

class NFCDataHandler: ObservableObject {
    let logger = Logger(subsystem: "com.memolink.tag", category: "NFCDataHandler")
    static let shared = NFCDataHandler()
    @Published var lastScannedUUID: String?

    func handleScannedUUID(_ uuid: String) {
        lastScannedUUID = nil
        lastScannedUUID = uuid
        os_log("Scanned UUID updated: \(uuid)")
    }

    func extractUUID(from uri: String) -> String? {
        // Implement logic to extract the UUID from the URI
        // Assuming the URI is in the format "memolink://contact_id/{contactID}"
        let components = uri.components(separatedBy: "/")
        return components.last
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    let logger = Logger(subsystem: "com.memolink.tag", category: "AppDelegate")
    
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        os_log("Background Tag from MemoLink found.")

        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            os_log("Background Tag: Guard 1")
            return false
        }

        // Confirm that the NSUserActivity object contains a valid NDEF message.
        let ndefMessage = userActivity.ndefMessagePayload
        guard ndefMessage.records.count > 0,
              ndefMessage.records[0].typeNameFormat != .empty else {
            os_log("Background Tag: Guard 2")
            return false
        }

        if let uriPayload = ndefMessage.records.first,
           let uri = String(data: uriPayload.payload.advanced(by: 1), encoding: .utf8),
           let uuid = NFCDataHandler.shared.extractUUID(from: uri) {
            NFCDataHandler.shared.handleScannedUUID(uuid)
            os_log("Handled scanned UUID: \(uuid)")
        }
        else{
            os_log("Failed to extract UUID from URI.")
        }

        return true
    }
}
