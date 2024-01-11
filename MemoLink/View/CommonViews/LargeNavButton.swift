import SwiftUI

struct LargeNavButton: View {
    var text: String

    var body: some View {
        Text(text)
            .font(.system(size: 32))
            .bold()
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .foregroundColor(Color("BG"))
            .background(Color.black)
            .cornerRadius(10)
            .padding()
    }
}

struct LargeNavButton_Previews: PreviewProvider {
    static var previews: some View {
        LargeNavButton(text: "Large Button")
    }
}
