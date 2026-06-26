# RLC回路モデリング — 演習教材

大学の工学部向け演習教材です。MATLAB Live Script を使い、**R → L → RL → RLC** の順で回路のダイナミクスを学び、最後に Simulink でシミュレーションします。

---

## 目次

1. [教材の構成](#教材の構成)
2. [必要な環境](#必要な環境)
3. [MathWorks アカウントの作成](#mathworks-アカウントの作成)
4. [MATLAB のインストール](#matlab-のインストール)
5. [MATLAB Drive（MATLAB Connector）の導入](#matlab-drivematlab-connectorの導入)
6. [GitHub から教材を取得する](#github-から教材を取得する)
7. [教材の使い方](#教材の使い方)
8. [Simulink モデルの準備](#simulink-モデルの準備)
9. [よくあるトラブルと対処](#よくあるトラブルと対処)
10. [参考リンク](#参考リンク)

---

## 教材の構成

| ファイル | 内容 |
|----------|------|
| `RLC_Modeling_Lecture.m` | メイン教材（Live Script 形式） |
| `RLC_Model.slx` | Simulink シミュレーション用モデル（第3章で使用） |
| `README.md` | 本ファイル（セットアップ手順） |

---

## 必要な環境

| 項目 | 要件 |
|------|------|
| OS | Windows 10 / 11（64bit）推奨 |
| MATLAB | **R2025a 以降**（必須） |
| Simulink | 第3章以降で使用（ライセンスに含まれていること） |
| ストレージ | 空き容量 約 10 GB 以上（MATLAB 本体用） |
| ネットワーク | 初回インストール・ライセンス認証・Drive 同期時に必要 |

> **注意：** 本教材は MATLAB R2025a で導入された **プレーンテキスト Live Code 形式**（`%[text]` 記法）を使用しています。**R2024b 以前では正しく表示されません。**

---

## MathWorks アカウントの作成

MATLAB のインストールと MATLAB Drive の利用には、MathWorks アカウントが必要です。

1. ブラウザで [MathWorks アカウント作成ページ](https://www.mathworks.com/mwaccount/register) を開く
2. 大学で指定された **大学メールアドレス**（例：`xxx@univ.ac.jp`）で登録する
3. 届いた確認メールのリンクをクリックし、登録を完了する
4. [MathWorks ログインページ](https://www.mathworks.com/login) からログインできることを確認する

大学からライセンス情報（アクティベーションキー等）の案内がある場合は、必ずそちらも確認してください。

---

## MATLAB のインストール

### 方法A：大学キャンパスライセンスを使う（推奨）

多くの大学では、Campus-Wide License または Total Academic Headcount ライセンスが提供されています。

1. 大学の MATLAB ポータルページ（例：情報基盤センターの案内ページ）にアクセスする  
   - 大学ごとに URL が異なります。不明な場合は担当教員または情報基盤センターに確認してください
2. 大学メールアドレスで MathWorks アカウントに **サインイン** する
3. **「MATLAB をダウンロード」** または **「Install MATLAB」** をクリックする
4. OS（Windows）を選択し、**最新版（R2025a 以降）** をダウンロードする
5. ダウンロードした `matlab_R20XXx_win64.exe` を実行する
6. インストーラーの指示に従い、以下を選択・入力する
   - **Sign in to MathWorks Account**（アカウントでサインイン）
   - ライセンスの選択（大学ライセンスを選択）
   - インストール先フォルダ（デフォルトで問題なし）
   - **Simulink** を含む製品を選択（Simulink にチェックが入っていることを確認）
7. インストール完了後、MATLAB を起動し、ライセンスが有効であることを確認する

### 方法B：MathWorks 公式サイトから直接インストール

1. [MATLAB ダウンロードページ](https://www.mathworks.com/downloads/) にアクセスする
2. MathWorks アカウントでサインインする
3. **R2025a**（またはそれ以降）の **Install for Windows** を選択する
4. 上記 手順6〜7 と同様にインストールを進める

### インストール後の確認

MATLAB を起動し、コマンドウィンドウで以下を実行してください。

```matlab
ver
```

出力に `MATLAB Version: 25.x`（R2025a）以上が表示され、`Simulink` がリストに含まれていれば OK です。

---

## MATLAB Drive（MATLAB Connector）の導入

MATLAB Drive は、クラウド上にファイルを保存し、PC・MATLAB Online 間で同期できるサービスです。演習ファイルのバックアップや、自宅・大学間での作業引き継ぎに便利です。

### 1. MATLAB Connector のインストール

**MATLAB がすでにインストールされている場合：**

1. MATLAB を起動する
2. 画面上部 **Current Folder（現在のフォルダー）** ツールバーの **MATLAB Drive** アイコンをクリックする
3. 初回起動時に Connector のインストールを促されるので、指示に従ってインストールする

**MATLAB をまだインストールしていない場合：**

1. [MATLAB Connector ダウンロードページ](https://www.mathworks.com/products/matlab-drive.html) から OS 用インストーラーをダウンロードする
2. インストーラーを実行する
3. MathWorks アカウントでサインインする

### 2. 同期フォルダの設定

インストール中に **MATLAB Drive フォルダの場所** を指定します。

- 推奨：デフォルト（例：`C:\Users\<ユーザー名>\MATLAB Drive`）
- **避けるべき場所：**
  - ネットワークドライブ（`\\server\...`）
  - OneDrive / Google Drive など、他のクラウド同期フォルダ内
  - 読み取り専用フォルダ

> 同期フォルダの場所は、インストール後に変更できません。慎重に選んでください。

### 3. 動作確認

1. Windows のスタートメニューから **MATLAB Connector** を起動する（タスクトレイにアイコンが表示される）
2. MATLAB を起動し、左側 **Files（ファイル）** パネルで **MATLAB Drive** フォルダが表示されることを確認する
3. ブラウザで [MATLAB Drive Online](https://drive.mathworks.com/) にアクセスし、同じアカウントでログインしてファイルが表示されることを確認する

### ストレージ容量

| アカウント種別 | 容量 |
|----------------|------|
| MathWorks アカウントのみ | 5 GB |
| 有効な MATLAB ライセンス（SMS 契約中） | 20 GB |

---

## GitHub から教材を取得する

### 方法A：ZIP でダウンロード（Git 未経験者向け）

1. 本リポジトリの GitHub ページをブラウザで開く
2. 右上の **Code（コード）** → **Download ZIP** をクリックする
3. ダウンロードした ZIP を解凍する（例：`C:\Users\<ユーザー名>\Documents\RLC-Lecture`）
4. （任意）解凍したフォルダを MATLAB Drive フォルダ内にコピーする

### 方法B：Git でクローン（推奨）

[Git for Windows](https://gitforwindows.org/) をインストール済みの場合：

```powershell
cd C:\Users\<ユーザー名>\Documents
git clone https://github.com/<組織名>/<リポジトリ名>.git
cd <リポジトリ名>
```

MATLAB Drive 内に置く場合：

```powershell
cd "$env:USERPROFILE\MATLAB Drive"
git clone https://github.com/<組織名>/<リポジトリ名>.git
```

> `<組織名>` / `<リポジトリ名>` は、担当教員から案内された URL に置き換えてください。

---

## 教材の使い方

### 1. Live Script として開く

1. MATLAB を起動する
2. **Home（ホーム）** タブ → **Open（開く）** をクリックする
3. `RLC_Modeling_Lecture.m` を選択する
4. ファイルが通常の Editor（コードエディタ）で開いた場合：
   - 左側 **Files** パネルでファイルを **右クリック**
   - **Open as Live Script（Live Script として開く）** を選択する
5. Live Editor で教材が表示されれば成功です

> **重要：** 「Open as Text（テキストとして開く）」ではなく、必ず **Live Script として** 開いてください。テキストとして開くと `%[text]` がそのまま表示され、数式や太字が崩れます。

### 2. セクションごとに実行する

Live Editor 上部の **Run Section（セクションの実行）** ボタン（または `Ctrl+Enter`）で、セクション単位にコードを実行できます。

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

## Simulink モデルの準備

第3章では `RLC_Model.slx` という Simulink モデルを実行します。リポジトリに同梱されていない場合は、以下の手順で作成してください。

### モデル作成手順（概要）

1. MATLAB コマンドウィンドウで `simulink` と入力し、Simulink を起動する
2. **Blank Model（空白モデル）** を選択する
3. 以下のブロックを配置して直列 RLC 回路を構成する
   - **Step**（ステップ入力電圧）
   - **Series RLC Branch**（直列 RLC）または R, L, C 個別ブロック
   - **Voltage Measurement** / **Current Measurement**
   - **To Workspace**（結果を `i_data`, `tout` として出力）
4. ブロックのパラメータを変数参照に設定する
   - R → `R`、L → `L`、C → `C`（教材 3.1 節で定義）
5. **Save（保存）** し、ファイル名を `RLC_Model.slx` とする
6. 教材ファイル `RLC_Modeling_Lecture.m` と **同じフォルダ** に保存する

詳細な作成手順は、担当教員からの補足資料を参照してください。

---

## よくあるトラブルと対処

### `%[text]` がそのまま表示される / 数式が崩れる

| 原因 | 対処 |
|------|------|
| 通常 Editor で開いている | **Open as Live Script** で開き直す |
| R2024b 以前の MATLAB を使用 | **R2025a 以降** にアップデートする |
| `.mlx` に変換した際に形式が壊れた | リポジトリの `.m` ファイルを再取得し、Live Script として開く |

### 節の末尾に空のコードエリア（グレーの枠）が表示される

教材ファイル内に **空行がある** と、Live Editor が空のコードセルとして解釈します。リポジトリの最新版 `.m` を使用してください。手元で編集した場合は、テキスト行とコード行の間に空行を入れないでください。

### 太字や数式が正しく表示されない

- 本教材は R2025a 専用の `%[text]` 記法で記述されています
- ファイルを手動編集した場合、`**太字**` より `<strong>太字</strong>` の方が安定します
- 表示数式は `$...${"editStyle":"visual"}` 形式です（`$$...$$` は使いません）

### `Simulink モデル "RLC_Model" が見つからない` エラー

1. `RLC_Model.slx` が教材 `.m` ファイルと **同じフォルダ** にあるか確認する
2. MATLAB の Current Folder（現在のフォルダー）がそのフォルダになっているか確認する
3. ファイル名が正確に `RLC_Model.slx` であるか確認する（大文字小文字・拡張子）

### MATLAB Drive が同期しない

1. タスクトレイの **MATLAB Connector** アイコンを確認し、起動しているか確認する
2. インターネット接続を確認する
3. 同期フォルダが OneDrive 等の別クラウドサービス内にないか確認する
4. Connector を再起動する（右クリック → Quit → 再度起動）

### ライセンスエラーが出る

1. MATLAB 内で **Home → Help → Licensing → Activate Software** を確認する
2. 大学のライセンスポータルから再アクティベーションする
3. 解決しない場合は、大学の情報基盤センターまたは担当教員に連絡する

---

## 参考リンク

| リソース | URL |
|----------|-----|
| MATLAB ダウンロード | https://www.mathworks.com/downloads/ |
| MATLAB Drive | https://www.mathworks.com/products/matlab-drive.html |
| MATLAB Drive Online | https://drive.mathworks.com/ |
| Live Script とは（公式ドキュメント） | https://www.mathworks.com/help/matlab/matlab_prog/what-is-a-live-script-or-function.html |
| プレーンテキスト Live Code 形式（R2025a） | https://www.mathworks.com/help/matlab/matlab_prog/plain-text-file-format-for-live-scripts.html |
| Simulink 入門 | https://www.mathworks.com/help/simulink/getting-started-with-simulink.html |
| Git for Windows | https://gitforwindows.org/ |

---

## 問い合わせ

セットアップや教材内容で不明点がある場合は、**担当教員** または **演習の TA** まで連絡してください。  
MATLAB のライセンスに関する問題は、大学の **情報基盤センター** に相談してください。

---

*本 README は RLC回路モデリング演習教材（GitHub 配布版）に付属するセットアップガイドです。*
