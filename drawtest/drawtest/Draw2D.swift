//
//  Draw2D.swift
//  drawtest
//
//  Created by XCodeClub on 2015-02-14.
//  Copyright (c) 2015 XCodeClub. All rights reserved.
//

import UIKit
import Starscream
import Foundation

class Draw2D: UIView ,WebSocketDelegate{
 var socket = WebSocket(url: NSURL(scheme: "ws", host: "slofurno.com:555", path: "/")!)   
    
    var myid:Int = -1
    var timer:NSTimer? = nil
    
    var xvars:[Double] = [20,60,120]
    var yvars:[Double] = [300,150,20]
    
    var snakes:[Snake] = []
    
    var players:[Int:Snake] = [Int:Snake]()
    
    var mysnake:Snake = Snake(0,0,0,0)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
 
        self.myCustomSetup()
    
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.myCustomSetup()
    }
    
    func myCustomSetup() {
        
        socket.delegate = self
        socket.connect()
        for var i = 0 ; i < 10; i++ {
           // snakes.append( Snake(100,100,Double(5*rand1()),Double(5*rand1())))
        }
         timer = NSTimer.scheduledTimerWithTimeInterval(1/60, target: self, selector: Selector("Update"), userInfo: nil, repeats: true)
    }
    
    
    func websocketDidConnect(ws: WebSocket) {
        println("websocket is connected")
    }
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        if let e = error {
            println("websocket is disconnected: \(e.localizedDescription)")
        }
    }
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
        
        let json = parseJSON(text)
        
        let type:String! = json["type"] as String!
        let id:Int! = json["id"] as Int!
        
        //if let type:String = json["type"] as String?{
        
        if type == "init" {
            //let newid:Int = json["id"] as Int
            myid = id
            players[id] = mysnake
            println("init id : \(id)")
        }
        else if type=="update" {
            
            let xpos:Double = json["xpos"] as Double
            let ypos:Double = json["ypos"] as Double
            let xvel:Double = json["xvel"] as Double
            let yvel:Double = json["yvel"] as Double
            
            
            if let sn = players[id] {
                
                sn.xpos = xpos
                sn.ypos = ypos
                sn.xvel = xvel
                sn.yvel = yvel
               
            }
            else{
                
                players[id] = Snake(xpos,ypos,xvel,yvel)
            
            }
            
        }
        
        
        println("Rec data: \(json)")
        
        
    }
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        println("Received data: \(data.length)")
    }
    // MARK: Write Text Action
    @IBAction func writeText(sender: UIBarButtonItem) {
        socket.writeString("hello there!")
    }
    // MARK: Disconnect Action
    @IBAction func disconnect(sender: UIBarButtonItem) {
        if socket.isConnected {
            sender.title = "Connect"
            socket.disconnect()
        } else {
            sender.title = "Disconnect"
            socket.connect()
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch in touches {
            
            var coord = touch.locationInView(self)
            //var text = NSStringFromCGPoint(coord)
          //  var string1 = String(coord.x)
           // var string2 = String(coord.y)
            
            let text = "{\"x\": \(coord.x),\"y\": \(coord.y) }"
            socket.writeString(text)
            
            
        }
    }
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
   
        let context = UIGraphicsGetCurrentContext()
        let width = rect.width
        let height=rect.height
        
        //socket.writeString("HEY!")
        
        CGContextClearRect(context, rect);
        
        CGContextSetLineWidth(context, 4.0)
        CGContextSetStrokeColorWithColor(context,
            UIColor.blueColor().CGColor)
        
        for (pid, player) in players {
            
            
            let rectangle = CGRect(x:player.xpos-20,y:player.ypos-20,width:40,height: 40)
            CGContextAddRect(context, rectangle)
            CGContextStrokePath(context)
        }
        
        for var i = 0; i < snakes.count; i++
        {
            
            
            let rectangle = CGRect(x:snakes[i].xpos-20,y:snakes[i].ypos-20,width:40,height: 40)
            CGContextAddRect(context, rectangle)
            CGContextStrokePath(context)
            
            snakes[i].xpos += snakes[i].xvel
            snakes[i].ypos+=snakes[i].yvel
            
            if snakes[i].xpos > Double(width) {
                snakes[i].xvel = -snakes[i].xvel
                snakes[i].xpos = Double(width)
                
            }
            else if snakes[i].xpos < 0 {
                
                snakes[i].xvel = -snakes[i].xvel
                snakes[i].xpos = 0
            }
            
            
            
            if snakes[i].ypos > Double(height){
                snakes[i].yvel = -snakes[i].yvel
            snakes[i].ypos = Double(height)
                
            }
            else if snakes[i].ypos < 0 {
                snakes[i].yvel = -snakes[i].yvel
                snakes[i].ypos = 0
                
            }
        }
        
   
        
        
        
    }
    

    func Update(){
        
        self.setNeedsDisplay()
        
    }
    

}

func rand1() -> Float {
    return Float(arc4random()) /  Float(INT32_MAX) - 1
}

func parseJSON(inputString: String) -> NSDictionary{
    
    let data = (inputString as NSString).dataUsingEncoding(NSUTF8StringEncoding)
    
    var error: NSError?
    var boardsDictionary: NSDictionary = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers, error: &error) as NSDictionary
    return boardsDictionary
}
class Snake {
    
    var xpos:Double
    var ypos:Double
    var xvel:Double
    var yvel:Double
    
    init(_ x: Double, _ y: Double, _ vx:Double, _ vy:Double) {
        self.xpos = x
        self.ypos = y
        self.xvel = vx
        self.yvel = vy
    }
    
}


