import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "shareplay")
                    .resizable() // Ermöglicht die Anpassung der Größe des Symbols
                    .aspectRatio(contentMode: .fit) // Erhält das Seitenverhältnis des Symbols
                    .frame(width: 60, height: 60) // Hier können Sie die gewünschte Größe angeben
                    .foregroundColor(.accentColor)
                Text("Hold your phone near a image of a person")
                    .multilineTextAlignment(.center)
                    .font(.largeTitle)
                    .frame(alignment: .center)
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .padding()
            }
            
            
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing){
                    NavigationLink{
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                    
                }
            }
            .navigationTitle("MemoLink")
            .toolbarBackground(Color.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
