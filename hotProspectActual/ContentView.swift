//
//  ContentView.swift
//  hotProspectActual
//
//  Created by Aldiyar Batyrbekov on 6/27/20.
//  Copyright © 2020 Aldiyar Batyrbekov. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var prospects = Prospects()
    var body: some View {
        TabView {
            ProspectsView(filter: .none)
                .tabItem {
                    Image(systemName: "person.3")
                    Text("Everyone")
            }
            ProspectsView(filter: .contacted)
                .tabItem {
                    Image(systemName: "checkmark.circle")
                    Text("Contacted")
            }
            MeView()
                .tabItem {
                    Image(systemName: "person.crop.square")
                    Text("Me")
            }
        }.environmentObject(prospects)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
