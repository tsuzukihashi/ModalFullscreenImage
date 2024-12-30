//
//  ContentView.swift
//  ModalFullscreenImage
//
//  Created by ryo.tsuzukihashi on 2024/12/20.
//

import SwiftUI

struct ContentView: View {
    @State var showDetailView: Bool = false

    var body: some View {
        VStack {
            Button(action: {
                showDetailView.toggle()
            }, label: {
                Text("投稿モーダル")
            })
        }
        .sheet(isPresented: $showDetailView) {
            DetailView()
        }
    }
}


#Preview {
    ContentView()
}
