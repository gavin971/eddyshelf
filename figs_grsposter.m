%% Figures for paper 1:
% EW isobaths
ew = runArray({ ...
    'runew-64361', ...
    'runew-6341', ...
    'runew-6362-2', ...
    'runew-6441' });

% NS isobaths
folders = { ...
    'runns-64361', 'runns-6341', 'runns-6362-2',...
    'runns-6441', ...
          };
ns = runArray(folders);

% wide slope runs
folders = { ...
        %'runew-6341', ..
    'runew-6342', ...
    'runew-6362', ... %'runew-6362-1', 'runew-6362-2', 'runew-6371', ...
    'runew-6372', ... % 'runew-6373' ...
    ...                     %'runew-6452', 'runew-6352', ...
    'runew-64361', 'runew-64361-2', ...
    'runew-64461-3', ...%'runew-64462', ...
    'runew-64461-4', 'runew-64461-5',...
    'runew-64461-6', 'runew-64461-7', 'runew-64463-1', ...
    'runew-b4361', ...
    'runew-64351-cyc', 'runew-6341-fneg', ...
          };
sl = runArray(folders);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% xymap
name = 'ew-64361';
if ~exist('run', 'var') || ~strcmpi(run.name, name)
    run = runs(['../topoeddy/run' name '/']);
end
fontSize = [22 24 30];
ms = 22; % marker size
trackcolor = [1 1 1]*0.65;
sbslcolor = trackcolor;
rescolor = 'k';
tt = [1 250];
seqcolor = flipud(cbrewer('div','RdYlBu',32));
[~,~,tind] = run.locate_resistance;

figure; maximize(); pause(0.5);
ax3 = subplot(121);
run.animate_field('eddye', ax3, tt(1), 1);
limx = xlim;
plot(run.eddy.mx/1000, run.eddy.my/1000, 'Color', trackcolor);
plot(run.eddy.mx(tt(1))/1000, run.eddy.my(tt(1))/1000, '.', ...
     'MarkerSize', 1.5*ms, 'Color', trackcolor);
plot(run.eddy.mx(tind)/1000, run.eddy.my(tind)/1000, 'x', ...
     'MarkerSize', ms, 'Color', rescolor);
text(0.15*diff(limx), run.bathy.xsl/1000, 'slopebreak', ...
     'VerticalAlignment', 'Bottom', 'FontSize', fontSize(1)-4, ...
     'Color', sbslcolor);
text(0.15*diff(limx), run.bathy.xsb/1000, 'shelfbreak', ...
     'VerticalAlignment', 'Top', 'FontSize', fontSize(1)-4, ...
     'Color', sbslcolor);
title('Dyes and SSH'); caxis([-1 1]); beautify(fontSize);
colormap(ax3,seqcolor);
correct_ticks('y',[],[3 6]);

ax4 = subplot(122);
run.animate_field('eddye', ax4, tt(2), 1);
plot(run.eddy.mx/1000, run.eddy.my/1000, 'Color', trackcolor);
plot(run.eddy.mx(tt(2))/1000, run.eddy.my(tt(2))/1000, '.', ...
     'MarkerSize', 1.5*ms, 'Color', trackcolor);
plot(run.eddy.mx(tind)/1000, run.eddy.my(tind)/1000, 'x', ...
     'MarkerSize', ms, 'Color', rescolor);
caxis([-1 1]);
colormap(ax4,seqcolor); beautify(fontSize);
title('Dyes and SSH'); ylabel([]);
ax4.YTickLabel = [];
correct_ticks('y',[],[3 6]);

export_fig('-r450','images/grs-poster/xymap-poster.png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EW, NS Center-tracks - wide slope
ew.filter = [];
ns.filter = [];

fontSize = [22 22 30]
ew.plot_penetration('all'); maximize();
beautify(fontSize); legend('off');
export_fig('images/grs-poster/ew-centrack.pdf');
ns.plot_penetration('all'); maximize(); drawnow;
beautify(fontSize); legend('off')
ax1 = gca; ax1.XTick = unique([ax1.XTick 1])
export_fig('images/grs-poster/ns-centrack.pdf');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameterization
sl.filter = [1:sl.len]; sl.filter(end-2) = [];
sl.print_diag('bottom torque');
title([]); pause(1);
set(gcf, 'renderer', 'opengl');
correct_ticks('x', '%.3f', 6);
correct_ticks('y', '%.2f', 2);
export_fig('-r250', 'images/grs-poster/penetration-res-param.png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% energy decay - only KE
sl.filter = [3 4 5 7 8 12]
sl.plot_dEdt; maximize(); pause(1);
subplot(121); title([]);
ylim([0 1]);
pbaspect([1.618 1 1]); xlim([0 200]);
legend('off'); beautify([22 24 28]);
ax = subplot(122); delete(ax);
export_fig('images/grs-poster/energy-decay.pdf');