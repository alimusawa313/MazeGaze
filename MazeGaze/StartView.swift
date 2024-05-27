//
//  StartView.swift
//  MazeGaze
//
//  Created by Ali Haidar on 26/05/24.
//

import SwiftUI

struct StartView: View {
    
    @State var eyeGazeActive: Bool = true
    @State var lookAtPoint: CGPoint?
    @State var isWinking: Bool = false
    
    @State var isButtonClicked: Bool = false
    @State var navigateToChapterSelection: Bool = false
    @State private var bounce = false
//    
//    @Environment(\.dismiss) private var dismiss
    
    
    @State var rect = CGRect()
    @State var checkRect: String = ""
    @State var aRects = [CGRect]()
    
    
    private let start = Date()
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color(hex: "#003E63")
                    .ignoresSafeArea()
                
                Image("bg")
                    .resizable()
                    .padding()
                
//                ARViewContainer(eyeGazeActive: $eyeGazeActive, lookAtPoint: $lookAtPoint, isWinking: $isWinking).opacity(0)
                
                VStack(spacing: 20) {
                    Text("MazeGaze")
                        .font(.system(size: 150))
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
                    
                    Button {
                        DispatchQueue.main.async{

                            navigateToChapterSelection = true
                            ButtonSound.playSound(selectedSound: "start_button_sound")
                        }
                    } label: {
                        Text("Start")
                            .bold()
                            .font(.largeTitle)
                            .foregroundStyle(.white)
                            .padding(EdgeInsets(top: 15, leading: 35, bottom: 15, trailing: 35))
                            .background(RoundedRectangle(cornerRadius: 25.0).foregroundStyle(Color(hex: "#E65355")))
                    }
                    
                    
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height + 4)
//                .background(Rectangle()
//                    .colorEffect(
//                        ShaderLibrary.default.timeLines(
//                            .boundingRect,
//                            .float(17),
//                            .float(1))
//                    ))
                .background(TimelineView(.animation) { context in
                    Rectangle()
                        .foregroundStyle(.white)
                        .timeLines(seconds: context.date.timeIntervalSince1970 - self.start.timeIntervalSince1970,
                                   tapValue: 1
                        )
                })
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
                                    .frame(width: isWinking ? 250 : 200, height: isWinking ? 250 : 200)
                            )
                            .position(lookAtPoint)
                            .zIndex(1)
                            .animation(Animation.easeInOut(duration: 1.2), value: lookAtPoint)
                        
                    }
                }
            }.navigationDestination(isPresented: $navigateToChapterSelection) {
                MapChapterSelectionView()
            }
        }.navigationViewStyle(StackNavigationViewStyle())
    }
    
}


extension View {
    @inlinable
    public func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask {
            Rectangle()
                .overlay(alignment: alignment) {
                    mask()
                        .blendMode(.destinationOut)
                }
        }
    }
}
extension View {
    
    func timeLines(seconds: Double,  tapValue: CGFloat ) -> some View {
        
        self
            .colorEffect(
                ShaderLibrary.default.timeLines(
                    .boundingRect,
                    .float(seconds),
                    .float(tapValue))
            )
    }
}
#Preview {
    StartView()
}
