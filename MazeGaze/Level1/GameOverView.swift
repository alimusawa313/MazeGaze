//
//  GameOverView.swift
//  MazeGaze
//
//  Created by Ali Haidar on 27/05/24.
//

import SwiftUI
import Foundation


struct GameOverView: View {
    
    @State private var bounce = false
    
    @State private var navigateToLevel: Bool = false
    @State private var navigateToHome: Bool = false
    let userDefaults = UserDefaults.standard
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    
    
    
    var score:String
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Image("game_bg")
                    .resizable()
                    .ignoresSafeArea()
                HStack{
                    
                    VStack {
                        Spacer()
                        Image("done_ninja")
                    }
                    Spacer()
                    
                    VStack(spacing: 20) {
                        Text("Game Over")
                            .font(.system(size: 100))
                            .foregroundStyle(Color(hex: "#FDD26D"))
                            .bold()
                            .shadow(color: Color(hex: "#E65355"), radius: 1, x: 5, y: 5)
                            .shadow(color: Color(hex: "#003E63"), radius: 1, x: 10, y: 10)
                            .offset(y: bounce ? -10 : 10)
                            .onAppear {
                                withAnimation(Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                                    bounce.toggle()
                                }
                            }
                        
                        Text("Score: \(score) second")
                            .font(.title)
                        //                            .foregroundStyle(.white)
                        //                        Text("High Score: \(score) second")
                        
                        
                        
                        Button {
                            ButtonSound.playMusic(selectedSound: "button")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                navigateToLevel = true
                            }
                        } label: {
                            HStack(spacing: 25) {
                                Image(systemName: "play.fill")
                                Text("Play Again")
                            }
                            .shadow(radius: 10)
                            .foregroundStyle(.white)
                            .font(.title)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 25.0).foregroundStyle(Color(hex: "#FDD26D")).shadow(color: Color(hex: "#E65355"), radius: 1, x: 5, y: 5)
                                .shadow(color: Color(hex: "#003E63"), radius: 1, x: 10, y: 10).frame(width: 300))
                        }
                        
                        Button {
                            ButtonSound.playMusic(selectedSound: "button")
                            DispatchQueue.main.async {
                                navigateToHome = true
                            }
                        } label: {
                            HStack(spacing: 25) {
                                Image(systemName: "house.fill")
                                Text("Go Back Home")
                            }
                            .shadow(radius: 10)
                            .foregroundStyle(.white)
                            .font(.title)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 25.0).foregroundStyle(Color(hex: "#FDD26D")).shadow(color: Color(hex: "#E65355"), radius: 1, x: 5, y: 5)
                                .shadow(color: Color(hex: "#003E63"), radius: 1, x: 10, y: 10).frame(width: 300))
                        }
                        
                    }
                    
                    Spacer()
                }
            }
            //            .navigationDestination(isPresented: $navigateToLevel){
            //                Level1View()
            //            }
            .navigationDestination(isPresented: $navigateToLevel) {
                Level1View()
                    .onAppear {
//                        self.presentationMode.wrappedValue.dismiss()
                    }
            }
            .navigationDestination(isPresented: $navigateToHome){
                MapChapterSelectionView()
            }
        }.onAppear{
                        ButtonSound.playSound(selectedSound: "game_done")
        }
        .onDisappear{
                    dismiss()
                }
        .navigationBarBackButtonHidden(true)
        
        
    }
}

#Preview {
    GameOverView(score: "200")
}
