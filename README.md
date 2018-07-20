# MemoryLeaks
#一 、背景

平常我们都会用 Instrument 的 Leaks / Allocations 或其他一些开源库进行内存泄露的排查，但是检查过程非常繁琐，而且不清晰,最主要的是Abandoned memory不会被检测出来。

###Leaks
从苹果的开发者文档里可以看到，一个 app 的内存分三类：

- **Leaked memory**: Memory unreferenced by your application that cannot be used again or freed (also detectable by using the Leaks instrument).

- **Abandoned memory**: Memory still referenced by your application that has no useful purpose.

- **Cached memory**: Memory still referenced by your application that might be used again for better performance.

其中 Leaked memory 和 Abandoned memory 都属于应该释放而没释放的内存，都是内存泄露。
而 Leaks 工具只负责检测 Leaked memory，而不管 Abandoned memory。
在 MRC 时代 Leaked memory 很常见，因为很容易忘了调用 release，但在 ARC 时代更常见的内存泄露是循环引用导致的 Abandoned memory，Leaks 工具查不出这类内存泄露，应用有限。

###Allocations
对于 Abandoned memory，可以用 Instrument 的 Allocations 检测出来。

检测方法：每次点击 Mark Generation 时，Allocations 会生成当前 App 的内存快照，而且 Allocations 会记录从上回内存快照到这次内存快照这个时间段内，新分配的内存信息。


我们可以不断重复 push 和 pop 同一个 UIViewController，理论上来说，push 之前跟 pop 之后，app 会回到相同的状态。因此，在 push 过程中新分配的内存，在 pop 之后应该被 dealloc 掉，除了前几次 push 可能有预热数据和 cache 数据的情况。如果在数次 push 跟 pop 之后，内存还不断增长，则有内存泄露。

用这种方法来发现内存泄露还是很不方便的：

- 首先，你得打开 Allocations
- 其次，你得一个个场景去重复的操作
- 无法及时得知泄露，得专门做一遍上述操作，十分繁琐

#二 、MLeaksFinder
###简介
MLeaksFinder 是 WeRead 团队开源的iOS内存泄漏检测工具，[wereadteam博客](https://link.jianshu.com/?t=http://wereadteam.github.io)，[GitHub](https://link.jianshu.com/?t=https://github.com/Tencent/MLeaksFinder)。


MLeaksFinder 提供了内存泄露检测的解决方案。只需要引入 MLeaksFinder，就可以自动在 App 运行过程检测到内存泄露的对象并立即提醒，无需打开额外的工具，也无需为了检测内存泄露而一个个场景去重复地操作。

无需修改任何业务逻辑代码，而且只在 debug 下开启，完全不影响你的 release 包。

MLeaksFinder 具备以下优点：

- 使用简单，不侵入业务逻辑代码，不用打开 Instrument
- 不需要额外的操作，你只需开发你的业务逻辑，在你运行调试时就能帮你检测
- 内存泄露发现及时，更改完代码后一运行即能发现（这点很重要，你马上就能意识到哪里写错了）
- 精准，能准确地告诉你哪个对象没被释放

###原理

MLeaksFinder 一开始从 UIViewController 入手。当一个 UIViewController 被 pop 或 dismiss 后，该 UIViewController 包括它的 view，view 的 subviews 等等将很快被释放（除非你把它设计成单例，或者持有它的强引用，但一般很少这样做）。于是，我们只需在一个 ViewController 被 pop 或 dismiss 一小段时间后，看看该 UIViewController，它的 view，view 的 subviews 等等是否还存在。

具体的方法是，为基类 NSObject 添加一个方法 -willDealloc 方法，该方法的作用是，先用一个弱指针指向 self，并在一小段时间(3秒)后，通过这个弱指针调用 -assertNotDealloc，而 -assertNotDealloc 主要作用是直接中断言。

![image.png](https://upload-images.jianshu.io/upload_images/1129777-638a3135557786df.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)




这样，当我们认为某个对象应该要被释放了，在释放前调用这个方法，如果3秒后它被释放成功，weakSelf 就指向 nil，不会调用到 -assertNotDealloc 方法，也就不会中断言，如果它没被释放（泄露了），-assertNotDealloc 就会被调用中断言。这样，当一个 UIViewController 被 pop 或 dismiss 时（我们认为它应该要被释放了），我们遍历该 UIViewController 上的所有 view，依次调 -willDealloc，若3秒后没被释放，就会中断言。

![image.png](https://upload-images.jianshu.io/upload_images/1129777-b0196ed51562ae28.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


####有几个问题

1.  不入侵开发代码

这里使用了 AOP 技术，hook 掉 UIViewController 和 UINavigationController 的 pop 跟 dismiss 方法。

2.  遍历相关对象

在实际项目中，我们发现有时候一个 UIViewController 被释放了，但它的 view 没被释放，或者一个 UIView 被释放了，但它的某个 subview 没被释放。这种内存泄露的情况很常见，因此，我们有必要遍历基于 UIViewController 的整棵 View-ViewController 树。我们通过 UIViewController 的 presentedViewController 和 view 属性，UIView 的 subviews 属性等递归遍历。对于某些 ViewController，如 UINavigationController，UISplitViewController 等，我们还需要遍历 viewControllers 属性。

3.  构建堆栈信息

需要构建 View-ViewController stack 信息以告诉开发者是哪个对象没被释放。在递归遍历 View-ViewController 树时，子节点的 stack 信息由父节点的 stack 信息加上子结点信息即可。

4.  例外机制

单例或者被 cache 起来复用的 View 或 ViewController
释放不及时的 View 或 ViewController

对于有些 ViewController，在被 pop 或 dismiss 后，不会被释放（比如单例），因此需要提供机制让开发者指定哪个对象不会被释放，这里可以通过重载上面的 `-willDealloc` 方法，直接 return NO 即可。



5.  特殊情况

对于某些特殊情况，释放的时机不大一样（比如系统手势返回时，在划到一半时 hold 住，虽然已被 pop，但这时还不会被释放，ViewController 要等到完全 disappear 后才释放），需要做特殊处理，具体的特殊处理视具体情况而定。

6.  系统View

某些系统的私有 View，不会被释放（可能是系统 bug 或者是系统出于某些原因故意这样做的，这里就不去深究了），因此需要建立白名单

7.  手动扩展

MLeaksFinder目前只检测 ViewController 跟 View 对象。为此，MLeaksFinder 提供了一个手动扩展的机制，你可以从 UIViewController 跟 UIView 出发，去检测其它类型的对象的内存泄露。如下所示，我们可以检测 UIViewController 底下的 View Model：
![image.png](https://upload-images.jianshu.io/upload_images/1129777-1b250da0896e4dbd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这里的原理跟上面的是一样的，宏 MLCheck() 做的事就是为传进来的对象建立 View-ViewController stack 信息，并对传进来的对象调用 -willDealloc 方法。

![image.png](https://upload-images.jianshu.io/upload_images/1129777-bd6fdc3a4cbb311d.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![image.png](https://upload-images.jianshu.io/upload_images/1129777-fe9ecdd14fac86f2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

