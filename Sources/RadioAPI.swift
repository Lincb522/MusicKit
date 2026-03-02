import Foundation

// MARK: - 电台相关 API

public extension QQMusicClient {

    /// 获取电台分类列表
    func radioList() async throws -> JSON {
        try await request("/radio/get_radio_list")
    }

    /// 获取电台歌曲
    /// - Parameters:
    ///   - radioId: 电台 ID
    ///   - num: 返回歌曲数量
    func radioSongs(radioId: Int, num: Int = 20) async throws -> JSON {
        try await request("/radio/get_radio_songs", params: [
            "radio_id": String(radioId),
            "num": String(num),
        ])
    }

    /// 获取私人电台（心动模式）
    /// - Parameter num: 返回歌曲数量
    func personalRadio(num: Int = 20) async throws -> JSON {
        try await request("/radio/get_personal_radio", params: ["num": String(num)])
    }
}
