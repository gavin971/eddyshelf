% mosaic animate_field plots.
%     [handles] = mosaic_field(runArray, varname, timesteps, opt, clim)

function [handles] = mosaic_field(runArray, varname, timesteps, opt, clim)
    if length(runArray.filter) > 4
        error('Too many runs selected for 2x2 mosaic!');
    end

    if ~exist('timesteps', 'var') | isempty(timesteps)
        timesteps = {'max flux'; 'max flux'; 'max flux'; 'max flux'};
    end

    if ~exist('clim', 'var'), clim = []; end

    filter = runArray.filter;

    figure; maximize;
    ax = packfig(ceil(length(runArray.filter)/2), 2);
    insertAnnotation('runArray.mosaic_field');
    for ii=1:length(runArray.filter)
        if iscell(timesteps)
            tstep = timesteps{ii};
        else
            if ischar(timesteps)
                tstep = timesteps;
            else
                tstep = timesteps(ii);
            end
        end

        axes(ax(ii));
        handles(ii) = runArray.array(filter(ii)).animate_field(varname, gca, tstep, 1, opt);
        title('');
    end

    for ii=1:length(runArray.filter)
        axes(ax(ii));
        handles(ii).hrunname = text(0.80, handles(ii).htlabel.Position(2), ...
                                    runArray.getname(runArray.filter(ii)), ...
                                    'Units', 'normalized');
        handles(ii).hax = ax(ii);
    end

    linkaxes(ax, 'xy'); %axis tight;
    if isempty(clim), clim = caxis; end

    [handles(1).supax, handles(1).htitle] = suplabel(['Surface ' varname], 't');
    handles(1).supax.Position(4) = 0.88;
    handles(1).htitle.FontWeight = 'normal';

    axes(ax(1));
    colorbar('off'); caxis(clim);

    axes(ax(2));
    caxis(clim); ylabel(''); colorbar('off');
    ax(2).YTickLabel = {};

    if length(ax) ~= 2
        ax(1).XTickLabel = {};
        ax(1).XLabel.String = '';
        ax(2).XLabel.String = '';
        ax(2).XTickLabel = {};
    end
    try
        axes(ax(3));
        caxis(clim); colorbar('off'); ax(3).XTickLabel{end} = '';
        axes(ax(4));
        caxis(clim); ax(4).YTickLabel = {''}; ylabel('');
        hcb = colorbar; moveColorbarOut2x2(hcb);
    catch ME
        hcb = colorbar; moveColorbarOut1x2(hcb);
    end

    handles(1).hcb = hcb;
end
