% setupRLCPaths  RLC 教材用の simulink-utils を MATLAB パスに追加する
%
% Live Script は一時フォルダから実行されるため、mfilename ではなく
% which('RLC_Modeling_Lecture') で保存先のパスを特定する。

lectureFile = which('RLC_Modeling_Lecture');
if isempty(lectureFile)
    here = pwd;
    for k = 1:10
        cand = fullfile(here, 'RLC_Modeling_Lecture.m');
        if exist(cand, 'file')
            lectureFile = cand;
            break;
        end
        parent = fileparts(here);
        if isequal(parent, here)
            break;
        end
        here = parent;
    end
end

if isempty(lectureFile)
    error('RLC_Modeling:PathNotFound', ...
        ['教材ファイル RLC_Modeling_Lecture.m が見つかりません。\n' ...
         'MATLAB の Current Folder を study-dynamics-matlab フォルダに設定してから再実行してください。']);
end

utilsDir = fullfile(fileparts(lectureFile), 'simulink-utils');
if ~exist(utilsDir, 'dir')
    error('RLC_Modeling:UtilsNotFound', ...
        'simulink-utils フォルダが見つかりません: %s', utilsDir);
end

addpath(utilsDir);
