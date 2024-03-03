//
//  PasscodeView.swift
//  PasscodeScreen
//
//  Created by Mauricio Cesar on 02/03/24.
//

import SwiftUI

struct PasscodeView: View {
    @State private var passcode = ""

    var body: some View {
        VStack(spacing: 48) {
            VStack(spacing: 24) {
                Text("Enter Passcode")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                Text("Please enter your 4-digit pin to security access your account")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
            }
            .padding(.top)

            PasscodeIndicatorView(passcode: $passcode)

            Spacer()

            NumberPadView(passcode: $passcode)
        }
    }
}

#Preview {
    PasscodeView()
}
