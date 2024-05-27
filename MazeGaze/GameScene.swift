//
//  GameScene.swift
//  MazeGaze
//
//  Created by Ali Haidar on 27/05/24.
//
import Foundation
import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    static var player: AVAudioPlayer?
    var hero = SKSpriteNode()
    let hisTexture = SKTexture(imageNamed: "man_idle")
    let jump_button = SKTexture(imageNamed: "jump")
    var moveToLeft = false
    var moveToRight = false
    var isJumping = false
    var isOnGround = false
    
    weak var gameDelegate: GameDelegate?

    
    enum bitMaks: UInt32 {
        case hero = 0b1
        case ground = 0b10
        case door = 0b100
    }
    
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        for node in self.children {
            if(node.name == "Platform") {
                if let someTileMap: SKTileMapNode = node as? SKTileMapNode {
                    tilePhysics(map: someTileMap)
                    someTileMap.removeFromParent()
                }
                break
            }
        }
        
        addHero()
        addDoor()
    }
    
    func addHero() {
        hero = childNode(withName: "man_idle") as! SKSpriteNode
        hero.zPosition = 50
        hero.physicsBody = SKPhysicsBody(texture: hisTexture, size: hero.size)
        hero.physicsBody?.categoryBitMask = bitMaks.hero.rawValue
        hero.physicsBody?.contactTestBitMask = bitMaks.ground.rawValue | bitMaks.door.rawValue
        hero.physicsBody?.collisionBitMask = bitMaks.ground.rawValue
        hero.physicsBody?.allowsRotation = false
    }
    
    func addDoor() {
            if let door = childNode(withName: "door") as? SKSpriteNode {
                door.physicsBody = SKPhysicsBody(rectangleOf: door.size)
                door.physicsBody?.isDynamic = false
                door.physicsBody?.categoryBitMask = bitMaks.door.rawValue
                door.physicsBody?.contactTestBitMask = bitMaks.hero.rawValue
                door.physicsBody?.collisionBitMask = 0
            }
        }
    
    func tilePhysics(map: SKTileMapNode) {
        let tileMap = map
        let startLocation: CGPoint = tileMap.position
        let tileSize = tileMap.tileSize
        let halfWidth = CGFloat(tileMap.numberOfColumns) / 2.0 * tileSize.width
        let halfHeight = CGFloat(tileMap.numberOfRows) / 2.0 * tileSize.height
        
        for col in 0..<tileMap.numberOfColumns {
            for row in 0..<tileMap.numberOfRows {
                if let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row) {
                    let tileArray = tileDefinition.textures
                    let tileTextures = tileArray[0]
                    let x = CGFloat(col) * tileSize.width - halfWidth + (tileSize.width / 2)
                    let y = CGFloat(row) * tileSize.height - halfHeight + (tileSize.height / 2)
                    
                    let tileNode = SKSpriteNode(texture: tileTextures)
                    tileNode.position = CGPoint(x: x, y: y)
                    tileNode.physicsBody = SKPhysicsBody(texture: tileTextures, size: CGSize(width: tileTextures.size().width, height: tileTextures.size().height))
                    
                    tileNode.physicsBody?.categoryBitMask = bitMaks.ground.rawValue
                    tileNode.physicsBody?.contactTestBitMask = bitMaks.hero.rawValue
                    tileNode.physicsBody?.collisionBitMask = bitMaks.hero.rawValue
                    tileNode.physicsBody?.affectedByGravity = false
                    tileNode.physicsBody?.isDynamic = false
                    tileNode.physicsBody?.friction = 1
                    tileNode.zPosition = 0
                    //                    tileNode.anchorPoint = .zero
                    tileNode.position = CGPoint(x: tileNode.position.x + startLocation.x, y: tileNode.position.y + startLocation.y)
                    
                    self.addChild(tileNode)
                }
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == bitMaks.hero.rawValue && contact.bodyB.categoryBitMask == bitMaks.ground.rawValue) ||
            (contact.bodyB.categoryBitMask == bitMaks.hero.rawValue && contact.bodyA.categoryBitMask == bitMaks.ground.rawValue) {
            isOnGround = true
        }
        
        if (contact.bodyA.categoryBitMask == bitMaks.hero.rawValue && contact.bodyB.categoryBitMask == bitMaks.door.rawValue) ||
                   (contact.bodyB.categoryBitMask == bitMaks.hero.rawValue && contact.bodyA.categoryBitMask == bitMaks.door.rawValue) {
                   endGame()
               }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if (contact.bodyA.categoryBitMask == bitMaks.hero.rawValue && contact.bodyB.categoryBitMask == bitMaks.ground.rawValue) ||
            (contact.bodyB.categoryBitMask == bitMaks.hero.rawValue && contact.bodyA.categoryBitMask == bitMaks.ground.rawValue) {
            isOnGround = false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let position = touch.location(in: self)
            let touchNode = self.nodes(at: position)
            
            for node in touchNode {
                if node.name == "left" {
                    moveToLeft = true
                    playWalkingSound()
                }
                if node.name == "right" {
                    moveToRight = true
                    playWalkingSound()
                }
                if node.name == "jump" {
                    isJumping = true
                }
            }
        }
    }
    
    private func playWalkingSound(){
        guard let soundURL = Bundle.main.url(forResource: "walk", withExtension: "mp3") else {
            return
        }
        
        do {
            Level1View.player = try AVAudioPlayer(contentsOf: soundURL)
            Level1View.player?.numberOfLoops = -1
        } catch {
            print("Failed to load the sound: \(error)")
        }
        GameScene.player?.play()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let position = touch.location(in: self)
            let touchNode = self.nodes(at: position)
            
            for node in touchNode {
                if node.name == "left" {
                    moveToLeft = false
                    GameScene.player?.stop()
                }
                if node.name == "right" {
                    moveToRight = false
                    GameScene.player?.stop()
                }
                if node.name == "jump", isOnGround {
                    isJumping = false
                }
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if moveToLeft {
            hero.position.x -= 5
        }
        if moveToRight {
            hero.position.x += 5
        }
        if !moveToLeft && !moveToRight {
            hero.physicsBody?.velocity.dx = 0
        }
    }
    
    func jump() {
//        if isOnGround {
            hero.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 30))
//        }
    }
    
    
    func endGame() {
        
//        print("Game Over")
        gameDelegate?.gameDidEnd()
    }
    
    func resetGame() {
            guard let scene = SKScene(fileNamed: "GameScene") else {
                return
            }
            scene.scaleMode = .aspectFill
            view?.presentScene(scene, transition: SKTransition.crossFade(withDuration: 1.0))
        }
}




//func createPlatform(){
//    let platform = SKSpriteNode()
//    platform.size = CGSize(width: UIScreen.main.bounds.width, height: 50)
//    platform.color = .blue
//    platform.position = CGPoint(x: 50, y: 50)
//
//    platform.position = CGPoint(x: 150, y: 250)
//
//    platform.zRotation = 0 // rotate the platform
//
//    platform.physicsBody = SKPhysicsBody(rectangleOf: platform.size)
//
//    platform.physicsBody?.isDynamic = false
//    platform.physicsBody?.affectedByGravity = false
//
//    self.addChild(platform)
//}
