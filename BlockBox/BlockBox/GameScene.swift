//
//  GameScene.swift
//  BlockBox
//
//  Created by Bryce Daniel on 10/3/14.
//  Copyright (c) 2014 Bryce Daniel. All rights reserved.
//

import SpriteKit
import Foundation
import UIKit

// Object Variable
var block: SKSpriteNode!
var box: SKSpriteNode!
var heart1: SKSpriteNode!
var heart2: SKSpriteNode!
var heart3: SKSpriteNode!
var playAgain: SKSpriteNode!
var blockSet: SKNode!

// Lables
var scoreLabel: SKLabelNode!
var highScoreLabel: SKLabelNode!

// Random Variable
var columnMultiplier: CGFloat!

// Touch Object
var currentNodeTouched: SKNode!

// GameState Variables
var score = NSInteger()
var lives = NSInteger()
var highScore = NSInteger()
var levelWin: Bool = false
var gameLose: Bool = false
var spawnTime: NSTimeInterval = 0.7
var gravityValue: CGFloat = 1.5
var scoreCounter: Int = 30

//Contact Categories
let blockCategory: UInt32 = 1 << 0
let worldCategory: UInt32 = 1 << 1
let boxCategory: UInt32 = 1 << 2
let buttonCategory: UInt32 = 1 << 3

// Function to input color as Hex
extension UIColor {
    convenience init(rgb: UInt) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}


class GameScene: SKScene, SKPhysicsContactDelegate {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = UIColor.blackColor()
        self.physicsWorld.gravity = CGVectorMake(0.0, -gravityValue)
        self.physicsWorld.contactDelegate = self
        setupBackground()
        setupBlocks()
        setupGround()
        setupBox()
        setupScore()
        setupHighScore()
        setupHeart1()
        setupHeart2()
        setupHeart3()
        setupLives()
        
        blockSet = SKNode()
        self.addChild(blockSet)
        
    }
    
    
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        background.size = CGSizeMake(self.frame.width, self.frame.height)
        background.zPosition = -10
        self.addChild(background)
    }
    
    
    func setupBlocks() {
        
        let spawn = SKAction.runBlock { () -> Void in
            self.spawnBlocks()
        }
        
        let delay = SKAction.waitForDuration(spawnTime)
        
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        
        self.runAction(spawnThenDelayForever)
    }
    
    func IncreaseSpawnRate(){
        if scoreCounter == 0 {
            spawnTime = spawnTime - 0.1
            gravityValue = gravityValue + 0.1
//            setupBlocks()
            scoreCounter = 30
            
            println("spawntime\(spawnTime)")
        }
    }
    
    func spawnBlocks() {
        block = SKSpriteNode(imageNamed: "block")
        block.size = CGSizeMake((block.size.width / 2), (block.size.height / 2))
        do {
            columnMultiplier = (CGFloat(arc4random_uniform(100))) / 100
        } while(columnMultiplier <= 0.3 || columnMultiplier >= 0.7)
        
        block.position = CGPointMake((columnMultiplier * self.frame.width), (self.frame.height + block.size.height))
        block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
        
        block.physicsBody?.categoryBitMask = blockCategory
        block.physicsBody?.contactTestBitMask = boxCategory | worldCategory
//          block.physicsBody?.collisionBitMask = worldCategory | blockCategory | boxCategory
//            block.physicsBody?.allowsRotation = false
        block.name = "LiveBlock"
        block.physicsBody?.restitution = 0.01
//        self.addChild(block)
        blockSet.addChild(block)
        
    }
    
    func setupGround() {
        let ground = SKSpriteNode(imageNamed: "ground")
        ground.size = CGSizeMake(self.frame.width, ground.frame.height / 2)
        ground.position = CGPointMake(self.frame.height, 10)
        ground.zPosition = -9
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.dynamic = false
        
        ground.physicsBody?.categoryBitMask = worldCategory
        ground.physicsBody?.contactTestBitMask = blockCategory
        ground.physicsBody?.collisionBitMask = blockCategory
        
        self.addChild(ground)
    }
    
    func setupBox() -> CGPoint{
        box = SKSpriteNode(imageNamed: "box")
        box.size = CGSizeMake(box.size.width / 2, box.size.height / 2)
        box.position = CGPointMake(self.frame.width / 2 , self.frame.height / 5)
        let boxTexture = SKTexture(imageNamed: "box")
        box.physicsBody = SKPhysicsBody(texture: boxTexture, size: box.size)
        box.physicsBody?.dynamic = false
        box.name = "box"
        
        box.physicsBody?.categoryBitMask = boxCategory
        box.physicsBody?.contactTestBitMask = blockCategory
        box.physicsBody?.collisionBitMask = blockCategory
        self.addChild(box)
        return box.position
    }

    
    func setupPlayAgain() {
        playAgain = SKSpriteNode(imageNamed: "playAgain")
        playAgain.size = CGSizeMake(playAgain.size.width / 2, playAgain.size.height / 2)
        playAgain.position = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        playAgain.physicsBody = SKPhysicsBody(rectangleOfSize: playAgain.size)
        playAgain.physicsBody?.dynamic = false
        
        playAgain.physicsBody?.categoryBitMask = buttonCategory
        playAgain.physicsBody?.contactTestBitMask = blockCategory
        playAgain.name = "playAgainButton"
        
        self.addChild(playAgain)
    }
    
    func setupScore() {
        score = 0
        scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.fontSize = 50
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height / 1.1)
        scoreLabel.text = String(score)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
    }
    
    func setupHighScore() {
        if highScore <= score {
            highScore = score
        }
        highScoreLabel = SKLabelNode(fontNamed: "Helvetica")
        highScoreLabel.fontColor = UIColor.grayColor()
        highScoreLabel.fontSize = 30
        highScoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height / 1.15)
        highScoreLabel.text = String(highScore)
        highScoreLabel.zPosition = 101
        self.addChild(highScoreLabel)
    }
    
    func updateHighScore() {
        if highScore <= score {
            highScore = score
            highScoreLabel.text = String(highScore)
        }
    }
    
    func setupLives(){
        lives = 30
    }
    
    func updateLives(){
        switch lives {
        case 20:
            heart3.removeFromParent()
        case 10:
            heart2.removeFromParent()
        case 0:
            heart1.removeFromParent()
            gameLose = true
            setupPlayAgain()
        default:
            break
        }
            println(lives)
        
    }
    
    // Display Lives
    func setupHeart1() {
        heart1 = SKSpriteNode(imageNamed: "life")
        heart1.size = CGSizeMake(heart1.size.width / 2, heart1.size.height / 2)
        heart1.position = CGPointMake(self.frame.width / 3, self.frame.height / 1.07)
        self.addChild(heart1)
    }
    
    func setupHeart2() {
        heart2 = SKSpriteNode(imageNamed: "life")
        heart2.size = CGSizeMake(heart2.size.width / 2, heart2.size.height / 2)
        heart2.position = CGPointMake(self.frame.width / 2.7, self.frame.height / 1.07)
        self.addChild(heart2)
    }
    
    func setupHeart3() {
        heart3 = SKSpriteNode(imageNamed: "life")
        heart3.size = CGSizeMake(heart3.size.width / 2, heart3.size.height / 2)
        heart3.position = CGPointMake(self.frame.width / 2.45, self.frame.height / 1.07)
        self.addChild(heart3)
    }
    
    // Reset the game after loss
    func resetScene() {
        // Reposition Box
        box.position = CGPointMake((self.frame.width / 2 ), self.frame.height / 5)
        
        // Clear blocks
        blockSet.removeAllChildren()
        playAgain.removeFromParent()
        
        // Reset World
        gravityValue = 1.5
        
        
        // Reset score
        score = 0
        scoreLabel.text = String(score)
        scoreCounter = 30
        
        // Reset lives
        lives = 30
        setupHeart1()
        setupHeart2()
        setupHeart3()
        gameLose = false
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if (( contact.bodyA.categoryBitMask & boxCategory ) == boxCategory || ( contact.bodyB.categoryBitMask & boxCategory ) == boxCategory)
            && (contact.bodyB.node?.frame.origin.y > contact.bodyA.node?.frame.minY && contact.bodyB.node?.frame.origin.y < contact.bodyA.node?.frame.maxY)
            && (contact.bodyB.node?.frame.origin.x > contact.bodyA.node?.frame.minX && contact.bodyB.node?.frame.origin.x < contact.bodyA.node?.frame.maxX) {
            
            println("SCORE!")
            
            let delay = SKAction.waitForDuration(0.1)
            let deleteBlock = SKAction.removeFromParent()
            let fadeAway = SKAction.fadeOutWithDuration(0.1)
            let delayThenFade = SKAction.sequence([delay,fadeAway])
            let fadeThenDelete = SKAction.sequence([delayThenFade, deleteBlock])
            
            if ((contact.bodyB.node?.name == "LiveBlock") && (gameLose == false)) {
                score = score + 1
                scoreLabel.text = String(score)
                updateHighScore()
                scoreCounter = scoreCounter - 1
                IncreaseSpawnRate()
                contact.bodyB.node?.name = "DeadBlock"
                //            println(score)
            }
            contact.bodyB.node?.runAction(fadeThenDelete)
        } else if (contact.bodyA.categoryBitMask & worldCategory) == worldCategory || (contact.bodyB.categoryBitMask & worldCategory) == worldCategory {
            
            println("dead")
            let delay = SKAction.waitForDuration(5)
            let colorChange = SKAction.colorizeWithColor(UIColor(rgb: 0x222222), colorBlendFactor: 1.0, duration: 0.5)
            
            let deleteBlock = SKAction.removeFromParent()
            let fadeAway = SKAction.fadeOutWithDuration(0.25)
            let delayThenFade = SKAction.sequence([delay,fadeAway])
            let colorFadeThenDelete = SKAction.sequence([colorChange,delayThenFade, deleteBlock])
            
            if contact.bodyB.node?.name == "LiveBlock" {
                lives = lives - 1
                updateLives()
                contact.bodyB.node?.name = "DeadBlock"
            }
            contact.bodyB.node?.runAction(colorFadeThenDelete)

        } else if (contact.bodyA.contactTestBitMask & buttonCategory) == buttonCategory || (contact.bodyB.contactTestBitMask & buttonCategory) == buttonCategory {
            let delay = SKAction.waitForDuration(5)
            let colorChange = SKAction.colorizeWithColor(UIColor(rgb: 0x222222), colorBlendFactor: 1.0, duration: 0.5)
            
            let deleteBlock = SKAction.removeFromParent()
            let fadeAway = SKAction.fadeOutWithDuration(0.25)
            let delayThenFade = SKAction.sequence([delay,fadeAway])
            let colorFadeThenDelete = SKAction.sequence([colorChange,delayThenFade, deleteBlock])
            contact.bodyB.node?.runAction(colorFadeThenDelete)
        }
    
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self) as CGPoint
            var node: SKNode = self.nodeAtPoint(location)
            
            let time = NSTimeInterval(abs(location.x - box.position.x) * 0.0009)
            
            if (location.x != box.position.x) {
                box.runAction(SKAction.moveToX(location.x, duration: time))
            }
            if (node.name == "playAgainButton"){
                resetScene()
            }
        
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let time = NSTimeInterval(abs(location.x - box.position.x) * 0.0009)
            
            if (location.x != box.position.x) {
                box.runAction(SKAction.moveToX(location.x, duration: time))
            }
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        box.removeAllActions()
    }
    
    
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        self.physicsWorld.gravity = CGVectorMake(0.0, -gravityValue)
    }
}
