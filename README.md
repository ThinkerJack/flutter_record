![](https://img-blog.csdnimg.cn/5cf1ef2c34a84df6a8520f996dc6b138.png)

# Flutter录音APP

一个录音小工具。

## 1.语言环境

Flutter SDK : stable 2.0.6

Dart SDK： stable 2.12.3

## 2.项目截图

![](https://img-blog.csdnimg.cn/e408920fe8c74f65a505535ce8bce393.jpg)
![](https://img-blog.csdnimg.cn/7453b810b7904754a3c1da7b78ca4a9c.jpg)
![](https://img-blog.csdnimg.cn/0bf6b18d751f4948a79aa3536c7491c6.jpg)

## 3.开源软件包

```
flutter_sound: ^8.1.9 #录音+转MP3
path_provider: ^2.0.1 #获取文件路径
dio: ^4.0.0						#发送网络请求
permission_handler: ^8.1.3 #请求录音权限
```

## 4.开发流程简述

1. 检测录音权限是否开启，未开启会在APP内请求权限，将用户输入的ID传递到歌曲列表画面。
2. 歌曲列表画面调用两个接口，一个接口获取当前账户录过多少首歌曲，一个接口获取歌曲列表，滑动列表为ListView，请求错误时弹出POP框。点击歌曲进入到录音页面。
3. 录音页面展示的数据均为列表画面通过构造方法传入，调用flutter_sound包录音，录音结束后将acc转换为MP3，点击上传调用接口，通过FormData上传本地的MP3文件，请求错误弹出POP。

## 5.项目总结

技术上来说没有什么难点，没有引入过多的第三方软件包，网络请求，路由跳转，页面间传值都没有进行额外的封装。产品的原型也比较简单，没有设计图。比较大的收获是熟悉了一下FLutter项目android和IOS的打包。

[android打包](https://flutter.cn/docs/deployment/android)，命令：`flutter build apk --split-per-abi`，默认打包方式就是release，`flutter build apk`打出来的包特别大，因为多种架构模式的安卓包都打在一起了，加上`--split-per-abi`会把不同架构的包分开打，"armeabi-v7a", "arm64-v8a"是比较主流的，安卓也可以单独打开项目中的android文件夹，使用原生的方式进行打包，在app/build.gradle添加ndk配置，将主流的CPU架构打到一个包里，有两个地方需要特别注意，一是打包时signature中的V1和V2都需要勾选上，为了适配低版本安卓，二是app/build.gradle中的`minSdkVersion`决定了兼容的安卓版本，21适配安卓5.0。

[IOS打包](https://flutter.cn/docs/deployment/ios)，IOS打包比较复杂，推荐一篇[文章](https://segmentfault.com/a/1190000022497620)，文章有些内容有点过时，不过大部分流程都覆盖到了，简单描述一下就是在Xcode中配置好，然后`flutter build ipa      `，生成一个Runner.xcarchive文件，双击xcarchive文件一直Next生成IPA。如果不发布到app store，需要先拿到用户的UDID，添加到Devices，然后按照官网推荐的方式获取证书Certificates，Certificates就是给开发用的电脑装的，然后生成Profiles选中Devices和Certificates。在打包时选中生成的Profiles。如果发布到app store就不需要Profiles，选中Signing选项卡里的Automatically manage signing就可以了。Certificates是必须要安装的。

第二版提升了一下录音的音质，将采样率改成了96000，将比特率改成了256000.

