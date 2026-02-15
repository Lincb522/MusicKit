# QQMusicKit

QQ音乐 API 的 Swift 封装库，适用于 iOS 15+ / macOS 12+ / tvOS 15+ / watchOS 8+。

纯 Swift 实现，零第三方依赖，基于 async/await。

## 安装

### Swift Package Manager

Xcode：File → Add Package Dependencies → 输入仓库地址

或在 `Package.swift` 中：

```swift
dependencies: [
    .package(url: "你的仓库地址", from: "1.0.0"),
]
```

## 配置

```swift
import QQMusicKit

// 设置你部署的 API 服务器地址
QQMusicClient.configure(
    baseURL: URL(string: "http://你的IP:8000")!,
    timeout: 30,    // 请求超时（秒）
    maxRetries: 1   // 失败重试次数
)
```

## 使用示例

### 检查登录状态

```swift
let status = try await QQMusicClient.shared.authStatus()
if status.loggedIn {
    print("已登录: \(status.musicid ?? 0)")
}
```

### 扫码登录

```swift
// 获取二维码
let qr = try await QQMusicClient.shared.createQRCode(type: .qq)
let image = UIImage(data: qr.imageData!)  // 显示给用户

// 轮询等待扫码
let result = try await QQMusicClient.shared.pollQRCode(qrId: qr.qrId) { status in
    if status.isConfirm { print("已扫码，等待确认") }
}
if result.isDone { print("登录成功") }
```

### 搜索歌曲

```swift
let results = try await QQMusicClient.shared.search(keyword: "周杰伦", type: .song, num: 20)

// 使用便捷转换
for song in results.asSongs {
    print("\(song.title) - \(song.artist)")
    print("封面: \(song.coverURL?.absoluteString ?? "")")
}
```

### 获取播放链接

```swift
// 单首
if let url = try await QQMusicClient.shared.songURL(mid: "001yS0N31jFfpK") {
    // 用 AVPlayer 播放
}

// 批量
let urls = try await QQMusicClient.shared.songURLs(
    mids: "001yS0N31jFfpK,003OUlho2HcRHC",
    fileType: .mp3_320
)
```

### 获取歌词

```swift
let lyric = try await QQMusicClient.shared.lyric(value: "001yS0N31jFfpK", trans: true)
if lyric.hasLyric { print(lyric.lyric!) }
if lyric.hasTranslation { print(lyric.trans!) }
```

### 排行榜

```swift
let categories = try await QQMusicClient.shared.topCategory()
let detail = try await QQMusicClient.shared.topDetail(topId: 26, num: 50)
```

### 歌手

```swift
let singers = try await QQMusicClient.shared.singerList(area: .china, sex: .male, genre: .pop)
let songs = try await QQMusicClient.shared.singerSongs(mid: "0025NhlN2yWrP4", num: 30)
let avatar = QQMusicClient.singerAvatarURL(singerMid: "0025NhlN2yWrP4")
```

### 推荐

```swift
let feed = try await QQMusicClient.shared.homeFeed()
let guess = try await QQMusicClient.shared.guessLike()
let newSongs = try await QQMusicClient.shared.recommendNewSong()
```

### 评论

```swift
let hot = try await QQMusicClient.shared.hotComments(bizId: "438910555", pageSize: 20)
let latest = try await QQMusicClient.shared.newComments(bizId: "438910555")
```

### 用户

```swift
let homepage = try await QQMusicClient.shared.userHomepage(euin: "xxx")
let vip = try await QQMusicClient.shared.vipInfo()
let favSongs = try await QQMusicClient.shared.favSongs(euin: "xxx", num: 20)
```

### 错误处理

```swift
do {
    let url = try await QQMusicClient.shared.songURL(mid: "xxx")
} catch let error as QQMusicError {
    switch error {
    case .apiError(let code, let message, _):
        print("API 错误 [\(code)]: \(message)")
    case .emptyData:
        print("无数据")
    default:
        print(error.localizedDescription)
    }
} catch {
    print("网络错误: \(error)")
}
```

## 完整 API 列表

| 模块 | 方法 | 说明 |
|------|------|------|
| **认证** | `authStatus()` | 登录状态 |
| | `createQRCode(type:)` | 获取二维码 |
| | `checkQRCode(qrId:)` | 检查扫码状态 |
| | `pollQRCode(qrId:interval:timeout:onStatusChange:)` | 轮询扫码 |
| | `sendPhoneCode(phone:countryCode:)` | 发送验证码 |
| | `phoneLogin(phone:code:countryCode:)` | 手机登录 |
| | `logout()` | 退出登录 |
| **搜索** | `hotkey()` | 热搜词 |
| | `searchComplete(keyword:)` | 搜索补全 |
| | `quickSearch(keyword:)` | 快速搜索 |
| | `generalSearch(keyword:page:highlight:)` | 综合搜索 |
| | `search(keyword:type:num:page:highlight:)` | 分类搜索 |
| **歌曲** | `querySong(value:)` | 查询歌曲信息 |
| | `songDetail(value:)` | 歌曲详情 |
| | `songURLs(mids:fileType:)` | 批量播放链接 |
| | `songURL(mid:fileType:)` | 单首播放链接 |
| | `tryURL(mid:vs:)` | 试听链接 |
| | `similarSongs(songId:)` | 相似歌曲 |
| | `songLabels(songId:)` | 歌曲标签 |
| | `relatedSonglist(songId:)` | 相关歌单 |
| | `relatedMV(songId:)` | 相关 MV |
| | `otherVersions(value:)` | 其他版本 |
| | `songProducer(value:)` | 制作信息 |
| | `songSheet(mid:)` | 曲谱 |
| | `songFavCount(songIds:)` | 收藏数 |
| **歌词** | `lyric(value:qrc:trans:roma:)` | 获取歌词 |
| **歌手** | `singerList(area:sex:genre:)` | 歌手列表 |
| | `singerInfo(mid:)` | 歌手信息 |
| | `singerDesc(mids:)` | 歌手简介 |
| | `singerSongs(mid:num:page:)` | 歌手歌曲 |
| | `singerAlbums(mid:number:begin:)` | 歌手专辑 |
| | `singerMVs(mid:number:begin:)` | 歌手 MV |
| | `similarSingers(mid:number:)` | 相似歌手 |
| | `singerSongsList(mid:number:begin:)` | 歌手歌曲原始数据 |
| | `singerAllSongs(mid:)` | 歌手全部歌曲 |
| | `singerAllAlbums(mid:)` | 歌手全部专辑 |
| | `singerAllMVs(mid:)` | 歌手全部 MV |
| | `singerListIndex(area:sex:genre:index:sin:curPage:)` | 歌手列表（按索引） |
| | `singerTabDetail(mid:tabType:page:num:)` | 歌手 Tab 详情 |
| **专辑** | `albumDetail(value:)` | 专辑详情 |
| | `albumSongs(value:num:page:)` | 专辑歌曲 |
| **排行榜** | `topCategory()` | 排行榜分类 |
| | `topDetail(topId:num:page:tag:)` | 排行榜详情 |
| **歌单** | `songlistDetail(songlistId:dirid:num:page:onlySong:tag:)` | 歌单详情 |
| | `songlistAllSongs(songlistId:dirid:)` | 歌单全部歌曲 |
| | `createSonglist(name:)` | 创建歌单 |
| | `deleteSonglist(dirid:)` | 删除歌单 |
| | `addSongsToSonglist(dirid:songIds:)` | 添加歌曲到歌单 |
| | `deleteSongsFromSonglist(dirid:songIds:)` | 从歌单删除歌曲 |
| **MV** | `mvDetail(vids:)` | MV 详情 |
| | `mvURLs(vids:)` | MV 播放链接 |
| **评论** | `commentCount(bizId:)` | 评论数量 |
| | `hotComments(bizId:pageNum:pageSize:lastSeqNo:)` | 热评 |
| | `newComments(bizId:pageNum:pageSize:lastSeqNo:)` | 最新评论 |
| | `recommendComments(bizId:pageNum:pageSize:lastSeqNo:)` | 推荐评论 |
| | `momentComments(bizId:pageSize:lastSeqNo:)` | 时刻评论 |
| **用户** | `getEuin(musicid:)` | 获取 encrypt_uin |
| | `getMusicid(euin:)` | 反查 musicid |
| | `userHomepage(euin:)` | 用户主页 |
| | `vipInfo()` | VIP 信息 |
| | `followSingers(euin:page:num:)` | 关注歌手 |
| | `fans(euin:page:num:)` | 粉丝列表 |
| | `friends(page:num:)` | 好友列表 |
| | `followUsers(euin:page:num:)` | 关注用户 |
| | `createdSonglist(uin:)` | 创建的歌单 |
| | `favSongs(euin:page:num:)` | 收藏歌曲 |
| | `favSonglists(euin:page:num:)` | 收藏歌单 |
| | `favAlbums(euin:page:num:)` | 收藏专辑 |
| | `favMVs(euin:page:num:)` | 收藏 MV |
| | `musicGene(euin:)` | 音乐基因 |
| **推荐** | `homeFeed()` | 主页推荐 |
| | `guessLike()` | 猜你喜欢 |
| | `radarRecommend()` | 雷达推荐 |
| | `recommendSonglist()` | 推荐歌单 |
| | `recommendNewSong()` | 推荐新歌 |
| **工具** | `coverURL(albumMid:size:)` | 专辑封面链接 |
| | `singerAvatarURL(singerMid:size:)` | 歌手头像链接 |

## 许可

MIT
