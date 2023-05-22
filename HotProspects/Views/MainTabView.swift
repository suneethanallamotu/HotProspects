//
//  MainTabView.swift
//  HotProspects
//
//  Created by Suneetha Nallamotu on 5/17/23.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var prospects = Prospects()
    var body: some View {
        
        TabView {
            ProspectsView(filter: .none)
                .tabItem {
                    Label("All", systemImage: "person.3")
                }
            ProspectsView(filter: .contacted)
                .tabItem {
                    Label("Contacted", systemImage: "checkmark.circle")
                }
            ProspectsView(filter: .uncontacted)
                .tabItem {
                    Label("Uncontacted", systemImage: "questionmark.diamond")
                }
            MeView()
                .tabItem {
                    Label("Me", systemImage: "person.crop.square")
                }
        }
        .environmentObject(prospects)
    
    }
}

struct TabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
