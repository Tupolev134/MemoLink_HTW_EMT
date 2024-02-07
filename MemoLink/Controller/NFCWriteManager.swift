import CoreNFC


class NFCWriteManager:NSObject, NFCNDEFReaderSessionDelegate, ObservableObject {

    // MARK: - Properties

    var session: NFCNDEFReaderSession?
    var onNFCResult: ((Result<String, Error>) -> Void)?
    var message: NFCNDEFMessage = NFCNDEFMessage(records: [])
    var completion: ((Bool, Error?) -> Void)?

    func beginWrite(completion: @escaping (Bool, Error?) -> Void) {
        self.completion = completion
    
        guard NFCNDEFReaderSession.readingAvailable else {
            // Handle the error: NFC not supported
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        
        session?.alertMessage = "Hold your phone close to a tag."
        session?.begin()
    }
    
    // MARK: - NFCNDEFReaderSessionDelegate
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
    }
    
    /// - Tag: writeToTag
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval, execute: {
                session.restartPolling()
            })
            return
        }
        
        // Connect to the found tag and write an NDEF message to it.
        let tag = tags.first!
        session.connect(to: tag, completionHandler: { (error: Error?) in
            if nil != error {
                session.alertMessage = "Unable to connect to tag"
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus(completionHandler: { (ndefStatus: NFCNDEFStatus, capacity: Int, error: Error?) in
                guard error == nil else {
                    session.alertMessage = "Unable to connect to tag"
                    session.invalidate()
                    return
                }

                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = "Please use a different tag"
                    session.invalidate()
                case .readOnly:
                    session.alertMessage = "Please use a different tag"
                    session.invalidate()
                case .readWrite:
                    tag.writeNDEF(self.message, completionHandler: { (error: Error?) in
                        if nil != error {
                            session.alertMessage = "That did not work. Please try again"
                        } else {
                            session.alertMessage = "Added contact to the tag"
                            self.completion?(true, nil)
                        }
                        session.invalidate()
                    })
                @unknown default:
                    session.alertMessage = "That did not work. Please try again"
                    session.invalidate()
                }
            })
        })
    }
    
    /// - Tag: sessionBecomeActive
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        
    }
    
    /// - Tag: endScanning
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError,
                   readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead,
                   readerError.code != .readerSessionInvalidationErrorUserCanceled {
                    print("session invalidated")
                }
    }
}

