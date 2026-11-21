# OpenCode Desktop 的 Claude-Code 主题

[English](README.md) | **简体中文**

一个本地 OpenCode Desktop 插件，为 OpenCode Desktop 添加 **Claude-Code** 主题和
Claude 风格的排版。

- 暖纸色配色，只保留陶土色 `#D97757` 作为强调色，提供浅色和深色两套。
- 浅色模式按 Claude 的窗口分层：标签侧栏和顶栏是暖灰 `#F0EFEA`，会话区是近白
  纸色 `#FBFBF9`，正文用暖黑色。
- 深色模式下正文、标签、说明和时间戳统一使用暖灰 `#B0AEA5`；链接、代码高亮和
  实心按钮上的反白文字保留各自的颜色。
- 界面使用 Anthropic Sans，Markdown 标题使用 Anthropic Serif，字体来自你电脑上
  已安装的版本。如果没装，会依次回退到内嵌的思源拉丁字形和系统字体。
- 全界面只有一个字重，和 Claude 客户端一致：拉丁文用 Regular，中文用思源 450，
  不提供粗体变体，并关闭合成粗体。
- 中文使用内嵌的 **Source Han Sans CN** 和 **Source Han Serif SC** 子集，不需要
  在系统里安装中文字体。
- Claude 风格的界面细节：会话头部不显示项目图标，侧边栏会话列表不带项目图标，
  输入框把模型名和推理强度放在右侧、紧挨一个无边框的发送箭头，新会话显示衬线
  问候语而不是产品字标。

仓库已经包含构建好的 `dist/gui-experimental.cjs`。只有修改源码后才需要重新构建。

## 快速开始（Windows）

[下载 `install.bat`](https://github.com/PenicillinC3/opencode-claude-code-theme/raw/main/install.bat)，
双击运行。

- 把主题复制到 `%LOCALAPPDATA%\opencode-claude-code-theme`。
- 写进 `%USERPROFILE%\.config\opencode\opencode.jsonc`，保留你的注释和其他插件，
  改动前先在同目录做一份带时间戳的备份。
- 不需要 Node.js、npm，也不需要任何构建步骤。

重启 OpenCode Desktop，在 **Settings › Appearance › Theme** 里选择
**Claude-Code**。如果已经克隆了仓库，直接在仓库目录运行 `install.bat`，安装的是
这份本地副本。

## 环境要求

- OpenCode Desktop 2.2.6 或更高版本（带桌面 GUI 插件机制的版本）。
- Windows 10 或 11，用于一键安装脚本。
- 安装 Anthropic Sans 和 Anthropic Serif，才能得到预期的拉丁排版（可选，见
  [字体与覆盖范围](#字体与覆盖范围)）。
- Node.js 20+ 和 npm 只在从源码构建时需要，安装主题不需要。

## 安装

### Windows 一键安装（推荐）

1. 下载
   [`install.bat`](https://github.com/PenicillinC3/opencode-claude-code-theme/raw/main/install.bat)
   并双击运行。如果你已经克隆或解压了仓库，就在仓库目录里运行 `install.bat`，脚本会
   安装这份本地副本。
2. 脚本会下载最新的主题（约 10 MB），复制到
   `%LOCALAPPDATA%\opencode-claude-code-theme`，并把插件写进
   `%USERPROFILE%\.config\opencode\opencode.jsonc`。它会保留你配置里的注释，改动前
   先在同目录写一份带时间戳的备份，也不会动其他插件。整个过程不需要 Node.js、npm
   或任何构建步骤。
3. 重启 OpenCode Desktop，打开 **Settings › Appearance › Theme**，选择
   **Claude-Code**。

再次运行 `install.bat` 会更新已安装的副本，配置里始终只有一条记录。要移除时运行
[`uninstall.bat`](uninstall.bat)。

如果 Windows 在运行前弹出提示，选择 **更多信息 › 仍要运行**：这些脚本都是纯文本，
可以直接在仓库里查看。

### 手动安装（任意平台）

仓库可以克隆或解压到任意位置。注册时指向包含 `package.json` 的目录即可，插件
不需要固定在某个路径，运行时也不需要 `npm install`。

#### 1. 获取插件

```bash
git clone https://github.com/PenicillinC3/opencode-claude-code-theme.git
```

如果你重命名或 fork 了仓库，把 `opencode-claude-code-theme` 换成实际的仓库名。
不用 git 也可以：在 GitHub 上下载 ZIP，解压到任意目录。

#### 2. 注册插件

打开**全局** OpenCode 配置，不存在就新建：

- Windows：`%USERPROFILE%\.config\opencode\opencode.jsonc`
- macOS / Linux：`~/.config/opencode/opencode.jsonc`

保留已有配置，把插件加成一个**绝对 file URL**，指向仓库目录：

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "plugins": ["file:///absolute/path/to/opencode-claude-code-theme"]
}
```

示例：

```jsonc
// Windows
"plugins": ["file:///C:/Users/you/repos/opencode-claude-code-theme"]

// macOS
"plugins": ["file:///Users/you/repos/opencode-claude-code-theme"]

// Linux
"plugins": ["file:///home/you/repos/opencode-claude-code-theme"]
```

注意：

- 即使在 Windows 上，也使用正斜杠 `/`。
- `file://` URL 里不会展开 `~`，请写绝对路径。
- 路径含空格时，把空格转义成 `%20`，或者把仓库移到没有空格的路径。
- 安装完成后，仓库目录里应当有 `package.json`、`src/` 和 `dist/`。

#### 3. 启用主题

1. 重启 OpenCode Desktop。配置文件会被监听，但本地插件包有时需要重启才会加载。
2. 打开 **Settings › Extensions › Plugins**，确认列表里有
   `opencode-claude-code-theme`。如果是刚添加或之前加载失败，点 **Reload**。
3. 打开 **Settings › Appearance › Theme**，选择 **Claude-Code**。

## 更新

使用安装脚本时，再运行一次 `install.bat`。

使用本地仓库时，运行 `git pull`，然后重新加载插件或重启应用。如果你在本地构建
插件包，再运行一次 `npm run build`。

## 卸载

使用安装脚本时，运行 [`uninstall.bat`](uninstall.bat)。它会从 `plugins` 数组里
删除对应条目，并删除 `%LOCALAPPDATA%\opencode-claude-code-theme`。

手动卸载时，从 `plugins` 数组里删除对应条目并重新加载即可。如果只是暂时隐藏，
可以在插件 id 前加 `-`。条目删除后，直接删掉仓库目录也不会影响应用。

## 从源码构建

```bash
cd opencode-claude-code-theme
npm install
npm run typecheck
npm run build
npm run smoke
```

`npm run build` 会重新生成 `src/fonts.generated.ts`（本机 Anthropic 字体规则 +
内嵌的中文子集），并输出 `dist/gui-experimental.cjs`（约 4.65 MB，gzip 后约
3.5 MB）。

### 重新生成中文子集

只有修改 `assets/gb2312.txt` 或垂直压缩比例后才需要：

```bash
python -m pip install fonttools brotli
npm run subset
npm run build
```

仓库不包含思源可变字体原文件。需要重建时，把它们放到仓库旁边的 `source/` 目录
（子集脚本查找的是 `../source/`）：

- `../source/SourceHanSansCN-VF.otf`
- `../source/SourceHanSerifSC-VF.otf.ttf`

可以从 Adobe 的
[Source Han Sans](https://github.com/adobe-fonts/source-han-sans/releases) 和
[Source Han Serif](https://github.com/adobe-fonts/source-han-serif/releases)
发布页获取。

`assets/fonts/` 里生成好的 WOFF2 已经提交到仓库，所以普通安装和构建不需要这些
可变字体。

## 改了什么

插件通过实验性的桌面插件 API 注册两样东西：

- 一个名为 `Claude-Code`（`claude-code`）的 `Theme`；
- 一份 `Style` 样式表，包含 `@font-face` 规则和排版覆盖。

应用通过 `--font-family-sans` 和 `--font-family-mono` 解析字体，再派生出
`--font-family-text`、`--v2-font-family-sans` 和 `--v2-font-family-code`。插件在
`html:root` 上覆盖这些变量，因此不受样式表顺序影响。Markdown 的 `h1`–`h3` 使用
Anthropic Serif（中文为思源宋体），推理过程保持无衬线。

输入框的字号从应用的 13 px 提到正文的 14 px，行高仍保持 20 px，这样输入的内容
和上方消息在字号与压缩比例上完全一致。

Claude 的侧边栏会话列表是纯文本的：每行没有项目图标。主题移除了图标和它占用的
16 px 槽位，所以会话标题从列表左边缘开始，而不是排在头像列之后。未读和活动标记
仍留在行尾。无论是否是当前会话，标题都使用同一种安静的灰色（`#3d3d3a`），输入框
的占位文字也使用这个灰色。

Claude 的会话头部只写项目名，不带图标，所以会话位置卡片里的项目头像被隐藏，项目
名和面包屑文字保留。位置菜单里更大的头像不受影响。

Claude 把模型名和推理强度放在输入框右端、紧挨发送箭头，Agent 控件留在左侧。发送
控件是一个安静的无边框箭头，而不是带框按钮：保留原生 28 px 点击区域和图标、透明
填充和弱化的箭头，悬停时只加一层很淡的填充。运行中的停止方块和加载指示器保持同样
的处理。

Claude 打开新会话时显示的是一句问候，而不是 logo：动画 OpenCode 字标和它的图钉
画布被隐藏，换成一行 Anthropic Serif 的 `You're here!`。字标的盒子仍保留高度，所以
输入框不会移动。新会话的列宽收窄到 680 px，对应 Claude 那一条居中的问候、输入框和
项目行。项目行里的头像色块换成了应用自带的文件夹描边图标，使用触发器的文字颜色。

这些界面覆盖是针对 OpenCode Desktop 2.2.x 的 DOM 写的。主题、字体和配色是稳定的，
但未来的应用版本可能重命名侧边栏、输入框或问候语背后的元素。

## 字体与覆盖范围

| 字体家族                    | 用途          | 来源                                       |
| --------------------------- | ------------- | ------------------------------------------ |
| Anthropic Sans Text 400     | 界面文字      | 本机安装：`Anthropic Sans Text`            |
| Anthropic Serif Display 400 | Markdown 标题 | 本机安装：`Anthropic Serif Display`        |
| Anthropic Serif Display 300 | 新会话问候语  | 本机安装：`Anthropic Serif Display`        |
| Source Han Sans CN 450      | 中文界面      | 内嵌，源文件 `SourceHanSansCN-VF.otf`      |
| Source Han Serif SC 450     | 中文标题      | 内嵌，源文件 `SourceHanSerifSC-VF.otf.ttf` |

Anthropic 字体不打进插件。主题用 `local()` 绑定它们，只有本机安装了才会使用；
否则字体栈会继续走到内嵌的思源子集，再到系统字体。

### 字体去哪里找

Anthropic 字体是专有字体，本仓库不附带。主题的 `local()` 规则查找的是本机安装的
`Anthropic Sans Text` 和 `Anthropic Serif Display`。如果没有从 Anthropic 获取过
字体，可以使用第三方镜像：

- [matthieuhuguet/anthropic-fonts](https://github.com/matthieuhuguet/anthropic-fonts)
  提供可变字体 TTF 和 WOFF2。它是非官方的第三方镜像，仓库自述为 "personal use
  only, not my IP"。安装后的家族名是 `AnthropicSans` 和 `AnthropicSerif`，
  与主题的 `local()` 查找不匹配，因此会使用内嵌的回退字体。

该链接仅为方便提供，与本项目无关。下载或使用前请自行确认 Anthropic 的授权条款，
不要转发字体文件。

中文字体子集到 GB2312：7,402 个码位，覆盖常用中文、拉丁字母和标点，这样包体才
可控。子集之外的字符、日文假名和韩文会回退到系统 CJK 字体（`PingFang SC`、
`Microsoft YaHei`、`Noto Sans CJK SC`、`SimSun` 等）。

思源字形在 450 字重上实例化，并只做 **垂直方向 7.5%** 的压缩（水平步进和宽度不变）。
思源黑体的竖画又长又细，在小字号下会比拉丁界面字体显得更高；这点垂直修正能让中英
混排行看起来齐平。

每个字体家族只暴露一个字形，声明覆盖完整的 `100 900` 字重范围，并关闭合成粗体。
拉丁家族通过 `local()` 绑定到已安装的 Regular 字形，所以中等和粗体文字看起来和正文
完全一致，不会切换到更重的已安装字重，也不会伪造粗体。唯一的例外是新会话问候语：
它绑定已安装的 Light Display 字形，比标题衬线轻一档。如果没装 Light，会回退到
Regular Display。

## 常见问题

**主题列表里没有 Claude-Code。** 检查配置文件是否是当前平台的全局配置、`plugins`
条目是否指向包含 `package.json` 的仓库目录，以及
**Settings › Extensions › Plugins** 里是否能看到插件。修正路径后重启应用。

**拉丁文字看起来像中文字体。** 说明 Anthropic 字体没安装，或者应用看不到它们。
安装 Anthropic Sans Text 和 Anthropic Serif Display（见
[字体去哪里找](#字体去哪里找)），然后重启 OpenCode Desktop。

**侧边栏、输入框或问候语的覆盖失效了。** 多半是应用版本改了 DOM。对照环境要求
检查版本，并在 issue 里附上版本号。

## 许可

- **主题和插件代码**采用 MIT 许可，见 [LICENSE](LICENSE)。
- **Anthropic Sans 和 Anthropic Serif** 是 Anthropic 的专有字体。本仓库不包含
  它们，插件只使用本机安装的副本。请不要转发字体文件。
- **Source Han Sans / Source Han Serif** 采用 SIL Open Font License 1.1
  （<https://openfontlicense.org>）。内嵌的子集沿用同一许可。

MIT 许可覆盖代码和主题定义，不覆盖字体文件。

## 目录结构

```text
opencode-claude-code-theme/
  README.md
  README.zh-CN.md
  .gitattributes
  .gitignore
  LICENSE
  install.bat            一键安装（Windows）
  install.ps1            安装脚本本体，也负责 -Uninstall
  uninstall.bat          一键卸载（Windows）
  src/
    index.ts             服务器端插件入口
    gui.ts               桌面 GUI 入口（Theme + Style）
    theme.ts             Claude-Code 配色
    fonts.generated.ts   生成：local @font-face 规则 + 内嵌中文 + CSS
  scripts/
    embed-fonts.mjs      生成字体 CSS：本机 Anthropic 字体 + 内嵌中文
    build-cjk-fonts.py   中文子集化、实例化并做垂直压缩
    subset-fonts.ps1     重新生成 GB2312 WOFF2 子集
    smoke-test.cjs       加载构建产物并检查注册结果
  assets/
    fonts/               内嵌的中文子集
    gb2312.txt           子集码位表
  dist/
    gui-experimental.cjs 构建好的桌面插件包
```

`source/` 放在仓库旁边，不提交到仓库。里面有 Anthropic 的专有字体文件和大体积
可变字体，只有重建中文子集时才需要它。

桌面 GUI 插件 API 仍是实验性的（`./gui-experimental`），未来的应用版本可能改变
导入或加载方式。服务器入口和主题格式属于稳定的插件 API。
