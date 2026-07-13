# RLC回路モデリング — 演習教材

RLC回路を題材に、物理現象のモデリングについて学ぶ演習教材です。MATLAB の Live Script で **R → L → RL → RLC** の順に理解を深め、Simulink でシミュレーションを行います。

---

## 目次

1. [教材の構成](#教材の構成)
2. [必要な環境](#必要な環境)
3. [MathWorks アカウントの作成](#mathworks-アカウントの作成)
4. [MATLAB のインストール](#matlab-のインストール)
5. [GitHub から教材を取得する](#github-から教材を取得する)
6. [教材の使い方](#教材の使い方)
7. [よくあるトラブルと対処](#よくあるトラブルと対処)
8. [参考リンク](#参考リンク)

---

## 教材の構成

| ファイル / フォルダ | 内容 |
|----------|------|
| `RLC_Modeling_Lecture.m` | メイン教材（Live Script 形式） |
| `RLC_Model.slx` | Simulink シミュレーション用モデル（第3章で使用） |
| `simulink-utils/` | Simulink 実行用ヘルパー（`simulateRLCModel.m`） |
| `plot-utils/` | グラフ描画ヘルパー（白背景・入力/出力2段プロット） |
| `setupRLCPaths.m` | 教材用パス設定（`simulink-utils` / `plot-utils` を追加） |
| `circuit-plots/` | 回路図生成スクリプト |
| `README.md` | 本ファイル（セットアップ手順） |

---

## 必要な環境

| 項目 | 要件 |
|------|------|
| OS | Windows 10 / 11（64bit）推奨 |
| MATLAB | **R2025b 以降**（必須） |
| Simulink | 第3章以降で使用（ライセンスに含まれていること） |
| ストレージ | 空き容量 約 10 GB 以上（MATLAB 本体用） |
| ネットワーク | 初回インストール・ライセンス認証時に必要 |

> **注意：** 本教材は MATLAB R2025b で導入された **プレーンテキスト Live Code 形式**（`%[text]` 記法）を使用しています。**R2024b 以前では正しく表示されません。**

---

## MathWorks アカウントの作成

MATLAB のインストールには、MathWorks アカウントが必要です。

1. ブラウザで [MathWorks アカウント作成ページ](https://www.mathworks.com/mwaccount/register) を開く
2. 学校で指定された **学校メールアドレス**（例：`xxx@univ.ac.jp`）で登録する
3. 届いた確認メールのリンクをクリックし、登録を完了する
4. [MathWorks ログインページ](https://www.mathworks.com/login) からログインできることを確認する
5. **指導教員に、作成した MathWorks アカウントを学校の Campus-Wide License（キャンパスライセンス）等の学校ライセンスと紐づけるよう依頼する**
   - 学校によっては、教員が MathWorks の管理画面から学生アカウントをライセンスに追加する必要があります
   - 紐づけが完了すると、MATLAB のインストール時に学校ライセンスを選択できるようになります

---

## MATLAB のインストール

1. [MATLAB ダウンロードページ](https://www.mathworks.com/downloads/) にアクセスする
2. MathWorks アカウントでサインインする
3. **R2025b**（またはそれ以降）の **Install for Windows** を選択し、インストーラーをダウンロードする
4. ダウンロードした `matlab_R20XXx_win64.exe` を実行する
5. インストーラーの指示に従い、以下を選択・入力する
   - **Sign in to MathWorks Account**（アカウントでサインイン）
   - ライセンスの選択（学校ライセンスを選択）
   - インストール先フォルダ（デフォルトで問題なし）
   - **Simulink** を含む製品を選択（Simulink にチェックが入っていることを確認）
6. インストール完了後、MATLAB を起動し、ライセンスが有効であることを確認する

### インストール後の確認

MATLAB を起動し、コマンドウィンドウで以下を実行してください。

```matlab
ver
```

出力に `MATLAB Version: 25.x`（R2025b）以上が表示され、`Simulink` がリストに含まれていれば OK です。

---

## GitHub から教材を取得する

本教材は GitHub 上で配布しています。**Git 未経験の方は方法A（ZIP）**、**Git / GitHub に慣れている方は方法B（Fork）** を利用してください。方法B では教員リポジトリへの直接 clone は行わず、必ず Fork してから自分の Fork 先を clone します（[kosen-motor-drive-intro](https://github.com/enotyama19xx/kosen-motor-drive-intro) の運用と同様）。

教員リポジトリ（Fork 元）：  
[https://github.com/enotyama19xx/study-dynamics-matlab](https://github.com/enotyama19xx/study-dynamics-matlab)

### 方法A：ZIP でダウンロード（基本）

1. [教員リポジトリ](https://github.com/enotyama19xx/study-dynamics-matlab) をブラウザで開く
2. 右上の **Code（コード）** → **Download ZIP** をクリックする
3. ダウンロードした ZIP を解凍する（例：`C:\Users\<ユーザー名>\Documents\study-dynamics-matlab`）
4. 教材に更新がある場合は、ZIP を再ダウンロードして解凍し直す

### 方法B：Fork して clone（Git 利用者向け・推奨）

[Git for Windows](https://gitforwindows.org/) と [GitHub](https://github.com/) アカウントを用意したうえで、次の手順で取得します。**教員リポジトリへの直接 clone は行わないでください。**

#### 初回：Fork と clone

1. [教員リポジトリ](https://github.com/enotyama19xx/study-dynamics-matlab) を開き、右上 **Fork** から自分のアカウントに Fork を作成する
2. **自分の Fork 先** の URL で clone する

```powershell
cd C:\Users\<ユーザー名>\Documents
git clone https://github.com/<自分のユーザー名>/study-dynamics-matlab.git
cd study-dynamics-matlab
```

> Fork してから clone すると、演習で編集した内容を自分のリポジトリへ Push でき、他の学生と干渉しません。

#### 教材が更新されたとき：Sync fork → pull

1. GitHub 上で自分の Fork 先を開き、**Sync fork** → **Update branch** を実行する
2. 手元の PC で以下を実行する

```powershell
git pull origin main
```

> **Sync fork と pull はセットで実行** してください。どちらか一方だけでは最新の教材が手元に反映されません。

---

## 教材の使い方

### 1. Live Script として開く

1. MATLAB を起動する
2. 左側 **Files（ファイル）** パネルで `RLC_Modeling_Lecture.m` を **ダブルクリック** する  
   または **Home（ホーム）** タブ → **Open（開く）** からファイルを選択する
3. ファイルを右クリックする場合は **開く（Open）** を選ぶ（**テキストとして開く** は選ばない）
4. Live Editor で解説・数式・コードが一体として表示されれば成功です

### 2. セクションごとに実行する

**まずは指導教員の指示に従って進めてください。** 演習の進め方・提出物・使用する章は、教員からの案内に合わせてください。

Live Editor 上部の **Run Section（セクションの実行）** ボタン（または `Ctrl+Enter`）で、セクション単位にコードを実行できます。

教材は章ごとに区切られています。以下は、各章で **セクションを実行したときに何が起きるか** の目安です。

- **第1〜2章：** 解説のみ（コードなし）→ 読み進める
- **第3.1章：** パラメータ（R, L, C）がワークスペースに定義される
- **第3.2章：** Simulink モデルを実行してグラフが表示される

### 3. 学習の流れ

```
1. モデリング・ダイナミクスとは何か（概念理解）
      ↓
2. R → L → RL → RLC の順で微分方程式を理解
      ↓
3. Simulink で RLC 回路をシミュレーション
      ↓
4. パラメータ（R, L, C）を変えて波形の違いを確認
```

---

## よくあるトラブルと対処

### `%[text]` がそのまま表示される / 数式が崩れる

| 原因 | 対処 |
|------|------|
| 通常 Editor で開いている、または **テキストとして開く** を選んだ | ファイルを閉じ、**開く**（ダブルクリックまたは右クリック → 開く）で開き直す |
| R2024b 以前の MATLAB を使用 | **R2025b 以降** にアップデートする |
| `.mlx` に変換した際に形式が壊れた | リポジトリの `.m` ファイルを再取得し、**開く** で開き直す |

### 節の末尾に空のコードエリア（グレーの枠）が表示される

教材ファイル内に **空行がある** と、Live Editor が空のコードセルとして解釈します。リポジトリの最新版 `.m` を使用してください。手元で編集した場合は、テキスト行とコード行の間に空行を入れないでください。

### 太字や数式が正しく表示されない

- 本教材は R2025b 専用の `%[text]` 記法で記述されています
- ファイルを手動編集した場合、`**太字**` より `<strong>太字</strong>` の方が安定します
- 表示数式は `$...${"editStyle":"visual"}` 形式です（`$$...$$` は使いません）

### `Simulink モデル "RLC_Model" が見つからない` エラー

1. `RLC_Model.slx` が教材 `.m` ファイルと **同じフォルダ** にあるか確認する
2. MATLAB の Current Folder（現在のフォルダー）がそのフォルダになっているか確認する
3. ファイル名が正確に `RLC_Model.slx` であるか確認する（大文字小文字・拡張子）

### ライセンスエラーが出る

1. MATLAB 内で **Home → Help → Licensing → Activate Software** を確認する
2. 学校のライセンスポータルから再アクティベーションする
3. 解決しない場合は、**担当教員** に連絡する

---

## 参考リンク

| リソース | URL |
|----------|-----|
| MATLAB ダウンロード | https://www.mathworks.com/downloads/ |
| Live Script とは（公式ドキュメント） | https://www.mathworks.com/help/matlab/matlab_prog/what-is-a-live-script-or-function.html |
| プレーンテキスト Live Code 形式 | https://www.mathworks.com/help/matlab/matlab_prog/plain-text-file-format-for-live-scripts.html |
| Simulink 入門 | https://www.mathworks.com/help/simulink/getting-started-with-simulink.html |
| Git for Windows | https://gitforwindows.org/ |

---

## 問い合わせ

セットアップや教材内容で不明点がある場合は、**担当教員** まで連絡してください。

---

*本 README は RLC回路モデリング演習教材（GitHub 配布版）に付属するセットアップガイドです。*
