import Foundation

// MARK: - 推荐相关 API

public extension QQMusicClient {

    /// 获取主页推荐
    func homeFeed() async throws -> JSON {
        try await request("/recommend/get_home_feed")
    }

    /// 获取猜你喜欢
    func guessLike() async throws -> JSON {
        try await request("/recommend/get_guess_recommend")
    }

    /// 获取雷达推荐
    func radarRecommend() async throws -> JSON {
        try await request("/recommend/get_radar_recommend")
    }

    /// 获取推荐歌单
    func recommendSonglist() async throws -> JSON {
        try await request("/recommend/get_recommend_songlist")
    }

    /// 获取推荐新歌
    func recommendNewSong() async throws -> JSON {
        try await request("/recommend/get_recommend_newsong")
    }

    /// 获取歌单广场所有分类标签
    func songlistCategories() async throws -> JSON {
        try await request("/recommend/get_songlist_categories")
    }

    /// 按分类标签获取歌单列表
    /// - Parameters:
    ///   - categoryId: 分类标签 ID (10000000=全部)
    ///   - sortId: 排序方式 (5=推荐, 2=最新, 3=最热)
    ///   - page: 页码 (从 0 开始)
    ///   - size: 每页数量
    func songlistByCategory(categoryId: Int = 10000000, sortId: Int = 5, page: Int = 0, size: Int = 30) async throws -> JSON {
        try await request("/recommend/get_songlist_by_category", params: [
            "category_id": String(categoryId),
            "sort_id": String(sortId),
            "page": String(page),
            "size": String(size),
        ])
    }

    /// 获取每日个性化推荐歌曲
    /// - Parameter num: 推荐数量
    func dailyRecommend(num: Int = 30) async throws -> JSON {
        try await request("/recommend/get_daily_recommend", params: ["num": String(num)])
    }

    /// 获取新碟上架
    /// - Parameters:
    ///   - area: 地区 (1=内地, 2=港台, 3=欧美, 4=韩国, 5=日本, 6=其他)
    ///   - num: 每页数量
    ///   - page: 页码 (从 0 开始)
    func newAlbums(area: Int = 1, num: Int = 20, page: Int = 0) async throws -> JSON {
        try await request("/recommend/get_new_albums", params: [
            "area": String(area),
            "num": String(num),
            "page": String(page),
        ])
    }

    /// 获取推荐/热门 MV
    /// - Parameters:
    ///   - area: 地区 (0=全部, 1=内地, 2=港台, 3=欧美, 4=韩国, 5=日本)
    ///   - num: 每页数量
    ///   - page: 页码 (从 0 开始)
    func mvRecommend(area: Int = 0, num: Int = 20, page: Int = 0) async throws -> JSON {
        try await request("/recommend/get_mv_recommend", params: [
            "area": String(area),
            "num": String(num),
            "page": String(page),
        ])
    }
}
