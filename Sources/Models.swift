import Foundation

// MARK: - 统一响应

/// API 统一响应结构
public struct APIResponse<T: Decodable>: Decodable {
    /// 状态码（200 为成功）
    public let code: Int
    /// 消息
    public let message: String
    /// 数据
    public let data: T?
    /// 错误列表
    public let errors: [String]?
    /// 时间戳
    public let timestamp: Int?
}

// MARK: - 错误

/// QQ音乐 API 错误
public enum QQMusicError: LocalizedError {
    /// URL 构造失败
    case invalidURL(String)
    /// 响应格式无效
    case invalidResponse
    /// 响应数据为空
    case emptyData
    /// API 返回错误
    case apiError(code: Int, message: String, errors: [String]?)
    /// 未登录
    case notLoggedIn

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let path):
            return "无效的URL: \(path)"
        case .invalidResponse:
            return "服务器响应格式无效"
        case .emptyData:
            return "响应数据为空"
        case .apiError(let code, let message, let errors):
            let detail = errors?.joined(separator: "; ") ?? ""
            return "[\(code)] \(message)\(detail.isEmpty ? "" : " - \(detail)")"
        case .notLoggedIn:
            return "未登录，请先扫码登录"
        }
    }
}

// MARK: - JSON 动态类型

/// 通用 JSON 值，用于处理动态结构的 API 响应
public enum JSON: Decodable, CustomStringConvertible {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case array([JSON])
    case object([String: JSON])
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() { self = .null }
        else if let v = try? container.decode(Bool.self) { self = .bool(v) }
        else if let v = try? container.decode(Int.self) { self = .int(v) }
        else if let v = try? container.decode(Double.self) { self = .double(v) }
        else if let v = try? container.decode(String.self) { self = .string(v) }
        else if let v = try? container.decode([JSON].self) { self = .array(v) }
        else if let v = try? container.decode([String: JSON].self) { self = .object(v) }
        else { self = .null }
    }

    /// 获取字符串值
    public var stringValue: String? {
        if case .string(let v) = self { return v }
        if case .int(let v) = self { return String(v) }
        return nil
    }

    /// 获取整数值
    public var intValue: Int? {
        if case .int(let v) = self { return v }
        if case .double(let v) = self { return Int(v) }
        if case .string(let v) = self { return Int(v) }
        return nil
    }

    /// 获取浮点值
    public var doubleValue: Double? {
        if case .double(let v) = self { return v }
        if case .int(let v) = self { return Double(v) }
        return nil
    }

    /// 获取布尔值
    public var boolValue: Bool? {
        if case .bool(let v) = self { return v }
        return nil
    }

    /// 获取数组
    public var arrayValue: [JSON]? {
        if case .array(let v) = self { return v }
        return nil
    }

    /// 获取字典
    public var objectValue: [String: JSON]? {
        if case .object(let v) = self { return v }
        return nil
    }

    /// 下标访问字典
    public subscript(key: String) -> JSON? {
        objectValue?[key]
    }

    /// 下标访问数组
    public subscript(index: Int) -> JSON? {
        guard let arr = arrayValue, index >= 0, index < arr.count else { return nil }
        return arr[index]
    }

    public var description: String {
        switch self {
        case .string(let v): return "\"\(v)\""
        case .int(let v): return "\(v)"
        case .double(let v): return "\(v)"
        case .bool(let v): return "\(v)"
        case .null: return "null"
        case .array(let v): return "[\(v.map(\.description).joined(separator: ", "))]"
        case .object(let v):
            let pairs = v.map { "\"\($0.key)\": \($0.value)" }
            return "{\(pairs.joined(separator: ", "))}"
        }
    }
}

// MARK: - 认证模型

/// 登录状态
public struct AuthStatus: Decodable, Sendable {
    /// 是否已登录
    public let loggedIn: Bool
    /// 音乐 ID
    public let musicid: Int?
    /// 登录类型
    public let loginType: Int?

    enum CodingKeys: String, CodingKey {
        case loggedIn = "logged_in"
        case musicid
        case loginType = "login_type"
    }
}

/// 二维码信息
public struct QRCode: Decodable, Sendable {
    /// 二维码 ID（用于轮询状态）
    public let qrId: String
    /// Base64 图片（data:image/png;base64,...）
    public let image: String

    enum CodingKeys: String, CodingKey {
        case qrId = "qr_id"
        case image
    }

    /// 获取图片二进制数据
    public var imageData: Data? {
        guard let base64 = image.components(separatedBy: ",").last else { return nil }
        return Data(base64Encoded: base64)
    }
}

/// 二维码扫码状态
public struct QRCodeStatus: Decodable, Sendable {
    /// 状态字符串：SCAN / CONF / DONE / TIMEOUT / REFUSE
    public let status: String
    /// 登录成功时返回的 musicid
    public let musicid: Int?

    /// 等待扫码
    public var isScan: Bool { status == "SCAN" }
    /// 已扫码，等待确认
    public var isConfirm: Bool { status == "CONF" }
    /// 登录成功
    public var isDone: Bool { status == "DONE" }
    /// 二维码过期
    public var isTimeout: Bool { status == "TIMEOUT" }
    /// 用户拒绝
    public var isRefused: Bool { status == "REFUSE" }
    /// 是否为终态（不需要继续轮询）
    public var isFinal: Bool { isDone || isTimeout || isRefused }
}

/// 手机验证码发送状态
public struct PhoneSendStatus: Decodable, Sendable {
    /// 状态：SEND / CAPTCHA
    public let status: String
    /// 验证链接（需要滑块验证时返回）
    public let url: String?

    /// 是否发送成功
    public var isSent: Bool { status == "SEND" }
    /// 是否需要验证
    public var needCaptcha: Bool { status == "CAPTCHA" }
}

// MARK: - 歌词模型

/// 歌词结果
public struct LyricResult: Decodable, Sendable {
    /// 原文歌词
    public let lyric: String?
    /// 翻译歌词
    public let trans: String?
    /// 罗马音歌词
    public let roma: String?

    /// 是否有歌词
    public var hasLyric: Bool { lyric != nil && !(lyric?.isEmpty ?? true) }
    /// 是否有翻译
    public var hasTranslation: Bool { trans != nil && !(trans?.isEmpty ?? true) }
}

// MARK: - 枚举

/// 二维码登录类型
public enum QRLoginType: String, Sendable {
    case qq = "qq"
    case wx = "wx"
}

/// 搜索类型
public enum SearchType: String, Sendable {
    /// 歌曲
    case song = "SONG"
    /// 歌手
    case singer = "SINGER"
    /// 专辑
    case album = "ALBUM"
    /// 歌单
    case songlist = "SONGLIST"
    /// MV
    case mv = "MV"
    /// 歌词
    case lyric = "LYRIC"
    /// 用户
    case user = "USER"
}

/// 歌曲文件类型
public enum SongFileType: String, Sendable, CaseIterable {
    /// 臻品母带 24Bit 192kHz
    case master = "MASTER"
    /// 臻品全景声 16Bit 44.1kHz
    case atmos2 = "ATMOS_2"
    /// 臻品音质 16Bit 44.1kHz
    case atmos51 = "ATMOS_51"
    /// FLAC 无损 16Bit~24Bit
    case flac = "FLAC"
    /// OGG 640kbps
    case ogg640 = "OGG_640"
    /// OGG 320kbps
    case ogg320 = "OGG_320"
    /// OGG 192kbps
    case ogg192 = "OGG_192"
    /// OGG 96kbps
    case ogg96 = "OGG_96"
    /// MP3 320kbps
    case mp3_320 = "MP3_320"
    /// MP3 128kbps
    case mp3_128 = "MP3_128"
    /// AAC 192kbps
    case aac192 = "ACC_192"
    /// AAC 96kbps
    case aac96 = "ACC_96"
    /// AAC 48kbps
    case aac48 = "ACC_48"

    /// 显示名称
    public var displayName: String {
        switch self {
        case .master:  return "臻品母带 (24Bit 192kHz)"
        case .atmos2:  return "臻品全景声"
        case .atmos51: return "臻品音质"
        case .flac:    return "FLAC 无损"
        case .ogg640:  return "OGG 640kbps"
        case .ogg320:  return "OGG 320kbps"
        case .ogg192:  return "OGG 192kbps"
        case .ogg96:   return "OGG 96kbps"
        case .mp3_320: return "MP3 320kbps"
        case .mp3_128: return "MP3 128kbps"
        case .aac192:  return "AAC 192kbps"
        case .aac96:   return "AAC 96kbps"
        case .aac48:   return "AAC 48kbps"
        }
    }

    /// 常用音质选项（供 UI 选择器使用）
    public static var commonOptions: [SongFileType] {
        [.master, .flac, .ogg320, .mp3_320, .mp3_128, .aac96]
    }
}

/// 歌手地区
public enum AreaType: String, Sendable {
    case all = "ALL"
    case china = "CHINA"
    case taiwan = "TAIWAN"
    case america = "AMERICA"
    case japan = "JAPAN"
    case korea = "KOREA"
}

/// 歌手性别/组合
public enum SexType: String, Sendable {
    case all = "ALL"
    case male = "MALE"
    case female = "FEMALE"
    case group = "GROUP"
}

/// 歌手 Tab 类型
public enum SingerTabType: String, Sendable {
    /// 百科
    case wiki = "wiki"
    /// 演唱歌曲
    case song = "song_sing"
    /// 专辑
    case album = "album"
    /// 作曲
    case composer = "song_composing"
    /// 作词
    case lyricist = "song_lyric"
    /// 制作人
    case producer = "producer"
    /// 编曲
    case arranger = "arranger"
    /// 乐手
    case musician = "musician"
    /// 视频
    case video = "video"
}

/// 歌手风格
public enum GenreType: String, Sendable {
    case all = "ALL"
    case pop = "POP"
    case rap = "RAP"
    case rock = "ROCK"
    case electronic = "ELECTRONIC"
    case folk = "FOLK"
    case rnb = "R_AND_B"
    case jazz = "JAZZ"
    case classical = "CLASSICAL"
}
