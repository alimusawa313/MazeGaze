//
//  GameState.swift
//  MazeGaze
//
//  Created by Ali Haidar on 27/05/24.
//

import SwiftUI
import Combine

class GameState: ObservableObject, GameDelegate {
    @Published var isGameOver = false
    
    func gameDidEnd() {
        isGameOver = true
    }
}

