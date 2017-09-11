//
//  ViewController.swift
//  Dispatch_Test
//
//  Created by ittmomWang on 2017/9/2.
//  Copyright © 2017年 ittmomProject. All rights reserved.
//

import UIKit


class ViewController: UIViewController {
    
    typealias Task = () -> Void

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //serialSync()
        //serialAsync()
        //concurrentSync()
        concurrentAsync()
        //groupAsyncTask1()
        //groupAsyncTask2()
        //semaphoreControl()
        //barrierAsync()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //concurrentQueue()
        
        //print("viewDidAppear")
        if let queue = inactiveQueue {
            queue.activate()
        }
    }
    
    //串行同步,主线程上按顺序执行，不能开子线程
    func serialSync() {
        let queue1 = DispatchQueue(label: "com.ittmom1.www")
        let queue2 = DispatchQueue(label: "com.ittmom2.www")
        queue1.sync {
            for i in 0 ..< 10 {
                print("🔴",i,Thread.current)
            }
        }
        queue1.sync {
            for i in 100 ..< 110 {
                print("🔴",i,Thread.current)
            }
        }
        
        queue2.sync {
            for i in 1000 ..< 1010 {
                print("🔵",i,Thread.current)
            }
        }
        
        queue2.sync {
            for i in 10000 ..< 10010 {
                print("🔵",i,Thread.current)
            }
        }
        
    }
    //串行异步，一个队列可以开一条子线程，
    //同一个队列任务按顺序执行，不同队列
    //的任务可异步执行
    func serialAsync() {
        let queue1 = DispatchQueue(label: "com.ittmom1.www")
        let queue2 = DispatchQueue(label: "com.ittmom2.www")
        
        queue1.async {
            for i in 0 ..< 10 {
                print("🔴",i,Thread.current)
            }
        }
        
        queue1.async {
            for i in 100 ..< 110 {
                print("🔴",i,Thread.current)
            }
        }
        
        queue2.async {
            for i in 1000 ..< 1010 {
                print("🔵",i,Thread.current)
            }
        }
        
        queue2.async {
            for i in 10000 ..< 10010 {
                print("🔵",i,Thread.current)
            }
        }

    }
    
    //并发同步，不能开新线程，所有任务按顺序在主线程完成
    //结论： 同步执行的任务所在的队列，不管是串行还是并发
    //都不能开启新线程（所以这并没有什么卵用）
    func concurrentSync() {
        let queue1 = DispatchQueue(label: "com.ittmom1.www",attributes: .concurrent)
        let queue2 = DispatchQueue(label: "com.ittmom2.www",attributes: .concurrent)
        queue1.sync {
            for i in 0 ..< 10 {
                print("🔴",i,Thread.current)
            }
        }
        queue1.sync {
            for i in 100 ..< 110 {
                print("🔴",i,Thread.current)
            }
        }
        
        queue2.sync {
            for i in 1000 ..< 1010 {
                print("🔵",i,Thread.current)
            }
        }
        
        queue2.sync {
            for i in 10000 ..< 10010 {
                print("🔵",i,Thread.current)
            }
        }
    }
    //并发异步： 不同队列并发执行
    //一条队列可以同时开启多条线程，同一队列多个不同任务异步执行
    func concurrentAsync() {
        let queue1 = DispatchQueue(label: "com.ittmom1.www",attributes: .concurrent)
        let queue2 = DispatchQueue(label: "com.ittmom2.www",attributes: .concurrent)
        queue1.async {
            for i in 0 ..< 10 {
                print("🔴",i,Thread.current)
            }
        }
        queue1.async {
            for i in 100 ..< 110 {
                print("🔴",i,Thread.current)
            }
        }
        
        queue2.async {
            for i in 1000 ..< 1010 {
                print("🔵",i,Thread.current)
            }
        }
        
        queue2.async {
            for i in 10000 ..< 10010 {
                print("🔵",i,Thread.current)
            }
        }
    }
    //保证队列中的前一个任务执行结束以后再执行下面的任务
    func barrierAsync() {
        
        let queue1 = DispatchQueue.init(label: "semaphore1", qos: .userInitiated, attributes: .concurrent)
        
        queue1.async(flags: .barrier) {
            print("通过世界佳缘网寻找老实人")
            
            sleep(2)
            print("和老实人结婚")
        }
        
        queue1.async {
            print("搜集老实人的把柄")
            
            sleep(2)
            print("找到老实人漏税和灰色经营的证据")
        }
        
        queue1.async {
            print("联系公安局的舅舅")
            
            sleep(2)
            print("和舅舅一起敲诈勒索老实人")
        }
    }
    
    //信号量： 用于控制资源被多次访问的情况，保证线程安全的统计数量。
    func semaphoreControl() {
        let semaphore = DispatchSemaphore.init(value: 2)
        
        let queue1 = DispatchQueue.init(label: "semaphore1", qos: .userInitiated, attributes: .concurrent)
        
        queue1.async {
            semaphore.wait()
            print("第一个备胎和女神嘿嘿嘿")
            sleep(1)
            print("第一个备胎没钱了，可以滚了")
            semaphore.signal()
        }
        
        queue1.async {
            semaphore.wait()
            print("第二个备胎和女神嘿嘿嘿")
            sleep(2)
            print("第二个备胎没钱了，可以滚了")
            semaphore.signal()
        }
        
        queue1.async {
            semaphore.wait()
            print("终于轮到老子了")
            semaphore.signal()
        }
    }
    
    //DispatchGroup: 如果想在dispatch_queue中所有任务执行完成之后再做某些操作，
    //可以使用DispatchGroup
    func groupAsyncTask2() {
        
        let group = DispatchGroup()
        let queue1 = DispatchQueue.init(label: "com.ittmom1.www", qos: .userInitiated, attributes: .concurrent)
        let queue2 = DispatchQueue.init(label: "com.ittmom2.www", qos: .userInitiated, attributes: .concurrent)
        
        queue1.async(group: group) {
            sleep(2)
            NSLog("队列一任务执行完成",Thread.current)
        }
        
        queue2.async(group: group) {
            sleep(1)
            NSLog("队列二任务执行完成", Thread.current)
        }
        
        NSLog("等待前")
        //这里wait方法返回值是 DispatchTimeoutResult ，是一个枚举
        // success: 在指定时间内完成任务
        // timedOut: 超过指定时间完成任务，即 超时
        let result = group.wait(timeout:.now() + .seconds(3))
        
        NSLog("等待后")
        
        NSLog("队列外任务执行", Thread.current)
        
        group.notify(queue: DispatchQueue.main) {
            switch result {
            case .success: NSLog("任务完成，没有超时",Thread.current)
            case .timedOut: NSLog("任务完成，超时",Thread.current)
            }
        }
        
    }
    
    var inactiveQueue: DispatchQueue?
    
    //调整attributes参数，开发者可以手动触发执行任务
    func concurrentQueue() {
        let anotherQueue = DispatchQueue.init(label: "anotherQueue", qos: .utility, attributes: [.initiallyInactive, .concurrent])
        inactiveQueue = anotherQueue
        
        anotherQueue.async {
            for i in 0 ..< 10 {
                //sleep(1)
                print("queue1 （1）",i, Thread.current)
            }
        }
        
        anotherQueue.async {
            for i in 100 ..< 110 {
                //sleep(1)
                
                print("queue1 (2)",i, Thread.current)
            }
        }
        
        anotherQueue.async {
            for i in 1000 ..< 1010 {
                //sleep(1)
                print("queue1 （3）",i, Thread.current)
            }
            
        }
        
        
    }
    
    //延时操作
    func delay(_ time: TimeInterval, _ method: @escaping Task) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: method)
    }

    
    //主线程同步，会造成死锁
    func syncTest() {
        DispatchQueue.main.sync {
            NSLog("会死锁 \(Thread.current)")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
}

