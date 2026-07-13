import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        NavigationStack {
            Spacer()
            
            VStack {
                Image("Instagram_logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 100)

                VStack {
                    TextField("Enter your email", text: $email)
                        .autocapitalization(.none)
                        .modifier(IGTextFieldModifier())

                    SecureField("Enter your password", text: $password)
                        .modifier(IGTextFieldModifier())
                }
            }

            Button {
                print("Show forgot password")
            } label: {
                Text("Forgot password?")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .padding(.top)
                    .padding(.trailing, 28)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }

            Button {
                print("Login")
            } label: {
                Text("Log in")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .frame(width: 360, height: 44)
                    .background(Color(.systemBlue))
                    .clipShape(.rect(cornerRadius: 8))
            }
            .padding(.vertical)

            HStack {
                Rectangle()
                    .frame(height: 0.5)

                Text("OR")
                    .font(.footnote)
                    .fontWeight(.semibold)

                Rectangle()
                    .frame(height: 0.5)
            }
            .foregroundStyle(.gray)
            .padding(.horizontal, 40)

            HStack {
                Image("facebook_logo")
                    .resizable()
                    .frame(width: 20, height: 20)

                Text("Continue with Facebook")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.systemBlue))
            }
            .padding(.top, 8)

            Spacer()

            Divider()

            NavigationLink {
                AddEmailView()
                    .navigationBarBackButtonHidden()
            } label: {
                HStack(spacing: 3) {
                    Text("Don't have an account?")

                    Text("Sign Up")
                        .fontWeight(.semibold)
                }
                .font(.footnote)
            }
            .padding(.vertical, 16)

        }
    }
}

#Preview {
    LoginView()
}
