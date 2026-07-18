function [t, v, i, ok] = simulateRLCModel(modelName, stopTime)
% simulateRLCModel  RLC Simulink モデルを実行し入力電圧・電流の時系列を取得する
%
%   [t, v, i, ok] = simulateRLCModel(modelName, stopTime)
%
%   modelName : Simulink モデル名（例: 'RLC_Model'）
%   stopTime  : シミュレーション終了時間 [s]
%   t, v, i   : 時間・入力電圧・電流ベクトル（失敗時は空）
%   ok        : 成功時 true
%
%   可変ステップだとステップ入力直後の点が粗くなり、Scope では補間されて
%   滑らかに見えても To Workspace では立ち上がりが欠けて描画が途切れて
%   見えることがある。そのため MaxStep を制限し、描画用に時間軸を整える。

t = [];
v = [];
i = [];
ok = false;

if ~modelFileExists(modelName)
    warning('Simulink:ModelNotFound', ...
        ['モデルファイル "%s.slx" がカレントフォルダにありません（現在: %s）。\n' ...
         '  対処: Live Script と同じフォルダに保存するか、cd でそのフォルダに移動してください。'], ...
        modelName, pwd);
    return;
end

try
    % Scope と同程度に過渡を捉えるよう、最大刻みを制限する
    maxStep = stopTime / 500;
    simOut = sim(modelName, ...
        'StopTime', num2str(stopTime), ...
        'MaxStep', num2str(maxStep), ...
        'Refine', '1');

    [tTout, hasTout] = extractSimTime(simOut);
    [tI, iRaw] = extractTimedSignal(simOut, {'i_sim', 'i_data'});
    [tV, vRaw] = extractTimedSignal(simOut, {'v_sim', 'v_data'});

    if isempty(iRaw)
        error('RLC_Modeling:OutputMissing', ...
            '電流 i_sim（または i_data）がワークスペースに出力されていません。');
    end

    % 電流の時刻を優先（無ければ tout）
    if ~isempty(tI) && numel(tI) == numel(iRaw)
        tSrcI = tI;
        iSrc = iRaw;
    elseif hasTout && numel(tTout) == numel(iRaw)
        tSrcI = tTout;
        iSrc = iRaw;
    elseif hasTout
        tSrcI = tTout;
        iSrc = alignArrayToTime(iRaw, tTout);
    else
        error('RLC_Modeling:OutputMissing', ...
            '時間ベクトル tout / 信号の Time が取得できません。Model Settings で Time を有効にしてください。');
    end

    if isempty(vRaw)
        vSrc = fallbackStepVoltage(tSrcI);
        tSrcV = tSrcI;
    elseif ~isempty(tV) && numel(tV) == numel(vRaw)
        tSrcV = tV;
        vSrc = vRaw;
    elseif hasTout && numel(tTout) == numel(vRaw)
        tSrcV = tTout;
        vSrc = vRaw;
    else
        tSrcV = tSrcI;
        vSrc = alignArrayToTime(vRaw, tSrcI);
    end

    if isempty(vSrc)
        error('RLC_Modeling:OutputMissing', ...
            '入力電圧 v_sim が見つかりません。Step 出力 → To Workspace（v_sim）を設定するか、ワークスペースに V0 を定義してください。');
    end

    [tSrcI, iSrc] = removeNonFinite(tSrcI, iSrc);
    [tSrcV, vSrc] = removeNonFinite(tSrcV, vSrc);

    % 描画用に等間隔の時間軸へ載せ替える（途切れ・ギザつきを防ぐ）
    tStart = min([tSrcI(1), tSrcV(1)]);
    tEnd = max([tSrcI(end), tSrcV(end)]);
    nPlot = max(1000, round((tEnd - tStart) / maxStep) + 1);
    t = linspace(tStart, tEnd, nPlot).';
    i = interp1(tSrcI, iSrc, t, 'pchip');
    v = interp1(tSrcV, vSrc, t, 'previous'); % ステップ電圧の立ち上がりを保持
    v(~isfinite(v)) = interp1(tSrcV, vSrc, t(~isfinite(v)), 'linear', 'extrap');

    [t, v, i] = cleanSeries(t, v, i);
    ok = true;
catch ME
    reportSimError(modelName, ME);
end
end

function exists = modelFileExists(modelName)
exists = exist([modelName '.slx'], 'file') == 4 || exist([modelName '.mdl'], 'file') == 4;
end

function [t, hasTout] = extractSimTime(simOut)
t = [];
hasTout = false;
if isprop(simOut, 'tout') && ~isempty(simOut.tout)
    t = unpackNumeric(simOut.tout);
    hasTout = ~isempty(t);
end
end

function [t, y] = extractTimedSignal(simOut, names)
% sim() の戻り値だけを見る（ベースワークスペースの古い変数は使わない）
t = [];
y = [];
for k = 1:numel(names)
    name = names{k};
    raw = [];
    if isprop(simOut, name) && ~isempty(simOut.(name))
        raw = simOut.(name);
    elseif isa(simOut, 'Simulink.SimulationOutput')
        try
            raw = simOut.get(name);
        catch
            raw = [];
        end
    end
    if isempty(raw) && isprop(simOut, 'logsout') && ~isempty(simOut.logsout)
        try
            raw = simOut.logsout.getElement(name);
        catch
            raw = [];
        end
    end
    if isempty(raw)
        continue;
    end
    [t, y] = unpackTimed(raw);
    if ~isempty(y)
        return;
    end
end
end

function [t, y] = unpackTimed(x)
t = [];
y = [];

if isa(x, 'Simulink.SimulationData.Signal')
    x = x.Values;
end

if isa(x, 'timeseries')
    t = unpackNumeric(x.Time);
    y = unpackNumeric(x.Data);
    return;
end

if isstruct(x)
    if isfield(x, 'time') && isfield(x, 'signals')
        t = unpackNumeric(x.time);
        if isfield(x.signals, 'values')
            y = unpackNumeric(x.signals.values);
        end
        return;
    end
    if isfield(x, 'Time') && isfield(x, 'Data')
        t = unpackNumeric(x.Time);
        y = unpackNumeric(x.Data);
        return;
    end
end

if isnumeric(x)
    y = unpackNumeric(x);
    return;
end

if isa(x, 'timetable')
    t = seconds(x.Properties.RowTimes - x.Properties.RowTimes(1));
    y = unpackNumeric(x{:, 1});
end
end

function y = unpackNumeric(x)
if isa(x, 'timeseries')
    y = x.Data;
elseif isnumeric(x)
    y = x;
else
    y = [];
    return;
end
y = squeeze(y);
if isempty(y)
    return;
end
if isvector(y)
    y = y(:);
else
    y = y(:, end);
    y = y(:);
end
end

function yq = alignArrayToTime(ySrc, tQ)
% Array 形式で長さが tout と一致しないとき、同一時間範囲と仮定して補間する
ySrc = ySrc(:);
tQ = tQ(:);
if numel(ySrc) == numel(tQ)
    yq = ySrc;
    return;
end
if numel(ySrc) < 2
    yq = repmat(ySrc(1), size(tQ));
    return;
end
yq = interp1(linspace(0, 1, numel(ySrc)), ySrc, linspace(0, 1, numel(tQ)).', ...
    'linear', 'extrap');
end

function v = fallbackStepVoltage(t)
v = [];
if evalin('base', 'exist(''V0'',''var'')')
    V0 = evalin('base', 'V0');
    stepTime = 0;
    if evalin('base', 'exist(''stepTime'',''var'')')
        stepTime = evalin('base', 'stepTime');
    end
    v = V0 * (t >= stepTime);
    warning('Simulink:VoltageFallback', ...
        'v_sim が見つかりませんでした。ワークスペースの V0 からステップ電圧を再構成しました。Step → To Workspace（v_sim）の設定を推奨します。');
end
end

function [t, y] = removeNonFinite(t, y)
t = t(:);
y = y(:);
[t, idx] = unique(t, 'stable');
y = y(idx);
valid = isfinite(t) & isfinite(y);
t = t(valid);
y = y(valid);
if numel(t) < 2
    error('RLC_Modeling:OutputMissing', ...
        '有効な時系列点が不足しています。To Workspace の Save format / Decimation を確認してください。');
end
end

function [t, v, i] = cleanSeries(t, v, i)
t = t(:);
v = v(:);
i = i(:);
n = min([numel(t), numel(v), numel(i)]);
t = t(1:n);
v = v(1:n);
i = i(1:n);
valid = isfinite(t) & isfinite(v) & isfinite(i);
t = t(valid);
v = v(valid);
i = i(valid);
if isempty(t)
    error('RLC_Modeling:OutputMissing', ...
        '有効な時系列データが残っていません（NaN/Inf のみ）。To Workspace の設定を確認してください。');
end
end

function reportSimError(modelName, ME)
if strcmp(ME.identifier, 'RLC_Modeling:OutputMissing')
    warning('Simulink:OutputMissing', ...
        ['モデル "%s" は実行されましたが、結果の読み取りに失敗しました。\n' ...
         '  原因: %s\n' ...
         '  対処: Step（入力電圧）→ To Workspace（v_sim）、Integrator（i）→ To Workspace（i_sim）。\n' ...
         '        Save format = Array または Timeseries。Decimation = 1。Model Settings で Time を有効（tout）。'], ...
        modelName, ME.message);
else
    warning('Simulink:SimFailed', ...
        ['Simulink モデル "%s" の実行中にエラーが発生しました。\n' ...
         '  原因: %s\n' ...
         '  対処: パラメータ定義セクションを先に実行し、Simulink でモデルを開いてエラーを確認してください。'], ...
        modelName, ME.message);
end
end
