# 一 、背景

平常我们都会用 Instrument 的 Leaks / Allocations 或其他一些开源库进行内存泄露的排查，但是检查过程非常繁琐，而且不清晰,最主要的是Abandoned memory不会被检测出来。

### Leaks
从苹果的开发者文档里可以看到，一个 app 的内存分三类：

- **Leaked memory**: Memory unreferenced by your application that cannot be used again or freed (also detectable by using the Leaks instrument).

- **Abandoned memory**: Memory still referenced by your application that has no useful purpose.

- **Cached memory**: Memory still referenced by your application that might be used again for better performance.

其中 Leaked memory 和 Abandoned memory 都属于应该释放而没释放的内存，都是内存泄露。
而 Leaks 工具只负责检测 Leaked memory，而不管 Abandoned memory。
在 MRC 时代 Leaked memory 很常见，因为很容易忘了调用 release，但在 ARC 时代更常见的内存泄露是循环引用导致的 Abandoned memory，Leaks 工具查不出这类内存泄露，应用有限。

### Allocations
对于 Abandoned memory，可以用 Instrument 的 Allocations 检测出来。

检测方法：每次点击 Mark Generation 时，Allocations 会生成当前 App 的内存快照，而且 Allocations 会记录从上回内存快照到这次内存快照这个时间段内，新分配的内存信息。


我们可以不断重复 push 和 pop 同一个 UIViewController，理论上来说，push 之前跟 pop 之后，app 会回到相同的状态。因此，在 push 过程中新分配的内存，在 pop 之后应该被 dealloc 掉，除了前几次 push 可能有预热数据和 cache 数据的情况。如果在数次 push 跟 pop 之后，内存还不断增长，则有内存泄露。

用这种方法来发现内存泄露还是很不方便的：

- 首先，你得打开 Allocations
- 其次，你得一个个场景去重复的操作
- 无法及时得知泄露，得专门做一遍上述操作，十分繁琐

# 二 、MLeaksFinder
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

MLeaksFinder 为基类 NSObject 添加一个方法 -willDealloc 方法，该方法的作用是，先用一个弱指针指向 self，并在一小段时间(2秒)后，通过这个弱指针调用 -assertNotDealloc，而 -assertNotDealloc 主要作用是直接弹框提醒该对象可能存在内存泄漏。

这样，当我们认为某个对象应该要被释放了，在释放前调用这个方法，如果2秒后它被释放成功，weakSelf 就指向 nil，不会调用到 -assertNotDealloc 方法，也就不会弹框提示泄漏；如果它没被释放（泄露了），-assertNotDealloc 就会被调用，具体是遍历基于 UIViewController 的整棵 View-ViewController 树，通过 UIViewController 的 presentedViewController 和 view 属性，UIView 的 subviews 属性等递归遍历，依次调 -willDealloc，若2秒后没被释放，则存在泄漏。

![image.png](https://upload-images.jianshu.io/upload_images/1129777-638a3135557786df.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

MLeaksFinder 一开始从 UIViewController 入手，使用 AOP 技术，hook 掉 UIViewController 和 UINavigationController 的 pop 跟 dismiss 方法。具体是截获UIViewController 的 `viewDidDisappear: `方法里调用`[self willDealloc]`进行检查是否存在内存泄漏的对象。

![image.png](https://upload-images.jianshu.io/upload_images/1129777-83f32fe479be3d2a.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


至此，MLeaksFinder 能找出可能发生内存泄漏的对象。再点击弹框的 **Retain Cycle** 按钮通过 [FBRetainCycleDetector](https://github.com/facebook/FBRetainCycleDetector)检测该对象有没有循环引用。

FBRetainCycleDetector是Facebook 开源的一个循环引用检测工具。当传入内存中的任意一个 OC 对象，FBRetainCycleDetector 会递归遍历该对象的所有强引用的对象，以检测以该对象为根结点的强引用树有没有循环引用。

![image.png](https://upload-images.jianshu.io/upload_images/1129777-903748eb05ded865.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

循环引用的输出信息如下：

![image.png](https://upload-images.jianshu.io/upload_images/1129777-b3c357042c6300ad.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

上面的信息表示，BlockLeakViewController 有一个强引用的成员变量 _block，该变量的类型是 __NSMallocBlock__，在 _block 里又强引用了 BlockLeakViewController 造成循环引用。

# 三 、Usage

>pod 'MLeaksFinder'

# FAQ
**1) 引进 MLeaksFinder 后没生效？**

* 先验证引进是否正确，在 UIViewController+MemoryLeak.m 的 `+ (void)load` 方法里加断点，app 启动时进入该方法则引进成功，否则引进失败。
* 用 CocoaPods 安装时注意有没有 warnings，特别是 `OTHER_LDFLAGS` 相关的 warnings。如果有 warnings，可以在主工程的 Build Settings -> Other Linker Flags 加上 `-ObjC`。

* 由于Facebook的BSD-plus-Patents许可证，FBRetainCycleDetector已从podspec中删除。如果你想使用FBRetainCycleDetector，添加`pod 'FBRetainCycleDetector'`到您的项目的Podfile并打开MLeaksFinder.h里的宏`//#define MEMORY_LEAKS_FINDER_RETAIN_CYCLE_ENABLED 1`打开。

**2) 可以手动引进 MLeaksFinder 吗？**

* 直接把 MLeaksFinder 的代码放到项目里即生效。如果把 MLeaksFinder 做为子工程，需要在主工程的 Build Settings -> Other Linker Flags 加上 `-ObjC`。
* 引进 MLeaksFinder 的代码后即可检测内存泄漏，但查找循环引用的功能还未生效。可以再手动加入 FBRetainCycleDetector 代码，然后把 MLeaksFinder.h 里的 `//#define MEMORY_LEAKS_FINDER_RETAIN_CYCLE_ENABLED 1` 打开。

**3) Fail to find a retain cycle？**

* 内存泄漏不一定是循环引用造成的。
* 有的循环引用 FBRetainCycleDetector 不一定能找出。

**4) 如何关掉 MLeaksFinder？**

* MLeaksFinder 默认只在 debug 下生效，当然也可以通过 MLeaksFinder.h 里的 `//#define MEMORY_LEAKS_FINDER_ENABLED 0` 来手动控制开关。



#### 有几个问题

**1.  不入侵开发代码**

这里使用了 AOP 技术，hook 掉 UIViewController 和 UINavigationController 的 pop 跟 dismiss 方法。

**2.  遍历相关对象**


在实际项目中，我们发现有时候一个 UIViewController 被释放了，但它的 view 没被释放，或者一个 UIView 被释放了，但它的某个 subview 没被释放。这种内存泄露的情况很常见，因此，我们有必要遍历基于 UIViewController 的整棵 View-ViewController 树。我们通过 UIViewController 的 presentedViewController 和 view 属性，UIView 的 subviews 属性等递归遍历。对于某些 ViewController，如 UINavigationController，UISplitViewController 等，我们还需要遍历 viewControllers 属性。

**3.  构建堆栈信息**

需要构建 View-ViewController stack 信息以告诉开发者是哪个对象没被释放。在递归遍历 View-ViewController 树时，子节点的 stack 信息由父节点的 stack 信息加上子结点信息即可。

**4.  例外机制**

对于有些 ViewController， 比如单例或者被 cache 起来复用的 View 或 ViewController、  释放不及时的 View 或 ViewController，在被 pop 或 dismiss 后，不会被释放（比如单例），因此需要提供机制让开发者指定哪个对象不会被释放，这里可以通过重载上面的 `-willDealloc` 方法，直接 return NO 即可。

**5.  特殊情况**

对于某些特殊情况，释放的时机不大一样（比如系统手势返回时，在划到一半时 hold 住，虽然已被 pop，但这时还不会被释放，ViewController 要等到完全 disappear 后才释放），需要做特殊处理，具体的特殊处理视具体情况而定。

**6.  系统View**

某些系统的私有 View，不会被释放（可能是系统 bug 或者是系统出于某些原因故意这样做的，这里就不去深究了），因此需要建立白名单

**7.  查找其他对象中的泄漏**

MLeaksFinder目前只检测 ViewController 跟 View 对象。为此，MLeaksFinder 提供了一个手动扩展的机制，你可以从 UIViewController 跟 UIView 出发，去检测其它类型的对象的内存泄露。如下所示，我们可以检测 UIViewController 底下的 View Model：
![image.png](https://upload-images.jianshu.io/upload_images/1129777-1b250da0896e4dbd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这里的原理跟上面的是一样的，宏 MLCheck() 做的事就是为传进来的对象建立 View-ViewController stack 信息，并对传进来的对象调用 `-willDealloc` 方法。



# Demo地址：

https://github.com/Xcoder1011/MemoryLeaks
