//
//  SideMenuRowView.swift
//  SideMenu
//
//  Created by Mauricio Cesar on 07/03/24.
//

import SwiftUI

struct SideMenuRowView: View {
    let option: SideMenuOptionModel

    @Binding var selectedOption: SideMenuOptionModel?

    private var isSelected: Bool {
        selectedOption == option
    }

    var body: some View {
        HStack {
            Image(systemName: option.systemImageName)
                .imageScale(.small)

            Text(option.title)
                .font(.subheadline)

            Spacer()
        }
        .padding(.leading)
        .foregroundStyle(isSelected ? .blue : .primary)
        .frame(width: 216, height: 44)
        .background(isSelected ? .blue.opacity(0.25) : .clear)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    SideMenuRowView(option: .dashboard, selectedOption: .constant(.dashboard))
}
