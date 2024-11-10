//
//  PoseListCell.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/11/10.
//

import SwiftUI

struct PoseListCell: View {
    var body: some View {
       RoundedRectangle(cornerRadius: 20)
            .fill(.white)
            .opacity(0.1)
            .frame(width: 300, height: 500)
            .background(
                Color.white.opacity(0.08)
                    .blur(radius: 10)
            )
            .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    .linearGradient(.init(colors: [Color("BGBlue2"),Color.clear,Color("BGBlue1"),Color("BGBlue1")
                                                  ]),startPoint: .topLeading,endPoint: .bottomTrailing),lineWidth: 3
                )
                .padding(2)
            )
            .shadow(color:.black.opacity(0.05),radius: 5,x: -5,y: -5)
            .shadow(color:.black.opacity(0.05),radius:5, x: 5,y: 5)
    }
}

#Preview {
    PoseListCell()
}
