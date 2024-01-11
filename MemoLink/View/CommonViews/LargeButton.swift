import SwiftUI

struct LargeButton: View {
    var text: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.system(size: 32))
                .bold()
                .frame(maxWidth: .infinity)
                .frame(height: 150)
                .foregroundColor(Color("BG"))
                .background(Color.black)
                .cornerRadius(10)
        }
        .padding()
    }
}

struct LargeButton_Previews: PreviewProvider {
    static var previews: some View {
        LargeButton(text: "Large Button", action: {
            // Action
        })
    }
}
