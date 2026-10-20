import AppKit

/// Ya cap 设计规范 - 基于 Semi Design
enum DesignTokens {

    // MARK: - Colors

    enum Colors {
        // 品牌色
        static let primary = NSColor(calibratedRed: 0.20, green: 0.44, blue: 1.0, alpha: 1.0) // #3370FF
        static let primaryHover = NSColor(calibratedRed: 0.25, green: 0.50, blue: 1.0, alpha: 1.0) // #4080FF
        static let primaryActive = NSColor(calibratedRed: 0.17, green: 0.36, blue: 0.82, alpha: 1.0) // #2B5DD1

        // 功能色
        static let success = NSColor(calibratedRed: 0.04, green: 0.63, blue: 0.36, alpha: 1.0) // #0BA05D
        static let warning = NSColor(calibratedRed: 1.0, green: 0.49, blue: 0.0, alpha: 1.0) // #FF7D00
        static let danger = NSColor(calibratedRed: 0.85, green: 0.10, blue: 0.10, alpha: 1.0) // #D91A1A
        static let info = primary // #3370FF

        // 功能色 - 深色背景上的浅色变体（保证对比度）
        /// 强调文本、链接
        static let primaryLight = NSColor(calibratedRed: 0.42, green: 0.66, blue: 0.98, alpha: 1.0) // #6BA8FA
        /// 柔和警示文本
        static let warningSoft = NSColor(calibratedRed: 0.95, green: 0.55, blue: 0.45, alpha: 1.0) // #F28C73
        static let dangerLight = NSColor(calibratedRed: 1.00, green: 0.37, blue: 0.35, alpha: 1.0) // #FF5F59
        static let warningLight = NSColor(calibratedRed: 1.00, green: 0.74, blue: 0.18, alpha: 1.0) // #FFBD2E
        static let successLight = NSColor(calibratedRed: 0.31, green: 0.79, blue: 0.31, alpha: 1.0) // #4FC94F

        // 中性色 - 文本
        /// 标题、强调文本（Semi dark $color-text-0）
        static let textPrimary = NSColor.white.withAlphaComponent(0.95)
        /// 正文、说明文本（Semi dark $color-text-1）
        static let textSecondary = NSColor.white.withAlphaComponent(0.70)
        /// 辅助、状态文本（Semi dark $color-text-2）
        static let textTertiary = NSColor.white.withAlphaComponent(0.50)
        /// 装饰性图标、箭头（Semi dark $color-text-3）
        static let textQuaternary = NSColor.white.withAlphaComponent(0.32)
        /// 禁用态
        static let textDisabled = NSColor.white.withAlphaComponent(0.35)

        // 中性色 - 背景和边框
        static let border = NSColor.white.withAlphaComponent(0.08)
        static let borderStrong = NSColor.white.withAlphaComponent(0.14)
        static let divider = NSColor.white.withAlphaComponent(0.06)
        static let backgroundOverlay = NSColor.white.withAlphaComponent(0.04)
        static let backgroundInput = NSColor.white.withAlphaComponent(0.06)
        static let backgroundHover = NSColor.white.withAlphaComponent(0.08)
        static let backgroundActive = NSColor.white.withAlphaComponent(0.12)
        static let backgroundSunken = NSColor.black.withAlphaComponent(0.22)

        // 表面色 - 窗口与面板渐变（深色主题底层）
        /// 窗口背景渐变（左上 → 右下）
        static let windowGradientStart = NSColor(calibratedRed: 0.10, green: 0.13, blue: 0.17, alpha: 1.0) // #1A2129
        static let windowGradientMid = NSColor(calibratedRed: 0.08, green: 0.10, blue: 0.14, alpha: 1.0) // #141A24
        static let windowGradientEnd = NSColor(calibratedRed: 0.11, green: 0.10, blue: 0.10, alpha: 1.0) // #1C1A1A
        /// 侧边栏面板渐变
        static let sidebarGradientStart = NSColor(calibratedRed: 0.11, green: 0.17, blue: 0.25, alpha: 1.0) // #1C2B40
        static let sidebarGradientEnd = NSColor(calibratedRed: 0.08, green: 0.12, blue: 0.18, alpha: 1.0) // #141F2E
        /// 内容面板渐变
        static let detailGradientStart = NSColor(calibratedRed: 0.13, green: 0.14, blue: 0.17, alpha: 1.0) // #21242B
        static let detailGradientEnd = NSColor(calibratedRed: 0.10, green: 0.11, blue: 0.13, alpha: 1.0) // #1A1C21

        // 控件填充色
        /// 选中态导航项背景
        static let primarySelected = NSColor(calibratedRed: 0.22, green: 0.40, blue: 0.85, alpha: 1.0) // #3866D9
        /// 滑块手柄渐变
        static let knobGradientStart = NSColor(calibratedRed: 0.74, green: 0.78, blue: 0.85, alpha: 1.0) // #BDC7D9
        static let knobGradientEnd = NSColor(calibratedRed: 0.60, green: 0.64, blue: 0.72, alpha: 1.0) // #99A3B8

        // 中性色 - 选中态叠加（用于高饱和背景之上）
        static let overlayOnAccent = NSColor.white.withAlphaComponent(0.22)
        static let overlayOnAccentBorder = NSColor.white.withAlphaComponent(0.30)

        // Tab 图标色（保留原有语义化颜色）
        static let tabGray = NSColor(calibratedRed: 0.62, green: 0.66, blue: 0.72, alpha: 1.0)
        static let tabBlue = NSColor(calibratedRed: 0.36, green: 0.66, blue: 0.98, alpha: 1.0)
        static let tabPink = NSColor(calibratedRed: 0.95, green: 0.54, blue: 0.62, alpha: 1.0)
        static let tabCyan = NSColor(calibratedRed: 0.38, green: 0.80, blue: 0.78, alpha: 1.0)
        static let tabGreen = NSColor(calibratedRed: 0.36, green: 0.78, blue: 0.50, alpha: 1.0)
        static let tabPurple = NSColor(calibratedRed: 0.70, green: 0.56, blue: 0.96, alpha: 1.0)
    }

    // MARK: - Border Radius

    enum BorderRadius {
        static let small: CGFloat = 4  // 按钮、标签、徽章
        static let medium: CGFloat = 8  // 卡片、输入框
        static let large: CGFloat = 12  // 弹窗、面板
        static let sidebar: CGFloat = 22  // 侧边栏外壳
        static let panel: CGFloat = 24  // 内容面板外壳
        static let full: CGFloat = 9999  // 完全圆角
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 12
        static let l: CGFloat = 16
        static let xl: CGFloat = 20
        static let xxl: CGFloat = 24
    }

    // MARK: - Typography

    enum Typography {
        // 字号
        enum FontSize {
            static let header: CGFloat = 16
            static let regular: CGFloat = 14
            static let small: CGFloat = 12
            static let tiny: CGFloat = 10
        }

        // 字重
        enum FontWeight {
            static let regular: NSFont.Weight = .regular    // 400
            static let medium: NSFont.Weight = .medium      // 500
            static let semibold: NSFont.Weight = .semibold  // 600
            static let bold: NSFont.Weight = .bold          // 700
        }

        // 行高
        enum LineHeight {
            static let compact: CGFloat = 1.2   // 标题
            static let normal: CGFloat = 1.5    // 正文
            static let relaxed: CGFloat = 1.7   // 长文本
        }
    }

    // MARK: - Shadows

    enum Shadow {
        static let small: NSShadow = {
            let shadow = NSShadow()
            shadow.shadowColor = NSColor.black.withAlphaComponent(0.12)
            shadow.shadowOffset = NSSize(width: 0, height: -1)
            shadow.shadowBlurRadius = 2
            return shadow
        }()

        static let medium: NSShadow = {
            let shadow = NSShadow()
            shadow.shadowColor = NSColor.black.withAlphaComponent(0.15)
            shadow.shadowOffset = NSSize(width: 0, height: -2)
            shadow.shadowBlurRadius = 8
            return shadow
        }()

        static let large: NSShadow = {
            let shadow = NSShadow()
            shadow.shadowColor = NSColor.black.withAlphaComponent(0.2)
            shadow.shadowOffset = NSSize(width: 0, height: -4)
            shadow.shadowBlurRadius = 16
            return shadow
        }()
    }

    // MARK: - Animation

    enum Animation {
        static let durationFast: TimeInterval = 0.15
        static let durationNormal: TimeInterval = 0.25
        static let durationSlow: TimeInterval = 0.35

        static let timingFunction = CAMediaTimingFunction(controlPoints: 0.4, 0, 0.2, 1)
    }
}
