# Dispatch_Test
多线程基础知识集锦
#### 1.多线程的基本概念
**线程：**
（thread）是组成进程的子单元，操作系统的调度器可以对线程进行单独的调度。实际上，所有的并发编程 API 都是构建于线程之上的 —— 包括 GCD 和操作队列（operation queues）。

**单核与多核CPU操作系统下多线程的不同：**
多线程可以在单核 CPU 上同时（或者至少看作同时）运行。操作系统将小的时间片分配给每一个线程，这样就能够让用户感觉到有多个任务在同时进行。如果 CPU 是多核的，那么线程就可以真正的以并发方式被执行，从而减少了完成某项操作所需要的总时间。

**线程生命周期：**
    1. 新建：实例化线程对象
    2. 就绪： 向线程对象发送star消息，线程对象被加入可调度线程池中等待CPU调度。
    3. 运行： CPU负责调度线程池中可调度线程的执行。线程执行完成之前，状态可能会在就绪和运行之间来回切换。就绪和运行之间的状态变化都是由CPU负责，程序员不能干预
    4. 阻塞： 当满足某个预定条件时，可以使用休眠或锁，阻塞线程执行。sleepForTimeInterval（休眠指定时长），sleepUntilDate（休眠到指定日期），@synchronized(self)：（互斥锁）
    5. 死亡： 正常死亡，线程执行完毕。非正常死亡，当满足某个条件后，在线程内部中中止执行/在主线程中止线程对象。还有线程的 exit和cancel. 
    6. Thread.exit 一旦强行终止线程，后续的所有代码都不会执行。
    7. thread.cancel取消，并不会直接取消线程，只是给线程对象添加 isCancelled 标记
####2. 线程的安全问题
多个线程访问同一块资源时，很容易引发数据错乱和数据安全问题。
解决方案： 
**互斥锁（同步锁）**
@syncchronized(锁对象) {
    //需要锁定的代码
}
判断的时候锁对象要存在，如果代码中只有一个地方需要加锁，大多都使用self作为锁对象，这样可以避免单独再创建一个锁对象。
加了互斥锁的代码，当新线程访问时，如果发现其他线程正在执行锁定的代码，新线程就会进入休眠。
**自旋锁**
加了自旋锁，当新线程访问代码时，如果发现有其他线程正在锁定代码，新线程会用死循环的方式，一直等待锁定的代码执行完成。相当于不停尝试执行代码，比较消耗性能。

**属性修饰atomic就是一把自旋锁。**

**nonatomic:** 非原子属性，同一时间可以有很多线程读和写。非线程安全的，不过效率更高，一般使用nonatomic。
**atomic:** 原子属性（线程安全），保证同一时间只有一个线程能够写入（但是同一时间多个线程都可以取值），需要耗费大量资源。
####3.GCD的理解和使用
**GCD的特点：**
GCD会自动利用更多的CPU内核
GCD自动管理线程的生命周期（创建线程，调度任务，销毁线程等）
程序员只需要告诉 GCD 想要如何执行什么任务，不需要编写任何线程管理代码

**GCD的基本概念：**
    **任务（block）**：任务就是将要在线程中执行的代码，将这段代码用block封装好，然后将这个任务添加到指定的执行方式（同步执行和异步执行），等待CPU从队列中取出任务放到对应的线程中执行。
    **同步（sync）**：一个接着一个，前一个没有执行完，后面不能执行，不开线程
    **异步（async）**：开启多个新线程，任务同一时间可以一起执行。异步是多线程的代名词
    **队列**：装载线程任务的队形结构。(系统以先进先出的方式调度队列中的任务执行)。在GCD中有两种队列：串行队列和并发队列
    **并发队列**：线程可以同时一起进行执行。实际上是CPU在多条线程之间快速的切换。（并发功能只有在异步（dispatch_async）函数下才有效）
    **串行队列**：线程只能依次有序的执行
   下面是代码：
**由于篇幅限制，就不贴执行结果了，如果有兴趣不妨自己写来看看**
```Swift
//串行同步：任务在主线程上按顺序执行，不能开子线程
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
                
    }
```
```Swift
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
        
    }
```

```Swift
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
```

```Swift
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
    }
```
**GCD基础部分总结（可以说，看懂了这里，再也不用发愁面试被问到同步异步的区别了）：** 
串行队列同步执行，不开启线程（主线程中执行任务），代码从上往下按顺序执行。
串行队列异步执行，每个队列可以开启一条线程，相同队列的不同任务串行执行。不同队列可以实现异步执行。
并发队列同步执行，不开启线程（主线程中执行任务），代码从上往下按顺序执行。
并发队列异步执行，同一个队列可以开启多条线程，线程可以同时执行多个任务。
####4. GCD的高级用法（精华）
**4.1 利用initiallyInactive手动触发执行任务**

```Swift
var inactiveQueue: DispatchQueue?
    
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
override func viewDidAppear(_ animated: Bool) {
print("viewDidAppear")
super.viewDidAppear(animated)
concurrentQueue()

if let queue = inactiveQueue {
  queue.activate()
}
}
```
**4.2 DispatchGroup的使用**
如果想在dispatch_queue中所有任务执行完成之后再做某些操作，可以使用DispatchGroup。

```Swift
let group = DispatchGroup()
   
let queue1 = DispatchQueue(label: "task1")
queue1.async(group: group){
  for _ in 1 ..< 10 {
      sleep(1)
      let date = NSDate()
      print("🔴",Thread.current,date)
  }
}
   
let queue2 = DispatchQueue(label: "task2")
queue2.async(group: group) {
  self.delay(2, { 
      print("🔵",Thread.current)
  })
}
   
group.notify(queue: DispatchQueue.main) {
  let date = NSDate()
  print("task1,task2任务完成",date)
}
```
**wait**: 如果组里有多个并发队列存在，调用wait可以在任务执行完毕以后再继续执行代码，wait可以阻塞当前线程，等待执行结果。

```Swift
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
执行结果: 
2017-09-11 10:50:32.765867+0800 Dispatch_Test[4480:4020080] 等待前
2017-09-11 10:50:33.774021+0800 Dispatch_Test[4480:4020114] 队列二任务执行完成
2017-09-11 10:50:34.767320+0800 Dispatch_Test[4480:4020080] 等待后
2017-09-11 10:50:34.767569+0800 Dispatch_Test[4480:4020080] 队列外任务执行
2017-09-11 10:50:34.781383+0800 Dispatch_Test[4480:4020113] 队列一任务执行完成
2017-09-11 10:50:34.810031+0800 Dispatch_Test[4480:4020080] 任务完成，超时
```
**4.3 Semaphore 信号量**
用于控制资源被多次访问的情况，保证线程安全的统计数量。
举个栗子： 一个女神可以同时和两个备胎谈恋爱，如果有第三个备胎想插进来，需要等其中一个备胎没钱了，养不起女神了，才能轮得到你。当然，这没有前后顺序，谁不行了，谁撤...

```Swift
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
执行结果:
第一个备胎和女神嘿嘿嘿
第二个备胎和女神嘿嘿嘿
第一个备胎没钱了，可以滚了
终于轮到老子了
第二个备胎没钱了，可以滚了
```
**4.4 Barrier**
保证一个队列里的前一个任务执行完毕以后，才执行后面的任务。
举个栗子： 就拿翟欣欣骗婚的事情说，欣欣童鞋要通过世纪佳缘网骗老实人和她结婚，然后一边搜集老实人的把柄，一边跟公安局的舅舅密谋勒索老实人的财产。但是欣欣童鞋只可能保证跟老实人结婚以后才能做后续的工作，所以，这时候我们要用到Barrier

```Swift
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

执行结果：
通过世界佳缘网寻找老实人
和老实人结婚
搜集老实人的把柄
联系公安局的舅舅
找到老实人漏税和灰色经营的证据
和舅舅一起敲诈勒索老实人
```
**4.5 延时执行**

```Swift
DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: {
    //执行任务
})
```
