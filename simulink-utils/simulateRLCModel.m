function [t, v, i, ok] = simulateRLCModel(modelName, stopTime)
% simulateRLCModel  RLC Simulink モデルを実行し入力電圧・電流の時系列を取得する
%
%   [t, v, i, ok] = simulateRLCModel(modelName, stopTime)
%
%   modelName : Simulink モデル名（例: 'RLC_Model'）
%   stopTime  : シミュレーション終了時間 [s]
%   t, v, i   : 時間・入力電圧・電流ベクトル（失敗時は空）
%   ok        : 成功時 true

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
    simOut = sim(modelName, 'StopTime', num2str(stopTime));
    t = extractSimTime(simOut);
    i = extractSimSignal(simOut, {'i_sim', 'i_data'});
    v = extractSimSignal(simOut, {'v_sim', 'v_data'});
    if isempty(v) && ~isempty(t)
        v = fallbackStepVoltage(t);
    end
    [t, v, i] = alignSeries(t, v, i);
    ok = true;
catch ME
    reportSimError(modelName, ME);
end
end

function exists = modelFileExists(modelName)
exists = exist([modelName '.slx'], 'file') == 4 || exist([modelName '.mdl'], 'file') == 4;
end

function t = extractSimTime(simOut)
t = [];
if isprop(simOut, 'tout') && ~isempty(simOut.tout)
    t = simOut.tout;
elseif evalin('base', 'exist(''t_sim'',''var'')')
    t = evalin('base', 't_sim');
end
t = unpackSeries(t);
end

function y = extractSimSignal(simOut, names)
y = [];
for k = 1:numel(names)
    name = names{k};
    if isprop(simOut, name) && ~isempty(simOut.(name))
        y = simOut.(name);
        break;
    end
    if isa(simOut, 'Simulink.SimulationOutput')
        try
            y = simOut.get(name);
            if ~isempty(y)
                break;
            end
        catch
        end
    end
    if isempty(y) && evalin('base', sprintf('exist(''%s'',''var'')', name))
        y = evalin('base', name);
        break;
    end
end
if isempty(y) && isprop(simOut, 'logsout') && ~isempty(simOut.logsout)
    for k = 1:numel(names)
        try
            elem = simOut.logsout.getElement(names{k});
            if ~isempty(elem)
                ts = elem.Values;
                if isa(ts, 'timeseries')
                    y = ts.Data;
                    break;
                end
            end
        catch
        end
    end
end
y = unpackSeries(y);
end

function v = fallbackStepVoltage(t)
v = [];
if evalin('base', 'exist(''V0'',''var'')')
    V0 = evalin('base', 'V0');
    v = V0 * (t >= 0);
    warning('Simulink:VoltageFallback', ...
        'v_sim が見つかりませんでした。ワークスペースの V0 からステップ電圧を再構成しました。Step → To Workspace（v_sim）の設定を推奨します。');
end
end

function y = unpackSeries(x)
if isa(x, 'timeseries')
    y = x.Data;
elseif isstruct(x) && isfield(x, 'signals')
    y = x.signals.values;
elseif isnumeric(x)
    y = x;
else
    y = [];
end
y = squeeze(y(:));
end

function [t, v, i] = alignSeries(t, v, i)
if isempty(i) || isempty(t)
    error('RLC_Modeling:OutputMissing', ...
        '電流 i_sim（または i_data）がワークスペースに出力されていません。');
end
if isempty(v)
    error('RLC_Modeling:OutputMissing', ...
        '入力電圧 v_sim が見つかりません。Step 出力 → To Workspace（v_sim）を設定するか、3.1 節で V0 を定義してください。');
end
n = min([numel(t), numel(v), numel(i)]);
t = t(1:n);
v = v(1:n);
i = i(1:n);
end

function reportSimError(modelName, ME)
if strcmp(ME.identifier, 'RLC_Modeling:OutputMissing')
    warning('Simulink:OutputMissing', ...
        ['モデル "%s" は実行されましたが、結果の読み取りに失敗しました。\n' ...
         '  原因: %s\n' ...
         '  対処: Step（入力電圧）→ To Workspace（v_sim）、Integrator（i）→ To Workspace（i_sim）。\n' ...
         '        Save format = Array。Model Settings で Time にチェック（tout）。'], ...
        modelName, ME.message);
else
    warning('Simulink:SimFailed', ...
        ['Simulink モデル "%s" の実行中にエラーが発生しました。\n' ...
         '  原因: %s\n' ...
         '  対処: 3.1 節を先に実行し、Simulink でモデルを開いてエラーを確認してください。'], ...
        modelName, ME.message);
end
end
