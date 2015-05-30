%% Figures for paper 1:
% EW isobaths
ewall = runArray({ ...
    'runew-4341/', ...
    'runew-36-sym/', ...
    'runew-64361/', ...
                });
ewall.name = {'R/L_{sl} > 1', 'R/L_{sl} ~ 1', ...
              'R/L_{sl} < 1'};

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

% shelfbreak depth - xy maps
sb = runArray({ ...
    'runew-36', 'runew-2360_wider', 'runew-2361_wider', ...
    'runew-2363_wider', 'runew-2362_wider', ...
              });

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
    'runew-64461-6', 'runew-64461-7', ...
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
fontSize = [20 22 24];
ms = 12; % marker size
trackcolor = [1 1 1]*0.65;
sbslcolor = trackcolor;
tt = [1 250];
seqcolor = flipud(cbrewer('div','RdYlBu',32));
figure; maximize(); pause(0.5);

ax3 = subplot(121);
run.animate_field('eddye', ax3, tt(1), 1);
limx = xlim;
plot(run.eddy.mx/1000, run.eddy.my/1000, 'Color', trackcolor);
plot(run.eddy.mx(tt(1))/1000, run.eddy.my(tt(1))/1000, 'x', ...
     'MarkerSize', ms, 'Color', trackcolor);
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
plot(run.eddy.mx(tt(2))/1000, run.eddy.my(tt(2))/1000, 'x', ...
     'MarkerSize', ms, 'Color', trackcolor);
caxis([-1 1]);
colormap(ax4,seqcolor); beautify(fontSize);
title('Dyes and SSH'); ylabel([]);
ax4.YTickLabel = [];
correct_ticks('y',[],[3 6]);

export_fig('-r450','images/xymap-poster.png');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EW - center tracks - all,
fs  = 18;
ewall.plot_penetration(gca,'all');
maximize();
ax = gca;
title([]); pbaspect([1.618 1 1]);
text(-0.3, 1.5, 'R > L_{sl}', ...
     'FontSize', fs, 'Color', ax.ColorOrder(1,:));
text(0.2, 3.8, 'R ~ L_{sl}', ...
     'FontSize', fs, 'Color', ax.ColorOrder(2,:));
%text(-9, 2.1, 'R < L_{sl}', ...
%     'FontSize', fs, 'Color', ax.ColorOrder(3,:));
text(-6, 3.8, 'R < L_{sl}', ...
     'FontSize', fs, 'Color', ax.ColorOrder(3,:));
%legend('off');
export_fig('images/grs-poster/centrack.pdf');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% EW, NS Center-tracks - wide slope
ew.filter = [];
ns.filter = [];

fontSize = [22 22 30]
figure; maximize();
ax1 = subplot(121);
ew.plot_penetration(ax1, 'all');
beautify(fontSize)
subplot(122);
ns.plot_penetration(gca, 'all'); drawnow;
beautify(fontSize)
ax1 = gca; ax1.XTick = unique([ax1.XTick 1])
export_fig('images/grs-poster/sl-centrack.pdf');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% bottom friction

bfrics.plot_penetration([],'all'); maximize();
pbaspect([1.618 1 1]);
export_fig('images/grs-poster/bfrics-centrack.pdf');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% parameterization
sl.print_diag('bottom torque');
title([]); pause(1);
export_fig('images/grs-poster/penetration-res-param.pdf');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% energy decay
sl.plot_dEdt; maximize(); pause(1);
subplot(121); title([]);
pbaspect([1.618 1 1]); xlim([0 400]);
legend('off');
subplot(122); xlim([0 400]);
pbaspect([1.618 1 1]);
export_fig('images/grs-poster/energy-decay.pdf');