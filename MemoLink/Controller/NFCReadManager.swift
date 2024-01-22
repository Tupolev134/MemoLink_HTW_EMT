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
               // Process detected NFCNDEFMessage objects.
               self.detectedMessages.append(contentsOf: messages)
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
                        DispatchQueue.main.async {
                            // Process detected NFCNDEFMessage objects.
                            self.detectedMessages.append(message)
                            
                            // Loop through all records in the message
                            for record in message.records {
                                // Check if the payload's TNF (Type Name Format) indicates it's a well-known type
                                if record.typeNameFormat == .nfcWellKnown {
                                    // Attempt to decode the text string from the payload
                                    if let text = String(data: record.payload, encoding: .utf8) {
                                        print("NFC Text: \(text)")
                                    }
                                }
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
}
