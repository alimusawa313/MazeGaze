//
//  Level1View.swift
//  MazeGaze
//
//  Created by Ali Haidar on 27/05/24.
//

import SwiftUI
import SpriteKit
import AVFoundation

struct Level1View: View {
    
    static var player: AVAudioPlayer?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var gameState = GameState()
    
    var scene: SKScene = {
        let scene = GameScene(fileNamed: "Level1.sks")!
        scene.scaleMode = .resizeFill
        return scene
    }()
    
    @State private var moveToLeft = false
    @State private var moveToRight = false
    @State private var isJumping = false
    
    
    @State var eyeGazeActive: Bool = true
    @State var lookAtPoint: CGPoint?
    @State var isWinking: Bool = false
    @State private var firstBlinkDetected = false
    
    @State var isShowingMenu: Bool = false
    @State var isButtonClicked: Bool = false
    @State var navigateToGameOver: Bool = false
    @State var navigateToHome: Bool = false
    @State private var bounce = false
    
    @State private var isGameOver = false
    
    
    
    @State var rect = CGRect()
    @State var checkRect: String = ""
    @State var aRects = [CGRect]()
    
    // Timer-related state variables
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var highScore: TimeInterval?
    let highScoreKey = "HighScore"
    
    var body: some View {
        NavigationStack {
            ZStack {
                SpriteView(scene: scene)
                    .padding(EdgeInsets(top: -15, leading: -15, bottom: 0, trailing: 0))
                
                //            Color.black
                
//                
                ARViewContainer(eyeGazeActive: $eyeGazeActive, lookAtPoint: $lookAtPoint, isWinking: $isWinking).opacity(0)
                
                if !firstBlinkDetected{
                    Text("Blink to start your game")
                        .bold()
                        .font(.largeTitle)
                        .foregroundStyle(Color.white)
                        .bold()
                        .shadow(color: .black, radius: 1, x: 5, y: 5)
                }
                
                
                VStack {
                    
                    HStack {
                        Spacer()
                        Button(action: {
                            isShowingMenu.toggle()
                            //                            navigateToHome = true
                            //                            dismiss()
                        }, label: {
                            Image("menu_button")
                        })
                    }.padding()
                    Spacer()
                    
                    //                if gameState.isGameOver{
                    //                    Text("Game Over")
                    //                        .bold()
                    //                        .font(.largeTitle)
                    //                        .foregroundStyle(.white)
                    //
                    //                }else{
                    //
                    //                }
                    
                    if gameState.isGameOver {
                        Text("Game Over")
                            .bold()
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                        //
                        //                        if let highScore = highScore {
                        //                            Text("High Score: \(highScore, specifier: "%.2f") seconds")
                        //                                .bold()
                        //                                .font(.title)
                        //                                .foregroundStyle(.white)
                        //                        }
                    } else {
                    }
                    Spacer()
                    Text("\(elapsedTime, specifier: "%.2f") seconds")
                        .bold()
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding(25)
                    if firstBlinkDetected {
                        HStack {
                            
                            HoldableButton(imageName: "left_button") {
                                (scene as? GameScene)?.moveToLeft = true
                            } onRelease: {
                                (scene as? GameScene)?.moveToLeft = false
                            }
                            
                            HoldableButton(imageName: "right_button") {
                                (scene as? GameScene)?.moveToRight = true
                            } onRelease: {
                                (scene as? GameScene)?.moveToRight = false
                            }
                            
                            
                            
                            Spacer()
                            
                            HoldableButton(imageName: "jump_button") {
                                (scene as? GameScene)?.jump()
                                ButtonSound.playMusic(selectedSound: "jump")
                            } onRelease: {
                                
                            }
                            
                            
                        }
                        .padding()
                    }
                }
                .background(firstBlinkDetected ? .black : .clear)
                .ignoresSafeArea()
                .reverseMask {
                    if let lookAtPoint = lookAtPoint {
                        
                        Image(systemName: "eye.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                            .padding(20)
                            .background(
                                Circle()
                                    .fill(isWinking ? .green : Color(hex: "#F24295"))
                                    .frame(width: isWinking ? 550 : 500, height: isWinking ? 550 : 500)
                            )
                            .position(lookAtPoint)
                            .zIndex(1)
                            .animation(Animation.easeInOut(duration: 1.2), value: lookAtPoint)
                        
                    }
                }
                
                
                if isShowingMenu{
                    menuView(dismiss: dismiss, isShowingMenu: $isShowingMenu, navigateToHome: $navigateToHome)
                }
                
            }
            .ignoresSafeArea()
            .onAppear {
                if let scene = scene as? GameScene {
                    scene.gameDelegate = gameState
                }
                //                loadHighScore()
            }
            .onDisappear{
                self.dismiss()
            }
            .onChange(of: isWinking) {
                if isWinking && !firstBlinkDetected {
                    firstBlinkDetected = true
                    startTimer()
                    playBgMusic()
                }
            }
            .onChange(of: gameState.isGameOver) {
                if gameState.isGameOver {
                    handleGameOver()
                    Level1View.player?.stop()
                    navigateToGameOver = true
                }
            }.navigationDestination(isPresented: $navigateToGameOver) {
                GameOverView(score: "\(elapsedTime)")
                    .onAppear {
                        self.dismiss()
                    }
                
            }
            .navigationDestination(isPresented: $navigateToHome) {
                MapChapterSelectionView()}
            .onAppear {
//                self.dismiss()
            }
            .navigationBarBackButtonHidden(true)
        }
        
    }
    
    private func startTimer() {
        timer?.invalidate()
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            elapsedTime += 0.1
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        //        saveHighScore()
    }
    
    //    private func loadHighScore() {
    //        highScore = UserDefaults.standard.double(forKey: highScoreKey)
    //    }
    //
    //    private func saveHighScore() {
    //        if highScore == nil || elapsedTime > highScore! {
    //            highScore = elapsedTime
    //            UserDefaults.standard.set(elapsedTime, forKey: highScoreKey)
    //        }
    //    }
    
    private func handleGameOver() {
        stopTimer()
    }
    
    private func playBgMusic(){
        guard let soundURL = Bundle.main.url(forResource: "game_level", withExtension: "wav") else {
            return
        }
        
        do {
            Level1View.player = try AVAudioPlayer(contentsOf: soundURL)
            Level1View.player?.numberOfLoops = -1
        } catch {
            print("Failed to load the sound: \(error)")
        }
        Level1View.player?.play()
    }
    
}

struct menuView: View {
    
    let dismiss: DismissAction
    @Binding var isShowingMenu: Bool
    @Binding var navigateToHome: Bool
    
    var body: some View {
        HStack(spacing:55){
            
            Button {
                dismiss()
                navigateToHome = true
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
                isShowingMenu = false
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

struct HoldableButton: View {
    let imageName: String
    let onPress: () -> Void
    let onRelease: () -> Void
    
    var body: some View {
        Button {
            
        } label: {
            Image(imageName)
                .onLongPressGesture(minimumDuration: .infinity, pressing: { isPressing in
                    if isPressing {
                        onPress()
                    } else {
                        onRelease()
                    }
                }, perform: {})
            
        }
        
        
    }
}

#Preview {
    Level1View()
}
