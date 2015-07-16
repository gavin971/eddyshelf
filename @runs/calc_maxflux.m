% return magnitude and time index of max flux
function [maxflux, maxloc] = calc_maxflux(runs, fluxin)

    debug = 0;
    
    iflux = cumtrapz(runs.csflux.time, fluxin);
    [start,stop] = runs.flux_tindices(fluxin);

    % This smoothing is used only to make peak detection work
    % better. i.e., this makes maxloc a better estimate neglecting
    % some smaller peaks that might occur earlier.
    % The maxflux value is from the actual *unsmoothed*  time
    % series at time index "maxloc"
    nsmooth = 5;

    % flux vector for applicable time
    % convert everything to double since I'm
    % dealing with large numbers here (time in
    % seconds) and integrated flux (m^3)
    fluxvec = double(smooth(fluxin(start:stop), nsmooth));
    tvec = double(runs.csflux.time(start:stop));

    [~,locs] = findpeaks(fluxvec, ...
                         'MinPeakProminence', 0.15*max(fluxvec(:)));

    % select the first peak.
    maxloc = locs(1);

    % correct time shift
    maxloc = maxloc + start - 1;

    if debug
        figure;
        %findpeaks(fluxin, 'MinPeakProminence', 0.25*max(fluxvec(:)), ...
        %          'annotate', 'extents');
        plot(fluxin);
        linex((maxloc));
        title(runs.name);
    end

    maxflux = fluxin(maxloc,1);
    runs.csflux.maxflux = maxflux;
    runs.csflux.maxloc = maxloc;
end