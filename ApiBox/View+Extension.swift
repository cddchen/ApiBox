//
//  View+Extensions.swift
//  ApiBox
//
//  Created by 陈东 on 7/27/23.
//

import SwiftUI

extension View {
    @ViewBuilder
    func hSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxWidth: .infinity, alignment: alignment)
    }
    
    @ViewBuilder
    func vSpacing(_ alignment: Alignment) -> some View {
        self
            .frame(maxHeight: .infinity, alignment: alignment)
    }
}

extension Color {
    static let lightGray = Color(UIColor.lightGray)
}
