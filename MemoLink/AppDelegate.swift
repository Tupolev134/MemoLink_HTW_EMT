//
//  AppDelegate.swift
//  MemoLink
//
//  Created by Jonas Glöckner on 26.01.24.
//

import Foundation

import UIKit
import CoreNFC

class NFCDataHandler: ObservableObject {
    static let shared = NFCDataHandler()
    @Published var lastScannedUUID: String?

    func handleScannedUUID(_ uuid: String) {
        lastScannedUUID = nil
        lastScannedUUID = uuid
    }

    func extractUUID(from uri: String) -> String? {
        // Implement logic to extract the UUID from the URI
        // Assuming the URI is in the format "memolink://contact_id/{contactID}"
        print(uri)
        let components = uri.components(separatedBy: "/")
        return components.last
    }
}


class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb else {
            return false
        }

        let ndefMessage = userActivity.ndefMessagePayload
        guard ndefMessage.records.count > 0,
              ndefMessage.records[0].typeNameFormat != .empty else {
            return false
        }

        if let uriPayload = ndefMessage.records.first,
           let uri = String(data: uriPayload.payload.advanced(by: 1), encoding: .utf8),
           let uuid = NFCDataHandler.shared.extractUUID(from: uri) {
            NFCDataHandler.shared.handleScannedUUID(uuid)
        }

        return true
    }
}
