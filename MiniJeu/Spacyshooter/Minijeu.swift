//
//  ContentView.swift
//  Spacyshooter
//
//  Created by Apprenant 87 on 21/09/2024.
//

import SwiftUI
import SpriteKit
//Framework qui apport de la physics/gravité et des élément graphique
import GameKit
//frame work qui apporte de la gestion du classement ,multijoueur

class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    
    //GameScene = environnement de jeu (je globalise)
    //SKScene = gere le rendu graphique , animation , phisic.
    //SKPhysicsContactDelegate = permet de gerer les colision et interaction physic
    //ObservableObject = on va dire les mise a jour 
    
    
    let background = SKSpriteNode(imageNamed: "spaceBackground")
//    le background changeable
    var player = SKSpriteNode()
    var playerFire = SKSpriteNode()
    var enemy = SKSpriteNode()
    var bossOne = SKSpriteNode()
    @objc var bossOneFire = SKSpriteNode()
    // objc : permet a deux language de comuniquer Sans besoin de réecrire (je l'ai compris comme sa) -> interopérabilité
    //SKSpriteNode()  sa gere L'image, l'animation et le systeme physic
    
    
   @Published  var gameOver = false
    
    var scoreMiniJeu = 0
    var scoreLabel = SKLabelNode()
    // le score
    var liveArray = [SKSpriteNode]()
    
    var fireTimer = Timer()
    var enemyTimer = Timer()
    var bossOneFireTimer = Timer()
    var bossOneLives = 25
    //enemy et les tir timing
    
    struct CBItmask {
        static let playerShip: UInt32 = 0b1 // 1
        static let playerFire: UInt32 = 0b10 // 2
        static let enemyShip: UInt32 = 0b100 // 4
        static let bossOne: UInt = 0b1000 // 5
    }
    
    
    override func didMove(to view: SKView){
        physicsWorld.contactDelegate = self
        
        
        scene?.size = CGSize(width:950, height: 1335 )
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
//        Position background
        background.setScale(0.7)
//        taille back ground
        background.zPosition = 1
        background.alpha = 0.8
//        dimension background
        addChild(background)
//        le addchild permet d'ajouter un continue a un parent dans le framework SpriteKit
        
        makePlayer(playerCh:shipChoice.integer(forKey: "playerChoice"))
//        changement de vaisseau player
        
        fireTimer = .scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(playerFireFunction), userInfo: nil, repeats: true)
//        interval de tir
        
        enemyTimer = .scheduledTimer(timeInterval: 1, target: self, selector: #selector(makeEnemys), userInfo: nil, repeats: true)
//        interval d'enemy
        
        scoreLabel.text = "Arnaque Evité  \(scoreMiniJeu)"
//        Nom du score du jeu en cours
        scoreLabel.fontName = "Avenir"
//        Style d'ecriture
        scoreLabel.fontSize = 50
//        taille du score
        scoreLabel.fontColor = .red
//        couleur du score
        scoreLabel.zPosition = 10
        scoreLabel.position = CGPoint(x: size.width / 2, y: size.height / 1.3)
//        position du score
        addChild(scoreLabel)
        
        addlives(lives: 3)
    
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let contactA : SKPhysicsBody
        let contactB : SKPhysicsBody
//            Stock les corps physic en constante
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            contactA = contact.bodyA
            contactB = contact.bodyB
        }else {
            contactA = contact.bodyB
            contactB = contact.bodyA
        }
        
//        Playfire hit enemy
        if contactA.categoryBitMask == CBItmask.playerFire && contactB.categoryBitMask == CBItmask.enemyShip {
            
            udapteScore()
            
            playerFireHitEnemy(fires: contactA.node as! SKSpriteNode, enemys: contactB.node as! SKSpriteNode)
            
            
            if scoreMiniJeu == 5 {
    //            condition d'aparition du boss
                makeBossOne()
                enemyTimer.invalidate()
                bossOneFireTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(bossOneFireFunc), userInfo: nil, repeats: true)
            }
        }
        
        if contactA.categoryBitMask == CBItmask.playerShip && contactB.categoryBitMask == CBItmask.enemyShip {
            
            
            player.run(SKAction.repeat(SKAction.sequence([SKAction.fadeOut(withDuration: 0.1), SKAction.fadeIn(withDuration: 0.1) ]), count:8))
//            durée d'incibilté apres avoir pris des dmg
            contactB.node?.removeFromParent()
            
            if let live1 = childNode(withName: "live1") {
                live1.removeFromParent()
//                si tu prends une colision bah -1 vie
            }else  if let live2 = childNode(withName: "live2"){
                live2.removeFromParent()
            }else if let live3 = childNode(withName: "live3"){
                live3.removeFromParent()
                player.removeFromParent()
                fireTimer.invalidate()
                enemyTimer.invalidate()
//               sa dit que si ta plus de vie il n'y aura plus d'enemys ou tir
                gameOverFunc()
            }
        }
        
        if contactA.categoryBitMask == CBItmask.playerFire && contactB.categoryBitMask == CBItmask.bossOne {
            
//                    let explo = SKEmitterNode(fileNamed: "EplosionOne")
//                    explo?.position = contactA.node!.position
//                    explo?.setScale(2)
//                    explo?.zPosition = 5
//                    addChild(explo!)
                    
            //        explosion mais sa fait tout crash
            
            contactA.node?.removeFromParent()
            
            bossOneLives -= 1
            
            if bossOneLives == 0 {
                
//                 let explo = SKEmitterNode(fileNamed: "EplosionOne")
//                 explo?.position = contactB.node!.position
//                 explo?.zPosition = 5
//                 explo?.setScale(2)
//                 addChild(explo!)
                        
//                 explosion mais sa fait tout crash
                
                contactB.node?.removeFromParent()
                bossOneFireTimer.invalidate()
                enemyTimer = .scheduledTimer(timeInterval: 0.7, target: self, selector: #selector(makeEnemys), userInfo: nil, repeats: true)
            }
        }
        
        
        
    }
    func playerHitEnemy(players: SKSpriteNode, enemys: SKSpriteNode) {
        players.removeFromParent()
        enemys.removeFromParent()
        
        fireTimer.invalidate()
        enemyTimer.invalidate()
        
//        let explo = SKEmitterNode(fileNamed: "EplosionOne")
//        explo?.position = player.position
//        explo?.zPosition = 5
//        addChild(explo!)
        
//        explosion mais sa fait tout crash
    }
    
    func playerFireHitEnemy(fires: SKSpriteNode, enemys: SKSpriteNode) {
        fires.removeFromParent()
        enemys.removeFromParent()
        
//   let explo = SKEmitterNode(fileNamed: "heart")
//        explo?.position = enemys.position
//        explo?.zPosition = 5
//        addChild(explo!)
        
//        l'explosion mais sa fait tout crash (a test If let )
    }
    
    func addlives(lives: Int) {
        for i in 1...lives {
            let live = SKSpriteNode(imageNamed: "vie")
//            image de la vie
            live.setScale(0.5)
//          taille des vie
            live.position = CGPoint(x: CGFloat(i) * live.size.width + 10, y: size.height - live.size.height - 70 )
//            position des vie
            live.zPosition = 10
            live.name = "live\(i)"
            liveArray.append(live)
            
            addChild(live)
        }
    }
    
    
    func makePlayer(playerCh: Int){
        
        var shipName = ""
        
        switch playerCh {
        case 1:
            shipName = "friendlyShip2"
            
        case 2:
            shipName = "friendlyShip2"
            
        default:
            shipName = "friendlyShip3"
//            les vaisseau différent player
        }
        
        player = .init(imageNamed: shipName)
        player.position = CGPoint(x: size.width / 2, y: 200)
//        Position player
        player.zPosition = 10
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.setScale(0.1)
        player.physicsBody?.affectedByGravity = false
//        Enleve la gravité
        player.physicsBody?.isDynamic = true
//        en gros il est affecter par la gravité et la physic
        player.physicsBody?.categoryBitMask = CBItmask.playerShip
        player.physicsBody?.contactTestBitMask = CBItmask.enemyShip
        player.physicsBody?.collisionBitMask = CBItmask.enemyShip
        addChild(player)
//        dimension vaisseau ami et position la physic
    }
    
    func makeBossOne() {
        
        bossOne = .init(imageNamed: "Hacker")
        bossOne.position = CGPoint(x: size.width / 2, y: size.height + bossOne.size.height)
//        Position du boss
        bossOne.zPosition = 10
        bossOne.setScale(0.3)
//        Taille du boss
        bossOne.physicsBody = SKPhysicsBody(rectangleOf: bossOne.size)
//        Hit box boss
        bossOne.physicsBody?.affectedByGravity = false
//        gravité 
        bossOne.physicsBody?.categoryBitMask = UInt32(CBItmask.bossOne)
//        faie attention a cette ligne logiquement c'est "CBItmask.bossOne"
        bossOne.physicsBody?.contactTestBitMask = CBItmask.playerShip | CBItmask.playerFire
        bossOne.physicsBody?.collisionBitMask = CBItmask.playerShip | CBItmask.playerFire
        addChild(enemy)
        
        let move1 = SKAction.moveTo(y: size.height / 1.3, duration: 2)
        let move2 = SKAction.moveTo(x: size.width - bossOne.size.width / 2, duration: 2)
        let move3 = SKAction.moveTo(x: 0 + bossOne.size.width / 2, duration: 2)
        let move4 = SKAction.moveTo(x: size.width / 2 , duration: 1.5)
        let move5 = SKAction.fadeOut(withDuration: 0.2)
        let move6 = SKAction.fadeIn(withDuration: 0.2)
        let move7 = SKAction.moveTo(y: 0 + bossOne.size.height / 2, duration: 2)
        let move8 = SKAction.moveTo(y: size.height / 1.3, duration: 2)
        
        let action = SKAction.repeat(SKAction.sequence([move5, move6]), count:  6)
        let repeatForever = SKAction.repeatForever(SKAction.sequence([move2,move3,move4,action,move7,move8]))
        let sequence = SKAction.sequence([move1,repeatForever])
//        Paramettre du boss
        
        bossOne.run(sequence)
        
        addChild(bossOne)
    }
    
 @objc   func bossOneFireFunc() {
        bossOneFire = .init(imageNamed: "laserGreen")
        bossOneFire.position = bossOne.position
        bossOneFire.zPosition = 5
        bossOneFire.setScale(1.5)
        
        let move1 = SKAction.moveTo(y: 0 - bossOneFire.size.height, duration: 1.5)
        let removeAction = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([move1,removeAction])
        bossOneFire.run(sequence)
        
        addChild(bossOneFire)
        
    }
    
   @objc func playerFireFunction(){
        playerFire = .init(imageNamed: "laserGreen")
//       l'image du laser'
        playerFire.position = player.position
//       position de depart du laser avec indicateur enemy/ player
       playerFire.zPosition = 3
       playerFire.physicsBody = SKPhysicsBody(rectangleOf: playerFire.size)
       playerFire.physicsBody?.affectedByGravity = false
       playerFire.physicsBody?.categoryBitMask = CBItmask.playerFire
       playerFire.physicsBody?.contactTestBitMask = CBItmask.enemyShip | UInt32(CBItmask.bossOne)
       playerFire.physicsBody?.collisionBitMask = CBItmask.enemyShip | UInt32(CBItmask.bossOne)
//       laser otpion physic
       
        addChild(playerFire)

        
       let moveAction = SKAction.moveTo(y: 1400, duration: 1)
//       il se deplace sur un espace difinie sur une durée definie
        let delateAction = SKAction.removeFromParent()
        let combine = SKAction.sequence([moveAction,delateAction])
//       interval de tir du laser player
        
        playerFire.run(combine)
        
    }
    
    @objc func makeEnemys() {
        let randomNumber = GKRandomDistribution(lowestValue: 50, highestValue: 700)
//        nombre d'enemy
        
        enemy = .init(imageNamed: "Hacker")
//        Image enemy vaisseau
        enemy.position = CGPoint(x: randomNumber.nextInt(), y: 1400)
//        Position enemy
        enemy.zPosition = 5
        enemy.setScale(0.1)
//            Taille enemi
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
//        hit box
        enemy.physicsBody?.affectedByGravity = false
//        gravité
        enemy.physicsBody?.categoryBitMask = CBItmask.enemyShip
        enemy.physicsBody?.contactTestBitMask = CBItmask.playerShip | CBItmask.playerFire
        enemy.physicsBody?.collisionBitMask = CBItmask.playerShip | CBItmask.playerFire
        addChild(enemy)
//        physique enemy
        
        let moveAction = SKAction.moveTo(y: -100, duration: 2)
         let delateAction = SKAction.removeFromParent()
         let combine = SKAction.sequence([moveAction,delateAction])
        
        enemy.run(combine)
//        mouvement enemy
        
    }
    
    func udapteScore() {
        scoreMiniJeu += 1
        
        scoreLabel.text = "Arnaque évité: \(scoreMiniJeu)"
//        Titre de départ du jeu
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            
            player.position.x = location.x
        }
    }
    
    func gameOverFunc() {
        removeAllChildren()
        gameOver = true
        
        let gameOverLabel = SKLabelNode()
        gameOverLabel.text = "Les hackeur on gagné"
//        text de game over 
        gameOverLabel.fontSize = 70
        gameOverLabel.position = CGPoint(x:  size.width / 2, y: 1.3 * size.height / 2 )
//        Position texte audessus
        gameOverLabel.fontColor = UIColor.red
//        Couleur taille position game over
        
        
        addChild(gameOverLabel)
    }
    
}

struct miniJeuOtionel: View {
 @ObservedObject   var scene = GameScene()
    
    var body: some View {
        
        NavigationView {
            HStack {
                ZStack {
                    
                    SpriteView(scene: scene)
                        .ignoresSafeArea()
                    
                    if scene.gameOver == true {
                        NavigationLink {
                            StartViewMiniJeu().navigationBarHidden(true)
                                .navigationBarBackButtonHidden(true)
                                
                        } label: {
                            Text("Revenir au choix de Protection")
//                            texte qui fait revenir au lancement
                                
                                
                        }
                    }
                    
                }
            }
        }
    }
}

#Preview {
    miniJeuOtionel()
}
