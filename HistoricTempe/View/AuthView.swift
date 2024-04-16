//
//  AuthView.swift
//  ClassProject
//
//  Created by Dinh Phuc Nguyen on 3/17/24.
//

import SwiftUI

struct AuthView: View {
    
    @State private var username : String = ""
    @State private var password : String = ""
    
    var body: some View {
        VStack{
            TextField("Username", text: $username)
                .padding()
                .textFieldStyle(.roundedBorder)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
                .padding()
            
            Button(action: {
                
            }){
                Text("Log in")
                    .padding()
                    .backgroundStyle(.blue)
            }
        }
    }
}

#Preview {
    AuthView()
}
