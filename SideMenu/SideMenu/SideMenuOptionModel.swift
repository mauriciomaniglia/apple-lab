//
//  SideMenuOptionModel.swift
//  SideMenu
//
//  Created by Mauricio Cesar on 07/03/24.
//

import Foundation

enum SideMenuOptionModel: Int, CaseIterable {
    case dashboard
    case performance
    case profile
    case search
    case notifications

    var title: String {
        switch self {
        case .dashboard:
            "Dashboard"
        case .performance:
            "Performance"
        case .profile:
            "Profile"
        case .search:
            "Search"
        case .notifications:
            "Notifications"
        }
    }

    var systemImageName: String {
        switch self {
        case .dashboard:
            "filemenu.and.cursorarrow"
        case .performance:
            "chart.bar"
        case .profile:
            "person"
        case .search:
            "magnifyingglass"
        case .notifications:
            "bell"
        }
    }
}

extension SideMenuOptionModel: Identifiable {
    var id: Int { self.rawValue }
}
