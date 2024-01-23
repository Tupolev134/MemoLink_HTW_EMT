//
//  NFCReadManager.swift
//  MemoLink
//
//  Created by Jonas Glöckner on 22.01.24.
//

import CoreNFC

/// - Tag: MessagesTableViewController
class NFCReadManager: NSObject, NFCNDEFReaderSessionDelegate, ObservableObject {

    @Published var detectedMessages = [NFCNDEFMessage]()
    @Published var lastScannedTagId: String?
    var session: NFCNDEFReaderSession?
    var onAlert: ((String, String) -> Void)?

    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            onAlert?("Scanning Not Supported", "This device doesn't support tag scanning.")
            return
        }

        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your iPhone near the item to learn more about it."
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            // Assuming the tag's unique identifier is stored as plain text in the NFC payload
            for payload in messages.first?.records ?? [] {
                if let text = String(data: payload.payload, encoding: .utf8) {
                    self.lastScannedTagId = text
                    break
                }
            }
        }
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            // Restart polling in 500ms
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected, please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        // Connect to the found tag and perform NDEF message reading
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag."
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                if .notSupported == ndefStatus {
                    session.alertMessage = "Tag is not NDEF compliant"
                    session.invalidate()
                    return
                } else if nil != error {
                    session.alertMessage = "Unable to query NDEF status of tag"
                    session.invalidate()
                    return
                }
                
                tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                    var statusMessage: String
                    if let error = error {
                        statusMessage = "Fail to read NDEF from tag: \(error.localizedDescription)"
                    } else if let message = message {
                        statusMessage = "Found \(message.records.count) NDEF message(s)"
                            for payload in message.records {
                                if let text = self.extractText(from: payload) {
                                    self.lastScannedTagId = text
                                    print(self.lastScannedTagId)
                                    }
                                }
                    } else {
                        statusMessage = "No NDEF message found."
                    }
                    
                    session.alertMessage = statusMessage
                    session.invalidate()
                })
            })
        })
    }
    
    /// - Tag: sessionBecomeActive
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        
    }
    
    /// - Tag: endScanning
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        // Check the invalidation reason from the returned error.
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a
            // successful read during a single-tag read session, or because the
            // user canceled a multiple-tag read session from the UI or
            // programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                DispatchQueue.main.async {
                    self.onAlert?("Session Invalidated", error.localizedDescription)
                }
            }
        }
        
        // To read new tags, a new session instance is required.
        self.session = nil
    }
    
    func extractText(from payload: NFCNDEFPayload) -> String? {
        guard payload.typeNameFormat == .nfcWellKnown else {
            print("not Well Known")
            return nil
        }

        let data = payload.payload
        print(data.base64EncodedString())
        // The first byte of the payload is the status byte (which includes the length of the language code)
        let statusByte = data.first ?? 0
        let langCodeLength = Int(statusByte & 0x3F) // lower 6 bits of the status byte
        let textDataRange = (1 + langCodeLength)..<data.count
        
        print(textDataRange)
        
        print(String(data: data[textDataRange], encoding: .utf8))

        return String(data: data[textDataRange], encoding: .utf8)
    }
}
