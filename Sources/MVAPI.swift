import Foundation

// MARK: - MV 相关 API

public extension QQMusicClient {

    /// 获取 MV 详情
    /// - Parameter vids: vid 列表，逗号分隔
    func mvDetail(vids: String) async throws -> JSON {
        try await request("/mv/get_detail", params: ["vids": vids])
    }

    /// 获取 MV 播放链接
    /// - Parameter vids: vid 列表，逗号分隔
    /// - Returns: vid -> {mp4: {}, hls: {}} 的映射
    func mvURLs(vids: String) async throws -> JSON {
        try await request("/mv/get_mv_urls", params: ["vids": vids])
    }

    /// 获取 MV 分类标签列表
    func mvTagList() async throws -> JSON {
        try await request("/mv/get_mv_tag_list")
    }

    /// 按标签获取 MV 列表
    /// - Parameters:
    ///   - area: 地区 (0=全部, 1=内地, 2=港台, 3=欧美, 4=韩国, 5=日本)
    ///   - tag: 标签 ID (0=全部)
    ///   - sort: 排序 (1=最新, 2=最热)
    ///   - num: 每页数量
    ///   - page: 页码 (从 0 开始)
    func mvByTag(area: Int = 0, tag: Int = 0, sort: Int = 1, num: Int = 20, page: Int = 0) async throws -> JSON {
        try await request("/mv/get_mv_by_tag", params: [
            "area": String(area),
            "tag": String(tag),
            "sort": String(sort),
            "num": String(num),
            "page": String(page),
        ])
    }
}
