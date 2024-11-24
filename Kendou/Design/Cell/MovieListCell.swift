//
//  SwiftUI.swift
//  Kendou
//
//  Created by 藤平真里奈 on 2024/11/10.
//

import SwiftUI

struct MovieListCell: View {
    //動画のタイトル
    let videoName: String
    //画像
    let image:UIImage?
    var body: some View {
        ZStack{
            BCView()
            
            HStack{
                HStack {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 144, maxHeight: 72)
                            .padding(.leading,36)
                        
                        Text(videoName)
                            .padding()
                        
                       Spacer()
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder
    func BCView() -> some View{
        RoundedRectangle(cornerRadius: 25)
            .fill(.white)
            .frame(height: 100)
            .opacity(0.1)
            .background(Color.white.opacity(0.08).blur(radius: 10)
            )
            .background(
            RoundedRectangle(cornerRadius: 25)
                .stroke(
                    .linearGradient(.init(colors: [Color("BGBlue1"),Color("BGBlue1").opacity(0.5),.clear,.clear,Color("BGBlue2"),]),startPoint: .topLeading,endPoint: .bottomTrailing),lineWidth: 2.5
                )
            
            .padding(2)
        )
            .shadow(color: .black.opacity(0.05), radius: 5,x: -5, y: -5)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 5,y: 5)
            .padding(16)
        
    }
}

#Preview {
    MovieListCell(videoName: "TestVideoName", image: UIImage(named: "person.fill"))
}
