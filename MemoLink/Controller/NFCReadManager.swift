//
//  NFCReadManager.swift
//  MemoLink
//
//  Created by Jonas Glöckner on 22.01.24.
//

import CoreNFC

/// - Tag: MessagesTableViewController
class NFCReadManager: NSObject, NFCNDEFReaderSessionDelegate, ObservableObject {
    var session: NFCNDEFReaderSession?
    var onAlert: ((String, String) -> Void)?
    var onEmptyTagDetected: (() -> Void)?

    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            onAlert?("Scanning Not Supported", "This device doesn't support tag scanning.")
            return
        }

        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "Hold your phone close to a tag."
        session?.begin()
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.main.async {
            for payload in messages.first?.records ?? [] {
                if let uri = self.extractURI(from: payload),
                   let contactID = self.extractContactID(from: uri) {
                    NFCDataHandler.shared.handleScannedUUID(contactID)
                }
            }
        }
    }

    func extractURI(from payload: NFCNDEFPayload) -> String? {
        guard payload.typeNameFormat == .nfcWellKnown,
              let type = String(data: payload.type, encoding: .ascii),
              type == "U" else {
            return nil
        }

        return String(data: payload.payload.advanced(by: 1), encoding: .utf8)
    }

    func extractContactID(from uri: String) -> String? {
        // Extract and return the contact ID part from the URI
        let components = uri.components(separatedBy: "/")
        return components.last
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
                session.alertMessage = "That didnt work. Please try again"
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                if .notSupported == ndefStatus {
                    session.alertMessage = "Please use a different tag"
                    session.invalidate()
                    return
                } else if nil != error {
                    session.alertMessage = "That didnt work. Please try again"
                    session.invalidate()
                    return
                }
                
                tag.readNDEF(completionHandler: { (message: NFCNDEFMessage?, error: Error?) in
                    var statusMessage: String
                    if let error = error {
                        if error.localizedDescription == "NDEF tag does not contain any NDEF message" {
                            // Error due to no NDEF message found
                            statusMessage = "Tag is not assigned to a contact yet"
                            DispatchQueue.main.async {
                                self.onEmptyTagDetected?()
                            }
                        } else {
                            // Other errors
                            statusMessage = "Fail to read from tag: \(error.localizedDescription)"
                        }
                    } else if let message = message {
                        statusMessage = "Found a Person!"
                        DispatchQueue.main.async {
                            for payload in message.records {
                                if let uri = self.extractURI(from: payload),
                                   let contactID = self.extractContactID(from: uri) {
                                    NFCDataHandler.shared.handleScannedUUID(contactID)
                                }
                            }
                        }
                    } else {
                        statusMessage = "Tag is not assigned to a contact yet"
                        DispatchQueue.main.async {
                            self.onEmptyTagDetected?()
                        }
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
        if let readerError = error as? NFCReaderError {
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                DispatchQueue.main.async {
                    self.onAlert?("Session Invalidated", error.localizedDescription)
                }
            }
        }
        
        self.session = nil
    }
    
}
