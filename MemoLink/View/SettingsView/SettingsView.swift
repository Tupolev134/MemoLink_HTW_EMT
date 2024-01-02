//
//  SettingsView.swift
//  MemoLink
//
//  Created by Carlo aus der Wiesche on 02.01.24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        VStack{
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BG").edgesIgnoringSafeArea(.all))
        .navigationBarTitle("Settings", displayMode: .large)
        .foregroundStyle(Color("MemoLinkBlue"))
    }
    

}

#Preview {
    SettingsView()
}
