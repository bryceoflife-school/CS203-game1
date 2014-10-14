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
var ground: SKSpriteNode!
var block: SKSpriteNode!
var antiBlock: SKSpriteNode!
var box: SKSpriteNode!
var heart1: SKSpriteNode!
var heart2: SKSpriteNode!
var heart3: SKSpriteNode!
var playAgain: SKSpriteNode!
var autoPlayButton: SKSpriteNode!
var blockSet: SKNode!
var antiBlockSet: SKNode!
var uncaughtSet: SKNode!
var randomly = 0


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
var gravityValue: CGFloat = 1.5
var scoreCounter: Int = 30
var autoPlay: Bool = false
var blockHasSpawned: Bool!
var antiBlockHasSpawned: Bool!
var location: CGPoint!

//Testing Variables
var shouldBeTrue = false
var groundTouchCount = 0
var lostLife1 = false
var lostLife2 = false
var lostLife3 = false

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

// Function to setup the game scene
class GameScene: SKScene, SKPhysicsContactDelegate {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = UIColor.blackColor()
        self.physicsWorld.gravity = CGVectorMake(0.0, -gravityValue)
        self.physicsWorld.contactDelegate = self
        
        setupBackground()
        setupGround()
        setupBox()
        setupScore()
        setupHighScore()
        setupHeart1()
        setupHeart2()
        setupHeart3()
        setupLives()
        setupAutoPlayButton()
        setupBlocks()
        
        blockSet = SKNode()
        self.addChild(blockSet)
        antiBlockSet = SKNode()
        self.addChild(antiBlockSet)
        uncaughtSet = SKNode()
        self.addChild(uncaughtSet)
        
    }

    
    // Tests
    
    func testThatBlockisDead() -> Bool{
        shouldBeTrue = false
        if blockHasSpawned != nil{
            if blockSet.children.first?.name == "DeadBlock" && blockSet.children.first?.frame.minY <= ground.frame.height + 5{
                shouldBeTrue = true
                println( "Pass: Dead Block is on Ground")
            } else if blockSet.children.first?.name == "DeadBlock" && blockSet.children.first?.frame.minY > ground.frame.height + 5{
                shouldBeTrue = false
                println(blockSet.children.first?.frame.minY)
                println( "Fail: Dead Block is not on Ground")
            } else if blockSet.children.first?.name != "DeadBlock" && blockSet.children.first?.frame.minY > ground.frame.height + 5 {
                shouldBeTrue = true
                println("Pass: Live block is not on the Ground")
            } else {
                shouldBeTrue = false
                println("Fail: Live block is on the Ground")
            }
        }
        return shouldBeTrue
    }
    
    func testThatBlockGeneratesWithinFrame() -> Bool{
        shouldBeTrue = false
        if blockHasSpawned != nil{
            if blockSet.children.last?.position.x > self.frame.minX && blockSet.children.last?.position.x < self.frame.maxX {
                shouldBeTrue = true
                println("Pass: Block is generated within the frame")
            } else {
                shouldBeTrue = false
                println("Fail: Block is not within the frame")
            }
        }
        return shouldBeTrue
    }

    func testThat30BlocksIsGameOver() -> Bool{
        shouldBeTrue = false
        if blockHasSpawned != nil{
            if groundTouchCount == 30 && gameLose == true {
                shouldBeTrue = true
                println("Pass: Thirty blocks hit and game is over")
            } else if groundTouchCount == 30 && gameLose == false {
                shouldBeTrue = false
                println("Fail: Thirty blocks hit and game is not over")
            } else if groundTouchCount < 30 && gameLose == true {
                shouldBeTrue = false
                println("Fail: Less than thirty blocks hit and game is over")
            } else if groundTouchCount < 30 && gameLose == false {
                shouldBeTrue = true
                println("Pass: Less than thirty blocks hit and game is not over")
            } else {
                // game is not over
            }
        
        }
        return shouldBeTrue
    }
    
    func testThat10BlocksIsLoseLife() -> Bool{
        shouldBeTrue = false
        if blockHasSpawned != nil{
            if blockSet.children.first?.name == "DeadBlock"{
            }
            if groundTouchCount >= 30 && lostLife1{
                shouldBeTrue = true
                println("Pass: 30 blocks hit ground. Lost respective live")
            } else if groundTouchCount >= 20 && lostLife2{
                shouldBeTrue = true
                println("Pass: 20 blocks hit ground. Lost respective live")
            } else if groundTouchCount >= 10 && lostLife3{
                shouldBeTrue = true
                println("Pass: 10 blocks hit ground. Lost respective live")
            }
                
            else if groundTouchCount >= 30 && !lostLife1{
                shouldBeTrue = false
                println("Fail: 30 blocks hit ground. Did not lose respective live")
            } else if groundTouchCount >= 20 && !lostLife2{
                shouldBeTrue = false
                println("Fail: 20 blocks hit ground. Did not lose respective live")
            } else if groundTouchCount >= 10 && !lostLife3{
                shouldBeTrue = false
                println("Fail: 10 blocks hit ground. Did not lose respective live")
            }
                
            else if groundTouchCount < 30 && lostLife1{
                shouldBeTrue = false
                println("Fail: 30 blocks did not hit ground. Lost respective live")
            } else if groundTouchCount < 20 && lostLife2{
                shouldBeTrue = false
                println("Fail: 20 blocks hit did not ground. Lost respective live")
            } else if groundTouchCount < 10 && lostLife3{
                shouldBeTrue = false
                println("Fail: 10 blocks hit did not ground. Lost respective live")
                
            }
            else if groundTouchCount < 10 && !lostLife1{
                shouldBeTrue = true
                println("Pass: 10 blocks did not hit ground. Did not lose respective live")
            } else if groundTouchCount < 20 && !lostLife2{
                shouldBeTrue = true
                println("Pass: 20 blocks hit did not ground. Did not lose respective live")
            } else if groundTouchCount < 30 && !lostLife3{
                shouldBeTrue = true
                println("Pass: 30 blocks hit did not ground. Did not lose respective live")
            }
            
        }
        return shouldBeTrue
    }
   
    func testThatHighScoreisMax() -> Bool{
        shouldBeTrue = false
        if blockHasSpawned != nil{
            if highScore >= score {
                shouldBeTrue = true
                println("Pass: High score is greater or equal to current score")
            } else {
                println("Fail: High score is not so high.")
            }
            
        }
        return shouldBeTrue
    }
    
    func testThatBoxMovesToTouch() -> Bool{
        shouldBeTrue = false
        if location.x == box.position.x {
            println("Pass: Box moves to finger")
    
        }
        return shouldBeTrue
    }
    
//    func testThatCaughtBlockIncrementsScore() -> Bool{
//        shouldBeTrue = false
//        if blockHasSpawned != nil{
//            if blockSet.children.first?.name == "CaughtBlock" {
//                println("Score should increment")
//            }
//            
//        }
//        return shouldBeTrue
//    }
    
    

    
    func testThat() -> Bool{
        shouldBeTrue = false
        if blockHasSpawned != nil{
            
        }
        return shouldBeTrue
    }
    
    /*
    func moveBlockToSet(){
        if blockSet.children.first != nil && blockSet.children.first?.position.y < self.frame.height / 5 {
            blockSet.childNodeWithName("LiveBlock")?.name = "UncaughtBlock"
        }
    }
    */
    // Random generation function used for AntiBlocks

    func runRandomly(){
        randomly = Int(arc4random_uniform(100))
    }
    
    // Create the background Sprite Node
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPointMake(self.frame.width / 2, self.frame.height / 2)
        background.size = CGSizeMake(self.frame.width, self.frame.height)
        background.zPosition = -100
        self.addChild(background)
    }
    
    // Create the blocks Sprite Node
    func setupBlocks() {
        
        let spawn = SKAction.runBlock { () -> Void in
            self.spawnBlocks()
        }
        
        let delay = SKAction.waitForDuration(0.7)
        
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        
        self.runAction(spawnThenDelayForever)
        
    }
    
    // Create the AntiBlocks Sprite Node
    func setupAntiBlocks() {
        let spawn = SKAction.runBlock { () -> Void in
            self.spawnAntiBlocks()
        }
        
        let delay = SKAction.waitForDuration(0.7)
        
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        
        self.runAction(spawnThenDelayForever)
    }

    // Increase the gravity with caught blocks
    func IncreaseSpawnRate(){
        if scoreCounter == 0 {
            gravityValue = gravityValue + 0.1
            scoreCounter = 30
        }
    }
    
    // Spawn Blocks
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

        block.name = "LiveBlock"
        block.physicsBody?.restitution = 0.01
//        self.addChild(block)
        blockSet.addChild(block)
//        accessBlocks()
        blockHasSpawned = true
    }
    
    // Spawn the AntiBlocks
    func spawnAntiBlocks() {
        if randomly == 1 {
        antiBlock = SKSpriteNode(imageNamed: "antiBlock")
        antiBlock.size = CGSizeMake((antiBlock.size.width / 2), (antiBlock.size.height / 2))
        do {
            columnMultiplier = (CGFloat(arc4random_uniform(100))) / 100
        } while(columnMultiplier <= 0.3 || columnMultiplier >= 0.7)
        
        antiBlock.position = CGPointMake((columnMultiplier * self.frame.width), (self.frame.height + antiBlock.size.height))
        antiBlock.physicsBody = SKPhysicsBody(rectangleOfSize: antiBlock.size)
        
        antiBlock.physicsBody?.categoryBitMask = blockCategory
        antiBlock.physicsBody?.contactTestBitMask = boxCategory | worldCategory
        antiBlock.name = "LiveAntiBlock"
        antiBlock.physicsBody?.restitution = 0.01
        antiBlockSet.addChild(antiBlock)
        antiBlockHasSpawned = true
        }
    }
    
    // Create the ground Sprite Node
    func setupGround() {
        ground = SKSpriteNode(imageNamed: "ground")
        ground.size = CGSizeMake(self.frame.width, ground.frame.height / 2)
        ground.position = CGPointMake(self.frame.width / 2, 10)
        ground.zPosition = -9
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.dynamic = false
        
        ground.physicsBody?.categoryBitMask = worldCategory
        ground.physicsBody?.contactTestBitMask = blockCategory
        ground.physicsBody?.collisionBitMask = blockCategory
        
        self.addChild(ground)
    }
    
    // Create the box Sprite Node
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
    
    // Game automation and Testing Suite
    func autoMoveBox() {
        if autoPlay && blockHasSpawned != nil {
            // human error addition
            var randomly = (Int(arc4random_uniform(20)))
            var blockPosition = block.position.x
            if randomly == 1 {
                let moveDelay = SKAction.waitForDuration(1.8)
                let move = SKAction.moveToX(blockPosition, duration: 0.1)
                let moveDelayThenGo = SKAction.sequence([moveDelay,move])
                box.runAction(moveDelayThenGo)

            }
//            Run Tests
            testThatBlockisDead()
            testThatBlockGeneratesWithinFrame()
            testThat30BlocksIsGameOver()
            testThat10BlocksIsLoseLife()
            testThatHighScoreisMax()
            testThatBoxMovesToTouch()

        }
    }

    // Create Play Again Button 
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
    
    // Create Automation Button
    func setupAutoPlayButton() {
        autoPlayButton = SKSpriteNode(imageNamed: "autoPlay")
        autoPlayButton.size = CGSizeMake(autoPlayButton.size.width, autoPlayButton.size.height)
        autoPlayButton.position = CGPointMake(self.frame.width / 1.5, self.frame.height / 9)
        autoPlayButton.zPosition = -50

        autoPlayButton.name = "autoPlayButton"
        
        self.addChild(autoPlayButton)
    }

    // Create Score label
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
    
    // Create High Score Label
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
    
    // Function for updating the high score
    func updateHighScore() {
        if highScore <= score {
            highScore = score
            highScoreLabel.text = String(highScore)
        }
    }
    
    // Create Lives Counter
    func setupLives(){
        lives = 30
    }
    
    // Switch function for removing lives
    func updateLives(){
        switch lives {
        case 20:
            heart3.removeFromParent()
            lostLife3 = true
        case 10:
            heart2.removeFromParent()
            lostLife2 = true
        case 0:
            heart1.removeFromParent()
            gameLose = true
            lostLife1 = true
            setupPlayAgain()
        default:
            break
        }
//            println(lives)
        
    }
    
    // Create Lives "Hearts" Sprite Nodes
    func setupHeart1() {
        heart1 = SKSpriteNode(imageNamed: "life")
        heart1.size = CGSizeMake(heart1.size.width / 2, heart1.size.height / 2)
        heart1.position = CGPointMake(self.frame.width / 3, self.frame.height / 1.07)
        heart1.name = "heart1"
        self.addChild(heart1)
    }
    
    func setupHeart2() {
        heart2 = SKSpriteNode(imageNamed: "life")
        heart2.size = CGSizeMake(heart2.size.width / 2, heart2.size.height / 2)
        heart2.position = CGPointMake(self.frame.width / 2.7, self.frame.height / 1.07)
        heart2.name = "heart2"
        self.addChild(heart2)
    }
    
    func setupHeart3() {
        heart3 = SKSpriteNode(imageNamed: "life")
        heart3.size = CGSizeMake(heart3.size.width / 2, heart3.size.height / 2)
        heart3.position = CGPointMake(self.frame.width / 2.45, self.frame.height / 1.07)
        heart3.name = "heart3"
        self.addChild(heart3)
    }
    
    // Reset the game after loss
    func resetScene() {
        // Reposition Box
        box.position = CGPointMake((self.frame.width / 2 ), self.frame.height / 5)
        
        // Clear blocks
        blockSet.removeAllChildren()
        antiBlockSet.removeAllChildren()
        playAgain.removeFromParent()
        
        // Reset World
        gravityValue = 1.5
        autoPlay = false
        
        
        
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
    
    // Function to handle object contact
    func didBeginContact(contact: SKPhysicsContact) {
        if (( contact.bodyA.categoryBitMask & boxCategory ) == boxCategory || ( contact.bodyB.categoryBitMask & boxCategory ) == boxCategory)
            && (contact.bodyB.node?.frame.origin.y > contact.bodyA.node?.frame.minY && contact.bodyB.node?.frame.origin.y < contact.bodyA.node?.frame.maxY)
            && (contact.bodyB.node?.frame.origin.x > contact.bodyA.node?.frame.minX && contact.bodyB.node?.frame.origin.x < contact.bodyA.node?.frame.maxX) {
                
                
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
                    contact.bodyB.node?.name = "CaughtBlock"

                } else if ((contact.bodyB.node?.name == "LiveAntiBlock") && (gameLose == false)) {
                    score = score - 1
                    scoreLabel.text = String(score)
                    updateHighScore()
                    scoreCounter = scoreCounter - 1
                    contact.bodyB.node?.name = "CaughtBlock"
                }

                contact.bodyB.node?.runAction(fadeThenDelete)
        } else if (contact.bodyA.categoryBitMask & worldCategory) == worldCategory || (contact.bodyB.categoryBitMask & worldCategory) == worldCategory {
            
            let delay = SKAction.waitForDuration(3)
            let colorChange = SKAction.colorizeWithColor(UIColor(rgb: 0x222222), colorBlendFactor: 1.0, duration: 0.5)
            
            let deleteBlock = SKAction.removeFromParent()
            let fadeAway = SKAction.fadeOutWithDuration(0.25)
            let delayThenFade = SKAction.sequence([delay,fadeAway])
            let colorFadeThenDelete = SKAction.sequence([colorChange,delayThenFade, deleteBlock])
            
            if contact.bodyB.node?.name == "LiveBlock" {
                lives = lives - 1
                updateLives()
                groundTouchCount++
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
    
    // Functions to handle touches
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        
        for touch: AnyObject in touches {
            location = touch.locationInNode(self) as CGPoint
            var node: SKNode = self.nodeAtPoint(location)
            
            let time = NSTimeInterval(abs(location.x - box.position.x) * 0.0009)
            
            if (node.name == "autoPlayButton"){
                if autoPlay == false {
                    autoPlay = true
                    println(autoPlay)
                } else {
                    autoPlay = false
                    println(autoPlay)
                }
            }
            
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
    
    // Function to update frame methods
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        self.physicsWorld.gravity = CGVectorMake(0.0, -gravityValue)
        autoMoveBox()
        runRandomly()
        spawnAntiBlocks()
//        testThatCaughtBlockIncrementsScore()
        //moveBlockToSet()
        
    }
}
