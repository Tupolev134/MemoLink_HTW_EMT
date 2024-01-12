import SwiftUI

struct StartView: View {
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "shareplay")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 60, height: 60)
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
            
        }
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
