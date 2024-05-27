//
//  testView.swift
//  MazeGaze
//
//  Created by Ali Haidar on 27/05/24.
//

import SwiftUI

struct testView: View {
    var body: some View {
        HStack(spacing:55){
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "house.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color(hex: "#FDD26D"))
                        .padding()
                        .background(Circle())
                    
                    Text("Home")
                }.foregroundStyle((Color(hex: "#003E63")))
            }
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "arrow.clockwise")
                        .bold()
                        .font(.largeTitle)
                        .foregroundStyle(Color(hex: "#FDD26D"))
                        .padding()
                        .background(Circle())
                    
                    Text("Restart")
                }.foregroundStyle((Color(hex: "#003E63")))
            }
            
            Button {
                
            } label: {
                VStack {
                    Image(systemName: "play.fill")
                        .font(.largeTitle)
                        .foregroundStyle(Color(hex: "#FDD26D"))
                        .padding()
                        .background(Circle())
                    
                    Text("Continue")
                }.foregroundStyle((Color(hex: "#003E63")))
            }

            
        }.background(RoundedRectangle(cornerRadius: 25.0).foregroundStyle(Color(hex: "#E65355")).frame(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 3))
    }
}

#Preview {
    testView()
}
