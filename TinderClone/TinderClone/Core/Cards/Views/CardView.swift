//
//  CardView.swift
//  TinderClone
//
//  Created by Mauricio Cesar on 19/03/24.
//

import SwiftUI

struct CardView: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Image(.meganfox1)
                .resizable()
                .scaledToFill()

            UserInfoView()
                .padding(.horizontal)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

extension CardView {
    private var cardWidth: CGFloat {
        UIScreen.main.bounds.width - 20
    }

    private var cardHeight: CGFloat {
        UIScreen.main.bounds.height / 1.45
    }
}

#Preview {
    CardView()
}
