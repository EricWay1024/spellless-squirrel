> ### This is not stock 鼠鬚管 / Squirrel
>
> It is [rime/squirrel](https://github.com/rime/squirrel) with the two things
> the [Spellless](https://github.com/EricWay1024/spellless) schema needs from a
> frontend and cannot do for itself. Everything below this box is upstream's
> README, unmodified — including its badges, which point at upstream.
>
> [![Spellless build](https://github.com/EricWay1024/spellless-squirrel/actions/workflows/spellless-build.yml/badge.svg?branch=spellless)](https://github.com/EricWay1024/spellless-squirrel/actions/workflows/spellless-build.yml)
> [![Download](https://img.shields.io/github/v/release/EricWay1024/spellless?label=download)](https://github.com/EricWay1024/spellless/releases/latest)
>
> **What it adds.** The frontend can see the document, and a schema cannot: it
> publishes the 32 characters before the composition as Rime's
> `surrounding_text`, and it honours a commit that begins with U+0008 by taking
> that many characters of the document back. Two functions, one convention —
> [SPELLLESS.md](SPELLLESS.md) has the whole of it, including the case that
> needs empty *marked* text rather than an empty insert.
>
> **Where to get it.** `Spellless-Squirrel-<version>.pkg`, on the
> [Spellless releases page](https://github.com/EricWay1024/spellless/releases).
> It carries no schema — pair it with the `spellless-<version>.zip` there. It
> is unsigned, as upstream's own releases are: right-click → **Open** the first
> time. It installs as ordinary Squirrel, so it takes the place of a Squirrel
> you already have, and macOS will ask you to log out and back in.
>
> **It never updates itself.** Sparkle is compiled in but its feed is empty and
> automatic checks are off, because an update from upstream's feed would
> install stock Squirrel over this build and take the document features with
> it, silently. [SPARKLE.md](SPARKLE.md) says what that would have looked like
> and what publishing real updates from here would take.
>
> Licensed GPL-3.0, as upstream is.

    鼠鬚管
    爲物雖微情不淺
    新詩醉墨時一揮
    別後寄我無辭遠

    　　　——歐陽修

今由　[中州韻輸入法引擎／Rime Input Method Engine](https://rime.im)
及其他開源技術強力驅動

【鼠鬚管】輸入法
===
[![Download](https://img.shields.io/github/v/release/rime/squirrel)](https://github.com/rime/squirrel/releases/latest)
[![Build Status](https://github.com/rime/squirrel/actions/workflows/commit-ci.yml/badge.svg)](https://github.com/rime/squirrel/actions/workflows)
[![GitHub Tag](https://img.shields.io/github/tag/rime/squirrel.svg)](https://github.com/rime/squirrel)

式恕堂 版權所無

授權條款：[GPL v3](https://www.gnu.org/licenses/gpl-3.0.en.html)

項目主頁：[rime.im](https://rime.im)

您可能還需要 Rime 用於其他操作系統的發行版：

  * 【中州韻】（ibus-rime、fcitx-rime）用於 Linux
  * 【小狼毫】用於 Windows

安裝輸入法
---

本品適用於 macOS 13.0+

初次安裝，如果在部份應用程序中打不出字，請註銷並重新登錄。

使用輸入法
---

選取輸入法指示器菜單裏的【ㄓ】字樣圖標，開始用鼠鬚管寫字。
通過快捷鍵 `` Ctrl+` `` 或 `F4` 呼出方案選單、切換輸入方式。

定製輸入法
---

定製方法，請參考線上 [幫助文檔](https://rime.im/docs/)。

使用系統輸入法菜單：

  * 選中「在線文檔」可打開以上網址
  * 編輯用戶設定後，選擇「重新部署」以令修改生效

安裝輸入方案
---

使用 [/plum/](https://github.com/rime/plum) 配置管理器獲取更多輸入方案。

致謝
---

輸入方案設計：

  * 【朙月拼音】系列

    感謝 CC-CEDICT、Android 拼音、新酷音、opencc 等開源項目

程序設計：

  * 佛振
  * Linghua Zhang
  * Chongyu Zhu
  * 雪齋
  * faberii
  * Chun-wei Kuo
  * Junlu Cheng
  * Jak Wings
  * xiehuc

美術：

  * 圖標設計 佛振、梁海、雨過之後
  * 配色方案 Aben、Chongyu Zhu、skoj、Superoutman、佛振、梁海

本品引用了以下開源軟件：

  * Boost C++ Libraries  (Boost Software License)
  * capnproto (MIT License)
  * darts-clone  (New BSD License)
  * google-glog  (New BSD License)
  * Google Test  (New BSD License)
  * LevelDB  (New BSD License)
  * librime  (New BSD License)
  * OpenCC / 開放中文轉換  (Apache License 2.0)
  * plum / 東風破 (GNU Lesser General Public License 3.0)
  * Sparkle  (MIT License)
  * UTF8-CPP  (Boost Software License)
  * yaml-cpp  (MIT License)

感謝王公子捐贈開發用機。

問題與反饋
---

發現程序有 BUG，或建議，或感想，請反饋到 [Rime 代碼之家討論區](https://github.com/rime/home/discussions)

聯繫方式
---

技術交流，歡迎光臨 [Rime 代碼之家](https://github.com/rime/home)，
或致信 Rime 開發者 <rimeime@gmail.com>。

謝謝
