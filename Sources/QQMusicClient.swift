import Foundation
#if canImport(os)
import os
#endif

/// QQ音乐 API 客户端
///
/// 所有 API 请求的入口，支持配置服务器地址、超时时间、重试策略。
///
/// 基本用法：
/// ```swift
/// QQMusicClient.configure(baseURL: URL(string: "http://你的IP:8000")!)
/// let songs = try await QQMusicClient.shared.search(keyword: "周杰伦")
/// ```
public final class QQMusicClient: @unchecked Sendable {

    // MARK: - 属性

    /// 服务器地址
    public let baseURL: URL

    /// 请求超时时间（秒）
    public let timeout: TimeInterval

    /// 最大重试次数
    public let maxRetries: Int

    /// URLSession
    private let session: URLSession

    #if canImport(os)
    /// 日志
    private static let logger = Logger(subsystem: "QQMusicKit", category: "Network")
    #endif

    // MARK: - 单例

    /// 共享实例（需先调用 configure 设置服务器地址）
    public static var shared = QQMusicClient(baseURL: URL(string: "http://localhost:8000")!)

    /// 配置共享实例
    /// - Parameters:
    ///   - baseURL: 服务器地址
    ///   - timeout: 请求超时时间，默认 30 秒
    ///   - maxRetries: 最大重试次数，默认 1
    public static func configure(
        baseURL: URL,
        timeout: TimeInterval = 30,
        maxRetries: Int = 1
    ) {
        shared = QQMusicClient(baseURL: baseURL, timeout: timeout, maxRetries: maxRetries)
    }

    // MARK: - 初始化

    /// 创建客户端实例
    /// - Parameters:
    ///   - baseURL: 服务器地址
    ///   - timeout: 请求超时时间
    ///   - maxRetries: 最大重试次数
    ///   - session: 自定义 URLSession
    public init(
        baseURL: URL,
        timeout: TimeInterval = 30,
        maxRetries: Int = 1,
        session: URLSession? = nil
    ) {
        self.baseURL = baseURL
        self.timeout = timeout
        self.maxRetries = maxRetries

        if let session {
            self.session = session
        } else {
            let config = URLSessionConfiguration.default
            config.timeoutIntervalForRequest = timeout
            config.timeoutIntervalForResource = timeout * 2
            self.session = URLSession(configuration: config)
        }
    }

    // MARK: - 网络请求

    /// 发送 GET 请求并解码响应
    /// - Parameters:
    ///   - path: 请求路径
    ///   - params: 查询参数
    /// - Returns: 解码后的数据
    func request<T: Decodable>(_ path: String, params: [String: String] = [:]) async throws -> T {
        let data = try await rawRequest(path, params: params)
        let response = try JSONDecoder().decode(APIResponse<T>.self, from: data)

        guard response.code == 200 else {
            throw QQMusicError.apiError(
                code: response.code,
                message: response.message,
                errors: response.errors
            )
        }

        guard let result = response.data else {
            throw QQMusicError.emptyData
        }

        return result
    }

    /// 发送 GET 请求，返回原始 APIResponse
    func requestRaw(_ path: String, params: [String: String] = [:]) async throws -> APIResponse<JSON> {
        let data = try await rawRequest(path, params: params)
        return try JSONDecoder().decode(APIResponse<JSON>.self, from: data)
    }

    /// 底层请求方法（带重试）
    private func rawRequest(_ path: String, params: [String: String]) async throws -> Data {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw QQMusicError.invalidURL(path)
        }

        if !params.isEmpty {
            components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }

        guard let url = components.url else {
            throw QQMusicError.invalidURL(path)
        }

        var lastError: Error?

        for attempt in 0...maxRetries {
            do {
                #if canImport(os)
                if attempt > 0 {
                    Self.logger.info("重试请求 (\(attempt)/\(self.maxRetries)): \(path)")
                }
                #endif

                let (data, response) = try await session.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw QQMusicError.invalidResponse
                }

                #if canImport(os)
                Self.logger.debug("\(httpResponse.statusCode) \(path)")
                #endif

                return data

            } catch {
                lastError = error

                // 不重试客户端错误
                if let musicError = error as? QQMusicError {
                    throw musicError
                }

                // 最后一次不等待
                if attempt < maxRetries {
                    let delay = UInt64(pow(2.0, Double(attempt))) * 1_000_000_000
                    try await Task.sleep(nanoseconds: delay)
                }
            }
        }

        throw lastError ?? QQMusicError.invalidResponse
    }
}
