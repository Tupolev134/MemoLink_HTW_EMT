import SwiftUI

struct StartView: View {
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")
            }
            .padding()
            .navigationBarItems(trailing: Button(action: {
                           self.showingSettings = true
                       }) {
                           Image(systemName: "gear")
                       })
                       .sheet(isPresented: $showingSettings) {
                           SettingsView()
                       }
                   }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
