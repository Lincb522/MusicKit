import Foundation

// MARK: - 排行榜相关 API

public extension QQMusicClient {

    /// 获取所有排行榜分类
    func topCategory() async throws -> [JSON] {
        try await request("/top/get_top_category")
    }

    /// 获取排行榜详情
    /// - Parameters:
    ///   - topId: 排行榜 id
    ///   - num: 返回数量
    ///   - page: 页码
    ///   - tag: 是否返回歌曲标签
    func topDetail(topId: Int, num: Int = 10, page: Int = 1, tag: Bool = true) async throws -> JSON {
        try await request("/top/get_detail", params: [
            "top_id": String(topId),
            "num": String(num),
            "page": String(page),
            "tag": String(tag),
        ])
    }
}
