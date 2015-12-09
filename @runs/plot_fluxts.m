%        [handles] = plot_fluxts(runs, factor, isobath, source)
function [handles] = plot_fluxts(runs, factor, isobath, source)

    fluxin = runs.recalculateFlux(factor*runs.bathy.hsb, isobath, source);
    [start, stop] = runs.flux_tindices(fluxin);
    [avgflux, err] = runs.calc_avgflux(fluxin);
    [maxflux,maxloc] = runs.calc_maxflux(fluxin);

    avgflux = avgflux/1000;
    maxflux = maxflux/1000;
    err = err/1000;
    tvec = runs.csflux.time / 86400;
    deltat = (tvec(stop)-tvec(start)) * 86400;
    ifluxvec = cumtrapz(tvec*86400, fluxin);
    iflux0 = ifluxvec(start);
    patchAlpha = 0.3;

    figure;
    insertAnnotation([runs.name '.plot_fluxts(' num2str(factor) ...
                      ', ' num2str(isobath) ', ' num2str(source) ')']);
    [handles.hax, handles.ts(1), handles.ts(2)] = ...
        plotyy(tvec, fluxin/1e3, tvec, ifluxvec);
    axes(handles.hax(1));
    ylabel('Instantaneous Flux (x 10^3 m^3/s)');
    handles.htitle = title(runs.name);
    xlabel('Time (day)');
    hold on;
    handles.maxflx = plot(tvec(maxloc), fluxin(maxloc)/1000, ...
                          'x', 'Color', handles.ts(1).Color);
    handles.patch(1) = patch([tvec(start) tvec(stop) tvec(stop) tvec(start)], ...
                             [avgflux-err avgflux-err avgflux+err avgflux+err], ...
                             handles.ts(1).Color);
    handles.patch(1).FaceAlpha = patchAlpha;
    handles.patch(1).EdgeColor = 'none';
    handles.line(1) = plot([tvec(start) tvec(stop)], [1 1]*avgflux, ...
                           '--', 'Color', handles.ts(1).Color);
    handles.hax(1).YTick = sort(unique(round( ...
        [handles.hax(1).YTick avgflux-err avgflux avgflux+err maxflux], 2)));
    correct_ticks('y', '%.2f', []);

    axes(handles.hax(2));
    hold on
    handles.patch(2) = patch([tvec(start) tvec(stop) tvec(stop) tvec(start)], ...
                    [iflux0  iflux0+(avgflux - err)*1000*deltat ...
                     iflux0+(avgflux + err)*1000*deltat iflux0], handles.ts(2).Color);
    handles.patch(2).FaceAlpha = patchAlpha;
    handles.patch(2).EdgeColor = 'none';
    handles.line(2) = plot([tvec(start) tvec(stop)], ...
                  [iflux0 iflux0+avgflux*1000*deltat], ...
                  '--', 'Color', handles.ts(2).Color);
    ylabel('% Volume transported');
    handles.hax(2).YTick = sort(unique([handles.hax(2).YTick(1) ...
                        ifluxvec(start) ifluxvec(stop) ...
                        handles.hax(2).YTick(end)]));
    handles.hax(2).YTickLabel{2} = '5%';
    handles.hax(2).YTickLabel{3} = '90%';
    handles.hax(2).YTickLabel{4} = '100%';

    hleg = legend([handles.maxflx  ...
                   handles.ts(1) handles.ts(2) ...
                   handles.line(1) handles.line(2) ...
                   handles.patch(1) handles.patch(2)],  ...
                  {'Maximum flux'; ...
                   'Flux - Instantaneous' ; ...
                   '       - Average'; ...
                   'Volume transported - actual'; ...
                   [blanks(32) ' - average flux']; ...
                   '95% confidence - average flux'; ...
                   [blanks(25) ' - volume transported']}, ...
                  'Location', 'NorthWest');

    axes(handles.hax(1)); beautify;
    handles.hax(1).YColor = handles.ts(1).Color;
    handles.hax(1).YLabel.Color = handles.ts(1).Color;

    axes(handles.hax(2)); beautify;
    handles.hax(2).YColor = handles.ts(2).Color;
    handles.hax(2).YLabel.Color = handles.ts(2).Color;

    handles.htext = text(0.05, 0.05, ['y/R = ' num2str(runs.csflux.ndloc(isobath), '%.2f')], ...
                         'Units', 'Normalized');
end