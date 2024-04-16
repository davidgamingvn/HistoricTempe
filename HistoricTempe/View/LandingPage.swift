//
//  ContentView.swift
//  ClassProject
//
//  Created by Dinh Phuc Nguyen on 3/17/24.
//

import SwiftUI

struct LandingPage: View {
    var body: some View {
        NavigationView {
            VStack{
                Text("Welcome to Tempe historical sites")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                
                Text("Please log in or continue as guest")
                    .font(.headline)
                    .fontWeight(.regular)
                    .padding()
                
                NavigationLink(destination : HomeView()) {
                    Text("Guest")
                        .padding()
                        .backgroundStyle(.blue)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination : AuthView()) {
                    Text("Member")
                        .padding()
                        .backgroundStyle(.blue)
                        .cornerRadius(10)
                }
                
            }
            
        }
        .padding()
    }
}

#Preview {
    LandingPage()
}
