%[text] # RLC回路のモデリング学習
%[text] このファイルは <strong>MATLAB R2025a</strong> 以降のプレーンテキスト Live Code 形式（`.m`）です。Live Editor で <strong>Open as Live Script</strong> から開くと、解説・数式・コードが一体化した教材として表示されます。
%%
%[text] ## 1. モデリング・ダイナミクスとは何か
%[text] <strong>モデリング</strong>とは、現実世界の現象（ここでは電気回路）を、数学的な式やコンピュータ上のブロック図などの「扱いやすい形」に写し取ることです。例えば「スイッチを入れたら、電流はどう変化するか？」という問いに答えるために、抵抗・インダクタ・キャパシタの性質を式にまとめ、シミュレーションで確認します。
%[text] <strong>ダイナミクス（動特性）</strong>とは、入力が変化したとき、出力が「時間とともにどう変化していくか」という振る舞いのことです。
%[text] - 即座に追従する（静的）
%[text] - 少し遅れて立ち上がる（1次の過渡応答）
%[text] - 振動しながら収束する、または振動し続ける（2次系） \
%[text] といった違いが、ダイナミクスの本質です。
%[text] 本教材では、回路要素を1つずつ足していくことで、「代数方程式 → 1階微分方程式 → 2階微分方程式」と次数が上がる過程を体験し、最後に Simulink で視覚的にシミュレーションする流れで学びます。
%%
%[text] ## 2. 回路要素のステップアップと微分方程式の解法
%[text] 以下では、各回路について (1) 回路図、(2) 物理法則（基本方程式）、(3) 微分方程式、(4) 解法（過渡・定常）の順に解説します。
%%
%[text] ### 2.1 R回路（抵抗のみ）
%[text] [ここにR回路（抵抗のみ）の回路図を挿入]
%[text] 抵抗 $R$ [$\\Omega$] におけるオームの法則：
%[text] $v_R(t) = R \\, i(t)${"editStyle":"visual"}
%[text] 入力電圧 $v(t)$ を印加し、回路全体の電流を $i(t)$ とすると（抵抗のみの場合）：
%[text] $v(t) = R \\, i(t) \\quad \\Longrightarrow \\quad i(t) = \\frac{v(t)}{R}${"editStyle":"visual"}
%[text] これは <strong>代数方程式</strong> であり、<strong>微分方程式ではありません</strong>。したがって R だけの回路には <strong>ダイナミクス（時間的な記憶）が存在しません</strong>。電圧が変われば、電流は <strong>即座に</strong>（理想的には瞬時に）新しい値に追従します。
%[text] #### 過渡応答・定常応答
%[text] - 定常（$v(t)=V_0$ が一定）：$i = V_0/R$（一定）
%[text] - 入力がステップ変化しても、遅れや振動は生じない（理想的な抵抗モデル） \
%%
%[text] ### 2.2 L回路（インダクタのみ）
%[text] [ここにL回路（インダクタのみ）の回路図を挿入]
%[text] インダクタ $L$ [H] の電圧–電流関係：
%[text] $v_L(t) = L \\, \\frac{di(t)}{dt}${"editStyle":"visual"}
%[text] 入力電圧 $v(t)$ がインダクタ两端に印加されると：
%[text] $v(t) = L \\, \\frac{di(t)}{dt}${"editStyle":"visual"}
%[text] これは <strong>1階常微分方程式</strong> です。<strong>ダイナミクスの始まり</strong> はここにあります。「電流の変化率 $\\frac{di}{dt}$ が電圧を生む」＝ 電流はいきなり跳び変われず、時間をかけて変化する、という物理的直感と一致します。
%[text] #### 定常応答
%[text] 定常状態（$\\frac{di}{dt}=0$）では $v=0$。つまり理想的な $L$ だけでは DC 定常電流を維持するために必要な電圧は 0 です（短絡的な挙動）。
%[text] #### 過渡応答（例：$v(t)=V_0$ ステップ入力、$i(0)=0$）
%[text] $\\frac{di}{dt} = \\frac{V_0}{L} \\quad \\Longrightarrow \\quad i(t) = \\frac{V_0}{L} \\, t${"editStyle":"visual"}
%[text] 電流は時間に比例して <strong>直線的に増加</strong> します（理想 $L$ のみ、無制限に増え続ける）。
%%
%[text] ### 2.3 RL回路（抵抗＋インダクタ）
%[text] [ここにRL回路（抵抗＋インダクタ）の回路図を挿入]
%[text] キルヒホッフの電圧法則（KVL）：
%[text] $v(t) = R \\, i(t) + L \\, \\frac{di(t)}{dt}${"editStyle":"visual"}
%[text] 整理すると <strong>1階線形常微分方程式</strong>：
%[text] $\\frac{di(t)}{dt} + \\frac{R}{L} \\, i(t) = \\frac{1}{L} \\, v(t)${"editStyle":"visual"}
%[text] <strong>時定数</strong> $\\tau = \\frac{L}{R}$ [s] が現れます。$\\tau$ は「電流が定常値の約 63% まで立ち上がる目安の時間」です。
%[text] #### 手計算での解法の流れ（$v(t)=V_0$ ステップ、$i(0)=0$）
%[text] 1. 同次方程式 $\\frac{di}{dt} + \\frac{R}{L}i = 0$ の解：
%[text] $i_h(t) = A \\, e^{-(R/L)t}${"editStyle":"visual"}
%[text] 2. 定常解（特解）：$i_{ss} = V_0/R$
%[text] 3. 一般解：$i(t) = i_{ss} + i_h(t) = \\frac{V_0}{R} + A \\, e^{-(R/L)t}$
%[text] 4. 初期条件 $i(0)=0$ より $A = -V_0/R$
%[text] #### 過渡応答
%[text] $i(t) = \\frac{V_0}{R}\\left(1 - e^{-t/\\tau}\\right), \\quad \\tau = \\frac{L}{R}${"editStyle":"visual"}
%[text] #### 定常応答
%[text] $t \\to \\infty$ のとき $i(\\infty) = V_0/R$（オームの法則どおり）
%%
%[text] ### 2.4 RLC回路（抵抗＋インダクタ＋キャパシタ）
%[text] [ここにRLC回路（直列）の回路図を挿入]
%[text] 直列 RLC 回路で、電荷 $q(t)$ [C]、電流 $i(t)=\\frac{dq}{dt}$ とすると KVL より：
%[text] $v(t) = R \\, \\frac{dq}{dt} + L \\, \\frac{d^2 q}{dt^2} + \\frac{1}{C} \\, q(t)${"editStyle":"visual"}
%[text] 両辺を $dt$ で微分（$i=\\frac{dq}{dt}$）すると、<strong>電流 $i(t)$ に関する2階微分方程式</strong>：
%[text] $L \\, \\frac{d^2 i}{dt^2} + R \\, \\frac{di}{dt} + \\frac{1}{C} \\, i(t) = \\frac{dv(t)}{dt}${"editStyle":"visual"}
%[text] 入力がステップ電圧 $v(t)=V_0$（$t \\ge 0$）のとき右辺は 0（$t>0$）となり：
%[text] $L \\, \\frac{d^2 i}{dt^2} + R \\, \\frac{di}{dt} + \\frac{1}{C} \\, i(t) = 0 \\quad (t>0)${"editStyle":"visual"}
%[text] 特性方程式 $L s^2 + R s + \\frac{1}{C} = 0$ の判別式：
%[text] $\\Delta = R^2 - \\frac{4L}{C}${"editStyle":"visual"}
%[text] - $\\Delta > 0$：<strong>過減衰</strong>（振動せずゆっくり収束）
%[text] - $\\Delta = 0$：<strong>臨界減衰</strong>
%[text] - $\\Delta < 0$：<strong>不足減衰</strong>（減衰振動） \
%[text] #### 【強調ポイント — 高次化の限界】
%[text] 次数が 1 → 2 になるだけで、手計算での解法は一気に複雑になります。特性根の計算、初期条件 $i(0)$, $\\frac{di}{dt}(0)$ の適用、さらにラプラス変換を使っても部分分数展開や逆変換の代数が煩雑になります。
%[text] 数式だけを眺めていると、「実際に振動するのか？」「どれくらいで収束するのか？」「パラメータを変えると波形はどう変わるのか？」といった <strong>ダイナミクスのイメージが掴みにくい</strong> — これが手計算中心の学習の大きな課題です。
%[text] 次の章では、この課題を <strong>Simulink</strong> で解決する方法を紹介します。
%%
%[text] ## 3. Simulinkによる実装とシミュレーション
%[text] 数式を紙の上で完全に解く代わりに、ブロック線図で回路を組み立て、コンピュータに微分方程式の数値積分を任せる手法が Simulink です。
%[text] #### Simulinkの素晴らしい点
%[text] - 微分方程式を手で解く必要がない（数値シミュレーションが自動）
%[text] - ブロック線図で回路・信号の流れが <strong>視覚的</strong> に理解できる
%[text] - $R$, $L$, $C$ を変えるだけで <strong>すぐ実験</strong> でき、設計の勘所が身につく \
%[text] 以下の MATLAB コードでパラメータを定義し、Simulink モデル `RLC_Model.slx` を実行して結果をプロットします。（※ 事前に Simulink 上で `RLC_Model` という名前のモデルを作成しておく必要があります）
%%
%[text] ### 3.1 パラメータ定義（MATLABコード）
%[text] ワークスペースに RLC パラメータを定義します。Simulink モデル内のブロックは、これらの変数名（`R`, `L`, `C`）を参照する想定です。
R = 10;      % 抵抗 [Ω]
L = 0.1;     % インダクタ [H]
C = 0.001;   % キャパシタ [F]
V0 = 5;      % ステップ入力電圧 [V]（モデル側で使用する場合）
Tsim = 2;    % シミュレーション時間 [s]
fprintf('パラメータを定義しました: R=%g Ω, L=%g H, C=%g F\n', R, L, C);
%%
%[text] ### 3.2 Simulink実行と結果プロット（MATLABコード）
%[text] `sim('RLC_Model')` でバックグラウンド実行し、結果をプロットします。モデルが存在しない場合は `try-catch` で分かりやすいメッセージを表示します。
modelName = 'RLC_Model';
try
    simOut = sim(modelName, 'StopTime', num2str(Tsim));
    if isprop(simOut, 'i_data') && isprop(simOut, 'tout')
        t = simOut.tout;
        i = simOut.i_data;
    elseif evalin('base', 'exist(''t_sim'',''var'')') && evalin('base', 'exist(''i_sim'',''var'')')
        t = evalin('base', 't_sim');
        i = evalin('base', 'i_sim');
    else
        error('シミュレーション結果（時間・電流）が見つかりません。To Workspace ブロックの設定を確認してください。');
    end
    figure('Name', 'RLC回路シミュレーション結果', 'NumberTitle', 'off');
    plot(t, i, 'b-', 'LineWidth', 1.5);
    grid on;
    xlabel('時間 t [s]');
    ylabel('電流 i(t) [A]');
    title(sprintf('RLC回路の過渡応答 (R=%g \\Omega, L=%g H, C=%g F)', R, L, C));
    fprintf('Simulink モデル "%s" のシミュレーションが正常に完了しました。\n', modelName);
catch ME
    warning('Simulink:ModelNotFound', ...
        ['Simulink モデル "%s" が見つからないか、実行に失敗しました。\n' ...
         '  原因: %s\n' ...
         '  対処: Simulink で RLC 直列回路モデル "RLC_Model.slx" を作成し、\n' ...
         '        To Workspace ブロックで i(t) と t を出力するよう設定してください。'], ...
        modelName, ME.message);
end
%%
%[text] ### 3.3 学習のまとめ
%[text] 本教材で学んだこと：
%[text] 1. <strong>R</strong> — 代数方程式。ダイナミクスなし（即応答）
%[text] 2. <strong>L</strong> — 1階 ODE。電流の変化が時間的挙動を生む
%[text] 3. <strong>RL</strong> — 1階 ODE + 時定数 $\\tau = L/R$。指数関数的な過渡応答
%[text] 4. <strong>RLC</strong> — 2階 ODE。振動・減衰の分類が必要で、手計算は急速に困難に
%[text] 5. <strong>Simulink</strong> — 数式の限界を補い、視覚と数値実験でダイナミクスを体感できる \
%[text] 次のステップとして、$R$, $L$, $C$ の値を変えて Simulink を何度も実行し、「不足減衰」「過減衰」の波形の違いを自分の目で確認してみてください。
%[text] 各セクションのプレースホルダー位置に回路図画像を挿入し、Simulink のスクリーンショットを追加すると、より完成度の高い教材になります。
%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"inline"}
%---
