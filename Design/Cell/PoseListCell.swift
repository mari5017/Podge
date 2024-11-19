//
//  PoseListCell.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/11/10.
//

import SwiftUI

struct PoseListCell: View {
    let title: String
    let description: String
    let imageRsc: String
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
        ZStack {
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
                            .linearGradient(.init(colors: [
                                Color("BGBlue2"),
                                Color("BGBlue2"),
                                .clear,
                                Color("BGBlue1"),
                                Color("BGBlue1"),
                            ]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 3
                        )
                        .padding(2)
                )
                .shadow(color: .black.opacity(0.05), radius: 5, x: -5, y: -5)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 5, y: 5)
            poseLayoutView()
        }
        
    }
    @ViewBuilder func poseLayoutView() -> some View {
        VStack{
            Image(imageRsc)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: 200, maxHeight: 220)
            Text(title)
                .font(.title)
            Text(description)
                .font(.body)
                .frame(maxWidth: 240)
        }
    }
}
    #Preview {
        PoseListCell(title: "タイトル: title",description: "説明: description",imageRsc: "person.fill")
    }

