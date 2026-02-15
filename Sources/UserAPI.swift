import Foundation

// MARK: - 用户相关 API

public extension QQMusicClient {

    /// 通过 musicid 获取 encrypt_uin
    /// - Parameter musicid: 用户 musicid
    func getEuin(musicid: Int) async throws -> JSON {
        try await request("/user/get_euin", params: ["musicid": String(musicid)])
    }

    /// 通过 encrypt_uin 反查 musicid
    /// - Parameter euin: encrypt_uin
    func getMusicid(euin: String) async throws -> JSON {
        try await request("/user/get_musicid", params: ["euin": euin])
    }

    /// 获取用户主页信息
    /// - Parameter euin: encrypt_uin
    func userHomepage(euin: String) async throws -> JSON {
        try await request("/user/get_homepage", params: ["euin": euin])
    }

    /// 获取当前登录账号的 VIP 信息
    func vipInfo() async throws -> JSON {
        try await request("/user/get_vip_info")
    }

    /// 获取关注歌手列表
    /// - Parameters:
    ///   - euin: encrypt_uin
    ///   - page: 页码
    ///   - num: 返回数量
    func followSingers(euin: String, page: Int = 1, num: Int = 10) async throws -> JSON {
        try await request("/user/get_follow_singers", params: [
            "euin": euin,
            "page": String(page),
            "num": String(num),
        ])
    }

    /// 获取粉丝列表
    /// - Parameters:
    ///   - euin: encrypt_uin
    ///   - page: 页码
    ///   - num: 返回数量
    func fans(euin: String, page: Int = 1, num: Int = 10) async throws -> JSON {
        try await request("/user/get_fans", params: [
            "euin": euin,
            "page": String(page),
            "num": String(num),
        ])
    }

    /// 获取好友列表
    /// - Parameters:
    ///   - page: 页码
    ///   - num: 返回数量
    func friends(page: Int = 1, num: Int = 10) async throws -> JSON {
        try await request("/user/get_friend", params: [
            "page": String(page),
            "num": String(num),
        ])
    }

    /// 获取关注用户列表
    /// - Parameters:
    ///   - euin: encrypt_uin
    ///   - page: 页码
    ///   - num: 返回数量
    func followUsers(euin: String, page: Int = 1, num: Int = 10) async throws -> JSON {
        try await request("/user/get_follow_user", params: [
            "euin": euin,
            "page": String(page),
            "num": String(num),
        ])
    }

    /// 获取用户创建的歌单
    /// - Parameter uin: musicid
    func createdSonglist(uin: String) async throws -> [JSON] {
        try await request("/user/get_created_songlist", params: ["uin": uin])
    }

    /// 获取收藏歌曲
    /// - Parameters:
    ///   - euin: encrypt_uin
    ///   - page: 页码
    ///   - num: 返回数量
    func favSongs(euin: String, page: Int = 1, num: Int = 10) async throws -> JSON {
        try await request("/user/get_fav_song", params: [
            "euin": euin,
            "page": String(page),
            "num": String(num),
        ])
    }

    /// 获取收藏歌单
    /// - Parameters:
    ///   - euin: encrypt_uin
    ///   - page: 页码
    ///   - num: 返回数量
    func favSonglists(euin: String, page: Int = 1, num: Int = 10) async throws -> JSON {
        try await request("/user/get_fav_songlist", params: [
            "euin": euin,
            "page": String(page),
            "num": String(num),
        ])
    }

    /// 获取收藏专辑
    /// - Parameters:
    ///   - euin: encrypt_uin
    ///   - page: 页码
    ///   - num: 返回数量
    func favAlbums(euin: String, page: Int = 1, num: Int = 10) async throws -> JSON {
        try await request("/user/get_fav_album", params: [
            "euin": euin,
            "page": String(page),
            "num": String(num),
        ])
    }

    /// 获取收藏 MV
    /// - Parameters:
    ///   - euin: encrypt_uin
    ///   - page: 页码
    ///   - num: 返回数量
    func favMVs(euin: String, page: Int = 1, num: Int = 10) async throws -> JSON {
        try await request("/user/get_fav_mv", params: [
            "euin": euin,
            "page": String(page),
            "num": String(num),
        ])
    }

    /// 获取音乐基因数据
    /// - Parameter euin: encrypt_uin
    func musicGene(euin: String) async throws -> JSON {
        try await request("/user/get_music_gene", params: ["euin": euin])
    }
}
