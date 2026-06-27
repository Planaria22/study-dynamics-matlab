function plotStepResponse(t, v, i, figName, layoutTitle, vTitle, iTitle)
% plotStepResponse  入力電圧と出力電流を上下2段でプロット（白背景）
fig = newWhiteFigure(figName);
tl = tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');
ax1 = nexttile;
plot(ax1, t, v, 'b-', 'LineWidth', 1.5);
grid(ax1, 'on');
ylabel(ax1, '電圧 v(t) [V]');
title(ax1, vTitle);
ax2 = nexttile;
plot(ax2, t, i, 'r-', 'LineWidth', 1.5);
grid(ax2, 'on');
ylabel(ax2, '電流 i(t) [A]');
xlabel(ax2, '時間 t [s]');
title(ax2, iTitle);
title(tl, layoutTitle);
linkaxes([ax1, ax2], 'x');
applyWhiteFigureStyle(fig);
end
