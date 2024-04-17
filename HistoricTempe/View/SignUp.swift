// SignUpView.swift
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpView: View {
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
            TextField("Email", text: $email)
                .padding()
            SecureField("Password", text: $password)
                .padding()
            Button(action: {
                register(username: username, email: email, password: password)
            }) {
                Text("Sign Up")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    func register(username: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                alertTitle = "Signup Failed"
                alertMessage = errorMessage
                showAlert = true
            } else {
                errorMessage = ""
                alertTitle = "Signup Successful"
                alertMessage = "You have successfully signed up."
                showAlert = true
            }
            if let user = result?.user {
                saveUserData(userId: user.uid, username: username, email: email)
            }
        }
    }
    
    func saveUserData(userId: String, username: String, email: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userId)
        userRef.setData([
            "userId": userId,
            "username": username,
            "email": email
        ]) { error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                // Handle successful user data save
            }
        }
    }
}
