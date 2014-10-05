//
//  GameScene.swift
//  BlockBox
//
//  Created by Bryce Daniel on 10/3/14.
//  Copyright (c) 2014 Bryce Daniel. All rights reserved.
//

import SpriteKit

// Object Variable
var block: SKSpriteNode!
var box: SKSpriteNode!
var scoreLabel: SKLabelNode!

// Random Variable
var columnMultiplier: CGFloat!

// Touch Object
var currentNodeTouched: SKNode!

// GameState Variables
var score = NSInteger()
var lives = NSInteger()
var gameWin: Bool!
var gameLose: Bool!

//Contact Categories
let blockCategory: UInt32 = 1 << 0
let worldCategory: UInt32 = 1 << 1
let boxCategory: UInt32 = 1 << 2

class GameScene: SKScene, SKPhysicsContactDelegate {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        self.backgroundColor = UIColor.blackColor()
        self.physicsWorld.gravity = CGVectorMake(0.0, -2)
        self.physicsWorld.contactDelegate = self
        setupBackground()
        setupBlocks()
        setupGround()
        setupBox()
        updateScore()
        
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
        
        let delay = SKAction.waitForDuration(0.5)
        
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        
        self.runAction(spawnThenDelayForever)
    }
    
    func spawnBlocks() {
        block = SKSpriteNode(imageNamed: "block")
        block.size = CGSizeMake((block.size.width / 2), (block.size.height / 2))
        do {
            columnMultiplier = (CGFloat(arc4random_uniform(100))) / 100
        } while(columnMultiplier <= 0.3 || columnMultiplier >= 0.7)
        
        
        println(columnMultiplier)
        block.position = CGPointMake((columnMultiplier * self.frame.width), (self.frame.height + block.size.height))
        block.physicsBody = SKPhysicsBody(rectangleOfSize: block.size)
        
        block.physicsBody?.categoryBitMask = blockCategory
        block.physicsBody?.contactTestBitMask = boxCategory | worldCategory
        //          block.physicsBody?.collisionBitMask = worldCategory | blockCategory | boxCategory
        //            block.physicsBody?.allowsRotation = false
        block.physicsBody?.restitution = 0.01
        
        
        
        self.addChild(block)
        
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
    
    func setupBox() {
        box = SKSpriteNode(imageNamed: "box")
        box.size = CGSizeMake(box.size.width / 2, box.size.height / 2)
        box.position = CGPointMake((self.frame.width / 2 ), self.frame.height / 5)
        let boxTexture = SKTexture(imageNamed: "box")
        box.physicsBody = SKPhysicsBody(texture: boxTexture, size: box.size)
        box.physicsBody?.dynamic = false
        box.name = "box"
        
        box.physicsBody?.categoryBitMask = boxCategory
        box.physicsBody?.contactTestBitMask = blockCategory
        box.physicsBody?.collisionBitMask = blockCategory
        self.addChild(box)
    }
    
    
    func updateScore() {
        score = 0
        scoreLabel = SKLabelNode(fontNamed: "Helvetica")
        scoreLabel.fontColor = UIColor.blackColor()
        scoreLabel.fontSize = 50
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.height / 2)
        scoreLabel.text = String(score)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        if ( contact.bodyA.categoryBitMask & boxCategory ) == boxCategory || ( contact.bodyB.categoryBitMask & boxCategory ) == boxCategory {
            
            println("SCORE!")
            
//            contact.bodyB.node?.physicsBody?.contactTestBitMask = worldCategory
            let delay = SKAction.waitForDuration(0.25)
            let deleteBlock = SKAction.removeFromParent()
            let fadeAway = SKAction.fadeOutWithDuration(0.25)
            let delayThenFade = SKAction.sequence([delay,fadeAway])
            let fadeThenDelete = SKAction.sequence([delayThenFade, deleteBlock])
            
            for(var i = 0; i == 0; i++) {
                score = score + 1
                scoreLabel.text = String(score)
                println(score)
            }
            contact.bodyB.node?.runAction(fadeThenDelete)
        } else if (contact.bodyA.categoryBitMask & worldCategory) == worldCategory || (contact.bodyB.categoryBitMask & worldCategory) == worldCategory {
            
            println("dead")
            let delay = SKAction.waitForDuration(5)
            let deleteBlock = SKAction.removeFromParent()
            let fadeAway = SKAction.fadeOutWithDuration(0.25)
            let delayThenFade = SKAction.sequence([delay,fadeAway])
            let fadeThenDelete = SKAction.sequence([delayThenFade, deleteBlock])
            contact.bodyB.node?.runAction(fadeThenDelete)

        }
    
    }
    
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let time = NSTimeInterval(abs(location.x - box.position.x) * 0.001)
            
            if (location.x != box.position.x) {
                box.runAction(SKAction.moveToX(location.x, duration: time))
                
            }
        }
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let time = NSTimeInterval(abs(location.x - box.position.x) * 0.001)
            
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
    }
}
