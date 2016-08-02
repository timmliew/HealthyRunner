//
//  GameScene.swift
//  StayFit
//
//  Created by Timothy Liew on 6/29/16.
//  Copyright (c) 2016 Tim Liew. All rights reserved.
//

import SpriteKit
import AudioToolbox

enum GameState {
    case Active, GameOver, Pause
}

enum Size {
    case Fat, Skinny
}

class GameScene: SKScene, SKPhysicsContactDelegate  {
    
    let fixedDelta: CFTimeInterval = 1.0/60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 160
    var scrollLayer: SKNode!
    var scrollCloud: SKNode!
    var obstacleLayer: SKNode!
    var timer: CFTimeInterval = 0
    var spawnTimer: CFTimeInterval = 0
    var foodTimer: CFTimeInterval = 0
    var coinTimer: CFTimeInterval = 0
    var secondBeeTimer: CFTimeInterval = 0
    var carrotTimer: CFTimeInterval = 0
    var touchCounter = 0
    var wallpaper: SKNode!
    var gameState: GameState = .Active
    var hero: SKSpriteNode!
    var hero2: SKSpriteNode!
    var evilBee: SKSpriteNode!
    var replayButton: MSButtonNode!
    var pauseButton: MSButtonNode!
    var continueButton: MSButtonNode!
    var homeButton: MSButtonNode!
    var sizeState: Size!
    var heroScale: CGFloat!
    var level = 0
    var pointsLabel: SKLabelNode!
    var points: Int = 0
    var bestLabel: SKLabelNode!
    var mass: CGFloat!
    var font: UIFont!
    var swipeBegins: CGPoint!
    var swipeEnds: CGPoint!
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        font = UIFont(name: "Noteworthy", size: 26)
        scrollLayer = self.childNodeWithName("scrollLayer")
        obstacleLayer = self.childNodeWithName("obstacleLayer")
        scrollCloud = self.childNodeWithName("scrollCloud")
        wallpaper = self.childNodeWithName("wallpaper")
        hero = self.childNodeWithName("//bunny") as! SKSpriteNode
        hero2 = self.childNodeWithName("//bunnySprite") as! SKSpriteNode
        evilBee = self.childNodeWithName("evilBee") as! SKSpriteNode
        replayButton = self.childNodeWithName("replayButton1") as! MSButtonNode
        pauseButton = self.childNodeWithName("pause") as! MSButtonNode
        continueButton = self.childNodeWithName("continueButton") as! MSButtonNode
        homeButton = self.childNodeWithName("homeButton") as! MSButtonNode
        pointsLabel = self.childNodeWithName("pointsLabel") as! SKLabelNode
        heroScale = hero.xScale
        pointsLabel.text = String(points)
        bestLabel = self.childNodeWithName("bestLabel") as! SKLabelNode
        bestLabel.text = String(NSUserDefaults.standardUserDefaults().integerForKey("bestLabel"))
        mass = hero.physicsBody?.mass
        
        self.replayButton.hidden = true
        self.continueButton.hidden = true
        self.replayButton.hidden = true
        self.homeButton.hidden = true
        self.pauseButton.hidden = false
        
        if heroScale == hero.xScale {
            sizeState = .Skinny
        }
        
        homeButton.selectedHandler = {
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load game scene */
            let scene = MainScene(fileNamed: "MainScene") as MainScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFit
            
            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = true
            skView.showsFPS = false
            
            /* Restart game scene */
            skView.presentScene(scene)
        }
        
        /* Setup restart button selection handler */
        replayButton.selectedHandler = {
            
            /* Grab reference to our SpriteKit view */
            let skView = self.view as SKView!
            
            /* Load game scene */
            let scene = GameScene(fileNamed: "GameScene") as GameScene!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFit
            
            /* Show debug */
            skView.showsPhysics = false
            skView.showsDrawCount = true
            skView.showsFPS = false
            
            /* Restart game scene */
            skView.presentScene(scene)
        }
        
        pauseButton.selectedHandler = {
            self.pauseButton.hidden = true
            self.continueButton.hidden = false
            self.replayButton.hidden = false
            self.homeButton.hidden = false
            self.gameState = .Pause
            self.paused = true
            self.physicsWorld.speed = 0
        }
        
        continueButton.selectedHandler = {
            self.gameState = .Active
            self.pauseButton.hidden = false
            self.homeButton.hidden = true
            self.replayButton.hidden = true
            self.continueButton.hidden = true
            self.paused = false
            self.physicsWorld.speed = 1
        }
        
        let colorChange = SKAction.colorizeWithColor(.blueColor(), colorBlendFactor: 1, duration: 5)
        let colorChange1 = SKAction.colorizeWithColor(.orangeColor(), colorBlendFactor: 1, duration: 5)
        let colorChange2 = SKAction.colorizeWithColor(.grayColor(), colorBlendFactor: 1, duration: 5)
        let action = SKAction.repeatActionForever(SKAction.sequence([colorChange, colorChange1, colorChange2]))
        wallpaper.runAction(action)
        
        
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        
        let swipeRight:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.respondToSwipe(_:)))
        swipeRight.direction = .Right
        view.addGestureRecognizer(swipeRight)
        
        
        let swipeLeft:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.respondToSwipe(_:)))
        swipeLeft.direction = .Left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeUp:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(GameScene.respondToSwipe(_:)))
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)


    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch ended */
        
        touchCounter += 1
        
        if touchCounter <= 2 {
            hero2.runAction(SKAction(named: "jump")!)
            
            /* Reset velocity, helps improve response against cumulative falling velocity */
            hero.physicsBody?.velocity = CGVectorMake(0, 0)
            
            /* Called when a touch begins */
            
            /* Apply vertical impulse */
            hero.physicsBody?.applyImpulse(CGVectorMake(0, 600))
            
         //   hero.physicsBody?.velocity = CGVector(dx: hero.physicsBody!.velocity.dx, dy: 5000.0)
            
            
            /* Apply subtle rotation */
            hero.physicsBody?.applyAngularImpulse(1)
        }
    }

   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if hero.position.x >= 200 {
            hero.position.x = 200
        }
        
        if hero.position.y < 40 || hero.position.x < -self.size.width {
            gameOver()
        }
        
        if sizeState == .Fat {
            hero.physicsBody?.applyForce(CGVector(dx: -25, dy: 0))
        }
        
        if hero.xScale <= heroScale {
            hero.xScale = heroScale
            sizeState = .Skinny
        }
        
        /* Grab current velocity */
        let velocityY = hero.physicsBody?.velocity.dy ?? 0
        
        /* Check and cap vertical velocity */
        if velocityY > 600 {
            hero.physicsBody?.velocity.dy = 550
        }
        
        /* Called before each frame is rendered */
        scrollWorld()
        updateObstacles()
        
        timer += fixedDelta
        
        secondBeeTimer += fixedDelta
        
        carrotTimer += fixedDelta
        
        coinTimer += fixedDelta
        
        foodTimer += fixedDelta
        
        spawnTimer += fixedDelta
    }
    
    func scrollWorld(){
        scrollLayer.position.x -= (scrollSpeed + CGFloat(points / 6)) * CGFloat(fixedDelta)
        
        if scrollLayer.position.x < size.width * CGFloat(level + 1) * -5.0 {
            if timer >= 5.0 {
                level += 1
                timer = 0
            }
            
            for child in scrollLayer.children {
                if child.name == "background" {
                    child.name = "backgroundOld"
                }
            }
            
            let resourcePath = NSBundle.mainBundle().pathForResource("Level\((level % 3) + 1)", ofType: "sks")
            print(level)
            let levelFirst = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath!))
            
            let offset = self.convertPoint(CGPoint(x: self.size.width * 1.5 + 40, y: 0), toNode: scrollLayer).x
            for child in levelFirst.children[0].children {
                child.removeFromParent()
                child.position.x += offset
                scrollLayer.addChild(child)
            }
        }
        
        /* Loop through scroll layer nodes*/
        for ground in scrollLayer.children {
            
            if ground.name == "background" {
                
                let groundSprite = ground as! SKSpriteNode
                
                /* Get ground node position, convert node position to scene space*/
                let groundPosition = scrollLayer.convertPoint(ground.position, toNode: self)
                
                /* Check if ground sprite has left the scene */
                if groundPosition.x <= -groundSprite.size.width / 2 {
                    
                    /* Reposition ground sprite to the second starting position */
                    ground.position.x += size.width * 1.5
                }
                
            } else if ground.name == "backgroundOld" {
                let groundSprite = ground as! SKSpriteNode
                
                /* Get ground node position, convert node position to scene space*/
                let groundPosition = scrollLayer.convertPoint(ground.position, toNode: self)
                
                /* Check if ground sprite has left the scene */
                if groundPosition.x <= -groundSprite.size.width / 2 {
                    
                    /* Reposition ground sprite to the second starting position */
                    ground.removeFromParent()
                }
            }
        }
        
        /* Scroll Cloud */
        scrollCloud.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        /* Loop through scroll layer nodes*/
        for cloud in scrollCloud.children as! [SKSpriteNode]{
            
            /* Get ground node position, convert node position to scene space*/
            let cloudPosition = scrollCloud.convertPoint(cloud.position, toNode: self)
            
            /* Check if ground sprite has left the scene */
            if cloudPosition.x <= -cloud.size.width / 2 {
                
                /* Reposition ground sprite to the second starting position */
                let newPosition = CGPointMake((self.size.width / 2) + self.size.width, cloudPosition.y)
                
                /* Convert new node position back to scroll layer space */
                cloud.position = self.convertPoint(newPosition, toNode: scrollCloud)
            }
        }
        
    }

    
    func updateObstacles(){
        
        obstacleLayer.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        for obstacle1 in obstacleLayer.children as! [SKReferenceNode] {
            let obstacle1Position = obstacleLayer.convertPoint(obstacle1.position, toNode: self)
            
            if obstacle1Position.x <= -size.width {
                obstacle1.removeFromParent()
            }
        }
        

        /* Loop through obstacle layer nodes */
        for obstacle in obstacleLayer.children as! [SKReferenceNode]{
            
            /* Get obstacle node position, convert node position to scene space */
            let obstaclePosition = obstacleLayer.convertPoint(obstacle.position, toNode: self)
            
            /* Check if the bunny has left the scene */
            if obstaclePosition.x <= 0 {
                
                /* Remove obstacle node from obstacle layer */
                obstacle.removeFromParent()
            }
        }
        
        if foodTimer >= 4.0 {
            
            let resourcePath = NSBundle.mainBundle().pathForResource("Fries", ofType: "sks")
            let fries = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath!))
            scrollLayer.addChild(fries)
            
            /* Generate new obstacle position for water */
            let randomPosition = CGPointMake(CGFloat.random(min: self.size.width + (self.size.width / 2), max: self.size.width * 2), 500)
            fries.position = self.convertPoint(randomPosition, toNode: scrollLayer)
            
            foodTimer = 0
        }
        
        if carrotTimer >= 2.0 {
            
            let topRight = CGPointMake(self.size.width, self.size.height)
            let bottomRight = CGPointMake(self.size.width, 0)
            
            let collision = self.physicsWorld.bodyAlongRayStart(topRight, end: bottomRight)
            
            if let collisionNode = collision?.node {
                
                let resourcePath = NSBundle.mainBundle().pathForResource("Carrot", ofType: "sks")
                let carrot = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath!))
                scrollLayer.addChild(carrot)
                /* Convert new node position back to obstacle layer space */
                
                carrot.position.x = self.convertPoint(topRight, toNode: scrollLayer).x + 30
                carrot.position.y = collisionNode.convertPoint(CGPoint(x: 0, y: 0), toNode: scrollLayer).y + 50
            }
            carrotTimer = 0
        }
        
        if coinTimer >= 3.0 {
            
            let topRight = CGPointMake(self.size.width, self.size.height)
            let bottomRight = CGPointMake(self.size.width, 0)
            
            let collision = self.physicsWorld.bodyAlongRayStart(topRight, end: bottomRight)
            
            if let collisionNode = collision?.node {
                let coins = SKSpriteNode(imageNamed: "coin_gold")
                coins.name = "coins"
                let coin = SKPhysicsBody (texture: coins.texture!, size: coins.size)
                coins.physicsBody = coin
                coins.physicsBody!.affectedByGravity = true
                coins.physicsBody!.allowsRotation = false
                coins.physicsBody!.categoryBitMask = 4
                coins.physicsBody!.collisionBitMask = 2
                coins.physicsBody!.contactTestBitMask = 1
                coins.physicsBody!.linearDamping = 10
                coins.size = CGSize(width: 55,height: 55)
                scrollLayer.addChild(coins)
                
                /* Convert new node position back to obstacle layer space */
                coins.position.x = self.convertPoint(topRight, toNode: scrollLayer).x + 30
                coins.position.y = collisionNode.convertPoint(CGPoint(x: 0, y: 0), toNode: scrollLayer).y + 50
            }
            
            coinTimer = 0
        }
        if points >= 70 {
            if points % 10 == 2 {
                if secondBeeTimer > 5.0 {
                    let secondBee = SKSpriteNode(imageNamed: "evilBee")
                    secondBee.name = "secondBee"
                    let secBee = SKPhysicsBody(circleOfRadius: secondBee.size.width * 0.5)
                    secondBee.zPosition = 1
                    secondBee.physicsBody = secBee
                    secondBee.physicsBody!.dynamic = false
                    secondBee.physicsBody!.affectedByGravity = false
                    secondBee.physicsBody!.categoryBitMask = 16
                    secondBee.physicsBody!.collisionBitMask = 0
                    secondBee.physicsBody!.contactTestBitMask = 1
                    secondBee.setScale(0.5)
                    secondBee.position = self.convertPoint(CGPoint(x: self.size.width * 2, y: 180), toNode: scrollLayer)
                    
                    scrollLayer.addChild(secondBee)
                    
                    secondBee.runAction(SKAction.repeatActionForever(SKAction(named: "fly")!))
                    
                    secondBeeTimer = 0
                    
                }
            }
        }
        
        /* Time to add new obstacle */
        if hero.position.x >= self.size.width / 2{
            
            if spawnTimer >= 0.5 {
            
                let topRight = CGPointMake(self.size.width, self.size.height)
                let bottomRight = CGPointMake(self.size.width, 0)
                
                let collision = self.physicsWorld.bodyAlongRayStart(topRight, end: bottomRight)
                
                if let collisionNode = collision?.node {
                    
                    if collisionNode.name!.hasPrefix("background") {
                    
                        let resourcePath = NSBundle.mainBundle().pathForResource("Obstacles", ofType: "sks")
                        let newObstacle = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath!))
                        scrollLayer.addChild(newObstacle)
                        /* Convert new node position back to obstacle layer space */
                        
                        newObstacle.position.x = self.convertPoint(topRight, toNode: scrollLayer).x
                        newObstacle.position.y = collisionNode.convertPoint(CGPoint(x: 0, y: 0), toNode: scrollLayer).y + 50
                    }
                }
                
                let topRight2 = CGPointMake(self.size.width, self.size.height)
                let bottomRight2 = CGPointMake(self.size.width, 0)
                let collision2 = self.physicsWorld.bodyAlongRayStart(topRight2, end: bottomRight)
                
                if let collisionNode2 = collision2?.node {
                    
                    if collisionNode2.name!.hasPrefix("background") {
                        
                        let resourcePath2 = NSBundle.mainBundle().pathForResource("Grass", ofType: "sks")
                        let grass = SKReferenceNode (URL: NSURL (fileURLWithPath: resourcePath2!))
                        scrollLayer.addChild(grass)
                        /* Convert new node position back to obstacle layer space */
                        
                        grass.position.x = self.convertPoint(topRight2, toNode: scrollLayer).x
                        grass.position.y = collisionNode2.convertPoint(CGPoint(x: 0, y: 0), toNode: scrollLayer).y + 50
                    }
                }
            
            }
            /* Reset spawn timer */
            spawnTimer = 0
        }
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        let contactA: SKPhysicsBody = contact.bodyA
        let contactB: SKPhysicsBody = contact.bodyB
        
        guard let nodeA = contactA.node, nodeB = contactB.node else {
            return
        }
  
        //carrot disappears when it touches bunny
        if (nodeA.name == "bunny" && nodeB.name == "carrot") || (nodeA.name == "carrot" && nodeB.name == "bunny")  {
            hero.physicsBody!.velocity.dx = (scrollSpeed / 2)
            if hero.physicsBody?.mass <= mass {
                hero.physicsBody?.mass = mass
            } else {
                hero.physicsBody?.mass -= ((hero.physicsBody?.mass)! / 4)
            }
            if gameState != .GameOver {
                points += 1
                pointsLabel.text = String(points)
                let scoreLabel = SKLabelNode(fontNamed: font.fontName)
                scoreLabel.fontSize = 26
                scoreLabel.color = SKColor.blackColor()
                scoreLabel.position = hero.convertPoint(CGPoint(x:0, y: 10), toNode: scrollLayer)
                scrollLayer.addChild(scoreLabel)
                scoreLabel.text = "+1"
                scoreLabel.runAction(SKAction.fadeOutWithDuration(1))
                scoreLabel.runAction(SKAction.sequence([
                    SKAction.moveByX(0, y: 30, duration: 1),
                    SKAction.removeFromParent()
                    ]))
                
                if points > Int(bestLabel.text!) {
                    bestLabel.text = String(points)
                }
                
                if points > NSUserDefaults.standardUserDefaults().integerForKey("bestLabel") {
                    NSUserDefaults.standardUserDefaults().setInteger(points, forKey: "bestLabel")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                
                bestLabel.text = String(NSUserDefaults.standardUserDefaults().integerForKey("bestLabel"))
            }
            
            if sizeState != .Skinny {
                hero.xScale -= heroScale
            }
            if nodeA.name == "carrot" {
                nodeA.removeFromParent()
            } else {
                nodeB.removeFromParent()
            }
            
        }
       
        //coins disappears when it touches bunny
        if (nodeA.name == "bunny" && nodeB.name == "coins") || (nodeA.name == "coins" && nodeB.name == "bunny") {
            if gameState != .GameOver {
                points += 2
                pointsLabel.text = String(points)
                let scoreLabel = SKLabelNode(fontNamed: font.fontName)
                scoreLabel.fontSize = 26
                scoreLabel.color = SKColor.blackColor()
                scoreLabel.position = hero.convertPoint(CGPoint(x:0, y: 10), toNode: scrollLayer)
                scrollLayer.addChild(scoreLabel)
                scoreLabel.text = "+2"
                scoreLabel.runAction(SKAction.fadeOutWithDuration(1))
                scoreLabel.runAction(SKAction.sequence([
                    SKAction.moveByX(0, y: 30, duration: 1),
                    SKAction.removeFromParent()
                    ]))
                
                if points > Int(bestLabel.text!) {
                    bestLabel.text = String(points)
                }
                
                if points > NSUserDefaults.standardUserDefaults().integerForKey("bestLabel") {
                    NSUserDefaults.standardUserDefaults().setInteger(points, forKey: "bestLabel")
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
                
                bestLabel.text = String(NSUserDefaults.standardUserDefaults().integerForKey("bestLabel"))
            }
            
            if nodeA.name == "coins" {
                nodeA.removeFromParent()
            } else {
                nodeB.removeFromParent()
            }
        }
        
        if (nodeA.name == "bunny" && nodeB.name == "evilBee") || (nodeA.name == "evilBee" && nodeB.name == "bunny") {
            hero2.runAction(SKAction(named: "hurt")!)
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            death()
            hero2.runAction(SKAction(named: "hurt")!)
            
        }
        
        if (nodeA.name == "bunny" && nodeB.name == "secondBee") || (nodeA.name == "secondBee" && nodeB.name == "bunny") {
            hero2.runAction(SKAction(named: "hurt")!)
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            death()
            hero2.runAction(SKAction(named: "hurt")!)
            
        }
        
        //fries disappears when it touches bunny
        if (nodeA.name == "bunny" && nodeB.name == "fries") || (nodeA.name == "fries" && nodeB.name == "bunny") {
            hero.runAction(SKAction(named: "hurt")!)
            hero.xScale += heroScale / 4
            sizeState = .Fat
            hero.physicsBody?.mass += ((hero.physicsBody?.mass)! / 4)
            if nodeA.name == "fries" {
                nodeA.removeFromParent()
            } else {
                nodeB.removeFromParent()
            }
            
        }
        
        if (nodeA.name == "bunny" && nodeB.name!.hasPrefix("background")) {
            if nodeA.position.y > nodeB.position.y {
                touchCounter = 0
            }
        } else if (nodeA.name!.hasPrefix("background") && nodeB.name == "bunny") {
            if nodeB.position.y > nodeA.position.y {
                touchCounter = 0
            }
        }

        
        if (nodeA.name == "bunny" && nodeB.name == "obstacle") || (nodeA.name == "obstacle" && nodeB.name == "bunny") {
            touchCounter = 0
        }
        
    }
    
    func death() {
        let heroDeath = SKAction.runBlock({
            
            /* Put our hero face down in the dirt */
            self.hero.physicsBody?.applyImpulse(CGVectorMake(0, 40))
            
            /* Put our hero face down in the dirt */
            self.hero.zRotation = CGFloat(-180).degreesToRadians()
            
            /* Stop hero from colliding with anything else */
            self.hero.physicsBody?.collisionBitMask = 0
            self.hero.physicsBody?.contactTestBitMask = 0
            self.touchCounter = 5
            
        })
        
        hero2.runAction(heroDeath)
    }
    
    func respondToSwipe(sender: UISwipeGestureRecognizer) {
        if let swipeGesture = sender as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Left:
                hero.physicsBody!.velocity.dx = -(scrollSpeed * 1)
                
            case UISwipeGestureRecognizerDirection.Right:
                hero.physicsBody!.velocity.dx = (scrollSpeed * 1)

            default:
                break
            }
        }
    }
    
    
    func gameOver() {
        gameState = .GameOver
        homeButton.hidden = false
        replayButton.hidden = false
        pauseButton.hidden = true
        self.paused = true
    }
    
}