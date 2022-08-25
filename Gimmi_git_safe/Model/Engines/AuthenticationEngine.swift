//
//  AuthenticationEngine.swift
//  Gimmi
//
//  Created by Marco Tagliafierro on 09/03/22.
//

import Foundation
import Firebase
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class AuthenticationEngine: NSObject {
    
    // Singleton
    static let shared: AuthenticationEngine = AuthenticationEngine()
    
    public var onCompletion : ((User?) -> ())!
    private var firstStart = true
    
    // Apple login nonce
    private var currentNonce: String?
    
    
    /// Manages the user's authentication by retrieving the previous token, if
    /// existing, or by requesting a temporary one
    ///
    /// - Parameter onCompletion: completion closure
    public func manageExistingAuthenticationToken(onCompletion: @escaping (User?) -> ()) {
        
        var auth = Auth.auth().currentUser
        
        if firstStart { auth = nil } // TEST ONLY
        firstStart = false
        
        if auth == nil {
        
            Auth.auth().signInAnonymously() { authResult, error in
                
                print("[CHECK] AuthenticationEngine: user logged in with temporary credentials")

                if error != nil {
                    onCompletion(nil)
                    
                    print("[Error] AuthenticationEngine: error during sing in with temporary credentials \(error!)")
                } else {
                    onCompletion(authResult?.user)
                }

            }
            
        } else {
            
            print("[CHECK] AuthenticationEngine: user logged in with previous credentials")
            onCompletion(auth)
            
        }
        
    }
    
    // Sign in Firebase using the provided credentials
    private func signInFirebase(with credential: AuthCredential, onCompletion: @escaping (User?) -> ()) {
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
       
            if let error = error {
                print(error.localizedDescription)
                onCompletion(nil)
                return
            }
            
            onCompletion(authResult?.user)
            
        }
        
    }

}

// Login with Google
extension AuthenticationEngine {
    
    func requestGoogleSignIn(onCompletion: @escaping (User?) -> ()) {
        
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }

        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: rootViewController) { user, error in

            if let error = error {
                print(error)
                return
            }

            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
            self.signInFirebase(with: credential, onCompletion: onCompletion)
            
        }
        
    }
    
}

// Login with Apple
extension AuthenticationEngine: ASAuthorizationControllerDelegate {
    
    // Generate a rondom nonce to be used in the login process
    private func randomNonceString(length: Int = 32) -> String {
        
        let charset: [Character] =  Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                    "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
    
    // Return the hash of the input string
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    /// Generates a nonce and forges a sing-in request with it
    public func forgeLoginWithAppleRequest(requestedScopes: [ASAuthorization.Scope] = [.fullName, .email]) -> ASAuthorizationAppleIDRequest {
        
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        return request
        
    }
    
    // Delegate's methods
    
    // Error in the authentication process
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("[ERROR] An error occurred while authenticating with Apple (\(error)")
    }
    
    // Authentication went as planned
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
        
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            // Initialize a Firebase credential.
            let credential = OAuthProvider.credential(
                withProviderID: "apple.com",
                idToken: idTokenString,
                rawNonce: nonce
            )
            
            // Sign in with Firebase.
            signInFirebase(with: credential, onCompletion: onCompletion)
            
        }

    }
    
}
