//
//  ContentView.swift
//  SwiftUIAR
//
//  Created by Doris Trakarskys on 2023/2/11.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ARViewContainer()
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
