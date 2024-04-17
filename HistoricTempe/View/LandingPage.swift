//
//  ContentView.swift
//  ClassProject
//
//  Created by Dinh Phuc Nguyen on 3/17/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LandingPage: View {
    @State var isLoggedIn = false
    @State var currentUser: User?
    
    var body: some View {
        NavigationView {
            VStack{
                Text("Welcome to Tempe historical sites")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .multilineTextAlignment(.center)
                Text("Explore historic Tempe!")
                    .font(.headline)
                    .fontWeight(.regular)
                    .padding()
                if isLoggedIn, let user = currentUser {
                    Text("Hello, \(user.username)!")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                    NavigationLink(destination: HomeView()) {
                        Text("Explore")
                            .padding()
                            .backgroundStyle(.blue)
                            .cornerRadius(10)
                    }
                } else {
                    NavigationLink(destination: SignUpView()) {
                        Text("Sign Up")
                            .padding()
                            .backgroundStyle(.blue)
                            .cornerRadius(10)
                    }
                    NavigationLink(destination: SignInView()) {
                        Text("Sign In")
                            .padding()
                            .backgroundStyle(.blue)
                            .cornerRadius(10)
                    }
                }
                
            }
            
        }
        .padding()
        .onAppear {
            checkUserSignInStatus()
        }
    }
    
    func checkUserSignInStatus() {
        if let user = Auth.auth().currentUser {
            isLoggedIn = true
            getCurrentUserData(userId: user.uid)
        } else {
            isLoggedIn = false
            currentUser = nil
        }
    }
    
    func getCurrentUserData(userId: String) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).getDocument { snapshot, error in
            if let error = error {
                print("Error getting user data: \(error)")
                return
            }
            if let snapshot = snapshot, snapshot.exists {
                let data = snapshot.data()
                let username = data?["username"] as? String ?? ""
                currentUser = User(userId: userId, username: username)
            }
        }
    }
}

#Preview {
    LandingPage()
}
