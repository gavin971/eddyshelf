% locate point of "resistance"
% defined as start of half the maximum southward speed.
% returns center locations and time index
% nsmooth is number of turnover periods to smooth over
% factor * v_min is what I'm looking for.
function [xx,yy,tind] = locate_resistance(runs, nsmooth, factor)

    debug_plot = 0;

    if ~exist('factor', 'var'), factor = 1/3; end
    if ~exist('nsmooth', 'var'), nsmooth = 6; end
    % number of points to smooth over.
    npts = (nsmooth*runs.eddy.turnover/86400);

    % support cyclones too
    sgn = sign(runs.params.eddy.tamp) * ...
          sign(runs.params.phys.f0);

    % smooth velocity a lot!
    if runs.bathy.axis == 'y'
        cen = smooth(runs.eddy.vor.cy, npts)/1000;
        mcen = runs.eddy.my/1000;
        %vel = smooth(runs.eddy.mvy, npts);
        % figure;
        % subplot(211)
        % plot(runs.eddy.my/1000); hold all
        % plot(cy);
        % subplot(212)
        % plot(smooth(runs.eddy.mvy, 15)); hold all
        % plot(vel);
    else
        cen = smooth(runs.eddy.vor.cx, npts)/1000;
        mcen = runs.eddy.mx/1000;
    end
    ndtime = runs.eddy.t*86400./runs.eddy.turnover;
    vel = sgn * [0; diff(cen)./diff(smooth(runs.eddy.t', npts))];

    % locate minimum, i.e., max. southward/westward speed
    % but limit search to first 'n' turnover time scales

    it = find_approx(ndtime, 60);
    %[mn, imin] = min(vel(5:it));
    [mn, imin] = min(vel(:));

    vv = vel(imin:end) - mn * factor;
    tind = find(vv > 0, 1, 'first');
    tind = tind + imin;

    xx = runs.eddy.mx(tind);
    yy = runs.eddy.my(tind);

    if debug_plot
        figure;
        insertAnnotation('runArray.locate_resistance');
        subplot(221)
        plot(ndtime, mcen);
        title(runs.name);
        linex(ndtime(tind));

        subplot(223)
        plot(ndtime, vel);
        linex(ndtime(imin)); liney(mn); liney(mn*factor);
        linex(ndtime(tind));

        subplot(2,2,[2 4])
        plot(runs.eddy.mx/1000, runs.eddy.my/1000);
        hold on; axis image
        plot(xx/1000, yy/1000, 'x', 'MarkerSize', 14);
    end
end