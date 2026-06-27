function [t, i, ok] = simulateRLCModel(modelName, stopTime)
% simulateRLCModel  RLC Simulink モデルを実行し電流 i(t) の時系列を取得する
%
%   [t, i, ok] = simulateRLCModel(modelName, stopTime)
%
%   modelName : Simulink モデル名（例: 'RLC_Model'）
%   stopTime  : シミュレーション終了時間 [s]
%   t, i      : 時間ベクトルと電流ベクトル（失敗時は空）
%   ok        : 成功時 true

t = [];
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
    i = extractSimCurrent(simOut);
    [t, i] = alignSeries(t, i);
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

function i = extractSimCurrent(simOut)
i = [];
if isprop(simOut, 'i_sim') && ~isempty(simOut.i_sim)
    i = simOut.i_sim;
elseif isa(simOut, 'Simulink.SimulationOutput')
    try
        i = simOut.get('i_sim');
    catch
    end
end
if isempty(i) && isprop(simOut, 'i_data') && ~isempty(simOut.i_data)
    i = simOut.i_data;
elseif isempty(i) && evalin('base', 'exist(''i_sim'',''var'')')
    i = evalin('base', 'i_sim');
elseif isempty(i) && evalin('base', 'exist(''i_data'',''var'')')
    i = evalin('base', 'i_data');
end
if isempty(i) && isprop(simOut, 'logsout') && ~isempty(simOut.logsout)
  try
    elem = simOut.logsout.getElement('i_sim');
    if isempty(elem) && simOut.logsout.numElements >= 1
        elem = simOut.logsout.getElement(1);
    end
    if ~isempty(elem)
        ts = elem.Values;
        if isa(ts, 'timeseries')
            i = ts.Data;
        end
    end
  catch
  end
end
i = unpackSeries(i);
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

function [t, i] = alignSeries(t, i)
if isempty(i) || isempty(t)
    error('RLC_Modeling:OutputMissing', ...
        '電流 i_sim（または i_data）がワークスペースに出力されていません。');
end
n = min(numel(t), numel(i));
t = t(1:n);
i = i(1:n);
end

function reportSimError(modelName, ME)
if strcmp(ME.identifier, 'RLC_Modeling:OutputMissing')
    warning('Simulink:OutputMissing', ...
        ['モデル "%s" は実行されましたが、結果の読み取りに失敗しました。\n' ...
         '  原因: %s\n' ...
         '  対処: Integrator（i）→ To Workspace、Variable name = i_sim、Save format = Array。\n' ...
         '        Model Settings > Data Import/Export で Time にチェック（tout）。'], ...
        modelName, ME.message);
else
    warning('Simulink:SimFailed', ...
        ['Simulink モデル "%s" の実行中にエラーが発生しました。\n' ...
         '  原因: %s\n' ...
         '  対処: 3.1 節を先に実行し、Simulink でモデルを開いてエラーを確認してください。'], ...
        modelName, ME.message);
end
end
