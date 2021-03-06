//
//  ViewController.swift
//  MetalDemo
//
//  Created by fanren on 16/4/6.
//  Copyright © 2016年 Qinmin. All rights reserved.
//

import UIKit
import Metal
import QuartzCore

class ViewController: UIViewController {

    var device:MTLDevice! = nil
    var metalLayer:CAMetalLayer! = nil
    var vertexBuffer: MTLBuffer! = nil
    var pipelineState: MTLRenderPipelineState! = nil
    var commandQueue: MTLCommandQueue! = nil
    var displayLink: CADisplayLink! = nil
    
    let vertexData:[Float] = [
         0.0,  1.0, 0.0,
        -1.0, -1.0, 0.0,
         1.0, -1.0, 0.0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        device = MTLCreateSystemDefaultDevice()
        metalLayer = CAMetalLayer()
        metalLayer.device = device
        metalLayer.pixelFormat = .BGRA8Unorm
        metalLayer.framebufferOnly = true
        metalLayer.frame = view.layer.frame 
        view.layer.addSublayer(metalLayer)
        
        
        let dataSize = vertexData.count * sizeofValue(vertexData[0])
        vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: .CPUCacheModeDefaultCache)
        
        let defaultLibrary = device.newDefaultLibrary()
        let fragmentProgram = defaultLibrary?.newFunctionWithName("basic_fragment")
        let vertexProgram = defaultLibrary?.newFunctionWithName("basic_vertex")
        
        // 2
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram!
        pipelineStateDescriptor.fragmentFunction = fragmentProgram!
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
        
        // 3
        do {
            try pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor)
        }catch(let e) {
            print("\(e)");
        }
        
        commandQueue = device.newCommandQueue()
        
        displayLink = CADisplayLink(target: self, selector: #selector(gameLoop))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    }
    
    func render() {
        let drawable = metalLayer.nextDrawable()
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable!.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .Clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 0.0, green: 104.0/255.0, blue: 5.0/255.0, alpha: 1.0)
        
        let commandBuffer = commandQueue.commandBuffer()
        let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, atIndex: 0)
        renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
        renderEncoder.endEncoding()

        commandBuffer.presentDrawable(drawable!)
        commandBuffer.commit()
    }
    
    func gameLoop(displayLink:CADisplayLink) {
        autoreleasepool {
            self.render()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

