//
//  GameScene.swift
//  GB2015
//
//  Created by Olof Rehnström on 2015-01-03.
//  Copyright (c) 2015 Olof Rehnström. All rights reserved.
//

import SpriteKit
import QuartzCore




class GameScene: SKScene {

    required init?(coder aDecoder: NSCoder) {
        
        bubbles = []
        lastTouch = CGPoint(x: 0,y: 0);
        gunPosition = CGPoint(x: 0,y: 0);
        timestamp = NSDate()
        
        //gun0 = SKSpriteNode(color: UIColor.whiteColor(), size: CGSizeMake(150, 150))
        gun0 = SKSpriteNode(imageNamed: "gun")
        //player = SKSpriteNode(color: UIColor.redColor(), size: CGSizeMake(50, 50))
        player = SKSpriteNode(imageNamed: "professor")
        
        playerGui = playerCircleLayer()

        super.init(coder: aDecoder)
        
        
        
    }

  
    
    let bubbleBitmask:UInt32 = 1;
    let monsterBitmask:UInt32 = 2;
    let playerBitmask:UInt32 = 3;
    let wallBitmask:UInt32 = 4;
    
    let ghostsFiles = ["ghost_1", "ghost_2.png", "ghost_3.png", "ghost_4.png", "ghost_5.png"]
    
    var bubbles:[SKSpriteNode]
    var bubbbleInGun:SKSpriteNode?
    var lastTouch:CGPoint
    var timestamp:NSDate
    var gunPosition:CGPoint
    var gun0:SKSpriteNode
    var player:SKSpriteNode
    var playerGui:playerCircleLayer
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        
       // let myLabel = SKLabelNode(fontNamed:"Chalkduster")
       // myLabel.text = "Hello, World!";
       // myLabel.fontSize = 65;
       // myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        
       // self.addChild(myLabel)
    
        self.gun0.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)/4);
        self.gun0.name = "gun"
        //self.gun0.physicsBody = SKPhysicsBody(rectangleOfSize: gun0.size)
        //self.gun0.physicsBody!.dynamic = false;
        //self.physicsBody?.categoryBitMask = 3
        //self.physicsBody!.collisionBitMask = 3
        //self.addChild(self.gun0)
        
        
        self.player.position = CGPoint(x:CGRectGetMidX(self.frame), y: 80);
        self.player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        //self.player.physicsBody!.dynamic = false;
        self.player.physicsBody!.affectedByGravity = false
        self.player.physicsBody!.categoryBitMask = playerBitmask;
        self.player.physicsBody!.collisionBitMask = 0;
        self.addChild(self.player);
        self.player.name = "player";
        gun0.anchorPoint = CGPoint(x: 0.5, y: 0.0)
         self.gun0.position = CGPoint(x:0, y:15);
        
        //self.player.xScale = 2.0
        //self.player.yScale = 2.0
        self.player.addChild(self.gun0);
        
        let playerPosInView = self.convertPointToView(self.player.position)
        self.playerGui.frame = CGRectMake(playerPosInView.x - CGRectGetMidX(self.frame)/4, playerPosInView.y - CGRectGetMidX(self.frame)/4 , CGRectGetMidX(self.frame)/2 , CGRectGetMidX(self.frame)/2 )
    
        //self.playerGui.backgroundColor = UIColor.whiteColor().CGColor
        view.layer.addSublayer(self.playerGui)
        self.playerGui.hidden = true
        self.playerGui.setNeedsDisplay()
        
        
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
           
            
            let locationInView = self.convertPointToView(location)
            if (CGRectContainsPoint(self.playerGui.frame, locationInView))
            {
                //println("inside playergui")
                //let bubble = SKSpriteNode(imageNamed:"round")
                let bubble = self.createBubble(CGSize(width: 100,height: 100))
                //bubble.xScale = 0.9
                //bubble.yScale = 0.6
                bubble.position = self.convertPoint(CGPoint(x: 0, y: 60), fromNode: self.gun0)
                //let action = SKAction.moveByX(0.0, y: 10, duration: 0.5)
                //bubble.runAction(SKAction.repeatActionForever(action))
                
                
                let action = SKAction.scaleBy(2.0, duration: 1.0)
                bubble.runAction(action, completion: { () -> Void in
                    bubble.removeFromParent()
                    
                })
                bubble.name = "bubble"
                bubbbleInGun = bubble
                self.addChild(bubble)
                
                self.gun0.texture = SKTexture(imageNamed: "gun_fire")
                
                timestamp =  NSDate()
            }
            lastTouch = location;
            
        }

    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches
        {
          
            let location = touch.locationInNode(self)
            
        
               /* Called when a touch moves */
               if ((bubbbleInGun) != nil)
               {
        
                
                var angle = atan(location.y/(location.x - self.size.width/2))
                if (location.x > self.size.width/2)
                {
                    angle = -atan((location.x - self.size.width/2)/location.y)
                }
                else
                {
                   angle = atan((self.size.width/2 - location.x)/location.y)
                }
                println(angle)
                //self.player.runAction(SKAction.rotateToAngle(angle, duration: 0.1))
                
                let gun:SKSpriteNode = self.player.childNodeWithName("gun") as SKSpriteNode
                
                
                gun.zRotation = angle;
                
               }
        
            }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches
        {
            let location = touch.locationInNode(self)
            
            if ((bubbbleInGun) != nil)
            {
                bubbbleInGun?.removeAllActions()
                
                let t2 = timestamp.timeIntervalSinceNow
                let t:CGFloat = CGFloat(t2)
    
                let factor:CGFloat = ((-1.0 / t) + 0.1)*2
                
                var v = CGVectorMake(location.x - lastTouch.x ,  location.y - lastTouch.y)
                v = CGVectorMake(v.dx * factor, v.dy * factor)
                
                
                
                bubbbleInGun!.physicsBody =  SKPhysicsBody.init(circleOfRadius:bubbbleInGun!.frame.size.width*0.5)
                
                
                
                bubbbleInGun!.physicsBody!.density = 0.2
                bubbbleInGun!.physicsBody!.applyForce(v)
                //bubbbleInGun!.physicsBody!.applyAngularImpulse(0.1)
                bubbbleInGun!.physicsBody!.affectedByGravity = false
                bubbbleInGun!.physicsBody!.collisionBitMask = wallBitmask | bubbleBitmask
                bubbbleInGun!.physicsBody!.categoryBitMask = bubbleBitmask
                
                bubbbleInGun = nil
                
                self.gun0.texture = SKTexture(imageNamed: "gun")
                
                
                lastTouch = location
                return
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        
       if (rand()%300 == 3)
       {
         self.spawnMonster()
        }
        
        
        for a:AnyObject in self.children
        {
            let b:SKNode = a as SKNode
            let s:NSString? = b.name
            
            if (s? == "monster")
            {
            
                //var allSprites = b.physicsBody!.allContactedBodies().filter { $0 is SKNode }
              for c:AnyObject in b.physicsBody!.allContactedBodies()
              {
                //print("contact ")
                
               // if (c is SKSpriteNode)
                //{
                
                // BUG: Swift: Unable to downcast AnyObject to SKPhysicsBody
                let c0:SKNode = c.node!!
                let s:NSString? = b.name
                //let c0:SKNode = c as SKNode
                //let s:NSString? = c0.name
                if (c.node??.name? == "bubble")
                {
                    
                   
                   if (CGRectContainsRect(c0.frame, b.frame))
                   {
                      //b.removeAllActions()
                      //b.removeFromParent()
                      let disappear = SKAction.scaleTo(0.0, duration: 0.2)
                      let move = SKAction.moveTo(c0.position , duration: 0.2)
                      b.physicsBody?.categoryBitMask = 0
                      b.runAction(move)
                      b.runAction(disappear, completion: { () -> Void in
                        b.removeFromParent()
                      })
                    
                    c0.physicsBody?.categoryBitMask = 0
                    c0.removeAllActions()
                    c0.physicsBody?.dynamic = false;
                    c0.runAction(disappear, completion: { () -> Void in
                        c0.removeFromParent()
                        
                    })
                    
                 }
                }
                
                if (c.node??.name? == "player")
                {
                    b.removeAllActions()
                    b.removeFromParent()
                    
                    let spin = SKAction.rotateByAngle(6*3.141592653589793, duration: 1.0)
                    
                    c0.runAction(spin)
                    
                }
                //let s:NSString? = b.name
                
              //}
                }
            }
        }
        
    
    
        
    }
    
    func spawnMonster()
    {
        //let gun:SKNode = self.childNodeWithName("gun")!
        //gunPosition = gun.position
        
        //let monster:SKSpriteNode = SKSpriteNode(color: UIColor.blackColor(), size: CGSizeMake(30, 30 ))

        //let monsterAtlas = SKTextureAtlas(named: "shock")
        
        
        let monster:SKSpriteNode = SKSpriteNode(imageNamed:"ghost_1.png")
        
        var textures:[SKTexture] = []
        
        for s in self.ghostsFiles
        {
            textures.append(SKTexture(imageNamed: s))
        }
        let anim = SKAction.animateWithTextures(textures, timePerFrame: 0.2)
        //monster.xScale = 0.1
        monster.yScale = 0.8
        
        
        let r = CGFloat(rand())
        let x_pos =  50 +  CGFloat(r % 300)
        
        monster.name = "monster"
        //monster.position.x = x_pos
        //monster.position.x  = 50
        monster.position = CGPoint(x: x_pos,y: self.size.height + 20)
    
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size)
        monster.physicsBody = SKPhysicsBody(texture: monster.texture, size:monster.size)
        monster.physicsBody!.affectedByGravity = false;
        monster.physicsBody!.collisionBitMask =  playerBitmask | bubbleBitmask | monsterBitmask;
        monster.physicsBody!.categoryBitMask = monsterBitmask;
        monster.physicsBody!.restitution = 0.0
        monster.physicsBody!.allowsRotation = false
        monster.physicsBody!.dynamic = false
        monster.physicsBody!.usesPreciseCollisionDetection = true
        
        //monster.position.y = self.size.height / 2 + 30
        
        
        let r2 = CGFloat(rand()) % 100
        println("monster.position \(monster.position.x) \(monster.position.y)")
        println("gun.position \(self.gun0.position.x) \(self.gun0.position.y)")
                //let m0:UnsafePointer<CGAffineTransform> = &m
        let p:CGMutablePathRef = CGPathCreateMutable()
        CGPathMoveToPoint(p, nil , monster.position.x, monster.position.y)
        CGPathAddCurveToPoint(p, nil,monster.position.x + 50,monster.position.y, self.player.position.x + 50,self.player.position.y, self.player.position.x, self.player.position.y - 100)
        
        //println("gun.position \(self.player.position.x) \(self.player.position.y)")
        //let p0 = self.convertPoint(self.gun0.position, toNode:monster)
        //println("gun.position* \(p0.x) \(p0.y)")
        //CGPathAddLineToPoint(p, nil, p0.x, p0.y)
        //let move = SKAction.followPath(p, speed: 40*(CGFloat(rand())%6))
        let move = SKAction.followPath(p, asOffset:false, orientToPath: false, speed: 30) //20*(CGFloat(rand())%6) + 20)
        ///let move = SKAction.moveTo(self0.position, duration: 4.0)
        monster.runAction(move)
        monster.runAction(SKAction.repeatActionForever(anim))
        
        
        
        self.addChild(monster)
        
        
      
        
        
    }
    
    
    
    func createBubble(size:CGSize)->SKSpriteNode
    {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let ctx = UIGraphicsGetCurrentContext()
        let circle = CGPathCreateWithEllipseInRect(CGRectMake(0,0, size.width, size.height), nil)
        CGContextSetRGBStrokeColor(ctx, 0.8, 0.8, 0.9, 1.0)
        CGContextSetRGBFillColor(ctx, 0.4, 0.8, 0.8 , 0.2)
        CGContextSetLineWidth(ctx, 2)
        
        CGContextAddPath(ctx, circle)
        CGContextFillPath(ctx)
        
        
        let circle2 = CGPathCreateWithEllipseInRect(CGRectMake(1,1, size.width - 2, size.height - 2), nil)
        CGContextAddPath(ctx, circle2)
        CGContextStrokePath(ctx)
        
        let circle3 = CGPathCreateWithEllipseInRect(CGRectMake(10,10, 40 , 80), nil)
        CGContextAddPath(ctx, circle3)
        CGContextSetRGBFillColor(ctx, 1, 1, 1 , 0.3)
        //CGContextFillPath(ctx)
        CGContextStrokePath(ctx)
        
        //let image = UIGraphicsGetImageFromCurrentImageContext();
        let txt = SKTexture(image: UIGraphicsGetImageFromCurrentImageContext())
        let b = SKSpriteNode(texture: txt)
        
        
        UIGraphicsEndImageContext();
        
        return b
    }
    
}

class playerCircleLayer : CALayer
{
    
    override func drawInContext(ctx: CGContext!)
    {
        var r = self.bounds
        r.inset(dx: 10, dy: 10)
        let circle = CGPathCreateWithEllipseInRect(r, nil)
        CGContextSetLineWidth(ctx, 3)
        CGContextSetRGBStrokeColor(ctx, 0.8, 0.8, 0.0 , 1.0)
        
        CGContextAddPath(ctx, circle)
        CGContextStrokePath(ctx)
        
    }
    
    
    
}




