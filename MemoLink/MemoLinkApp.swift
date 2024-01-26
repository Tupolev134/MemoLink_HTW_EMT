import SwiftUI

@main
struct MemoLinkApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            StartView()
        }
    }
}
