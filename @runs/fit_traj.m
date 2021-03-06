% tanh fit to eddy.my or eddy.hcen
% save output in runs.traj
function [] = fit_traj(runs, tcrit)

    debug = 0;

    if ~exist('tcrit', 'var'), tcrit = 1.1; end

    tvec = runs.ndtime';
    % get unique timesteps
    [ut,uind,~] = unique(tvec, 'stable');

    tvec = tvec(uind);

    use_my = 1;
    if use_my
        if runs.bathy.axis == 'y'
            yvec = runs.eddy.my(uind);
            laby = 'Y (m)';
            axis = runs.rgrid.y_rho(:,1);
        else
            yvec = runs.eddy.mx(uind);
            laby = 'X (m)';
            axis = runs.rgrid.x_rho(1,:);
        end

        % locate origin in the middle of the
        % straight line section.
        %iref = find_approx(yvec, ...
        %                   (yvec(1)+min(yvec))/2, 1);
    else
        yvec = runs.eddy.hcen(uind);
        i0 = find(yvec == yvec(1), 1, 'last');

        % locate origin in the middle of the
        % straight line section.
        %iref = find_approx(yvec, ...
        %                   (yvec(i0)+min(yvec))/2, 1);
    end

    % avoid using iref. Use the fit instead
    % y = yref + y0 * tanh( (t-tref)/T ) + y1 * (t-tref)/T
    [y0,T,y1,tref,yref] = runs.tanh_fit(tvec, yvec, 0);
    tfit = tvec - tref;

    % location and water depth along idealized
    % trajectory.
    if use_my
        ytraj = y0*tanh(tfit./T) + y1*(tfit./T) + ...
                yref;
        itraj = vecfind(axis, ytraj);
        if runs.bathy.axis == 'y'
            htraj = runs.bathy.h(1,itraj);
        else
            htraj = runs.bathy.h(itraj,1);
        end
        str = 'y = eddy.my';
    else
        % clamp to max water depth
        htraj = min(y0*tanh(tfit./T) + y1*(tfit./T) + ...
                    yref, max(runs.bathy.h(:)));
        itraj = vecfind(runs.bathy.h(1,:), ...
                        htraj);
        ytraj = runs.eddy.my(uind);
        str = 'y = hcen';
    end

    % sometimes T comes out as negative. not
    % sure why
    tind = find_approx(tvec - tref, tcrit*abs(T), 1);

    H = htraj(tind);
    Y = ytraj(tind);

    if debug
        figure;
        if use_my
            subplot(211);
            plot(tvec, yvec, '*', tvec, ytraj);
            liney(Y);
            linex(tvec(tind));
            ylabel(laby);
            subplot(212);
        end
        plot(tvec, runs.eddy.hcen(uind), '*', tvec, ...
             htraj);
        liney(H);
        linex(tvec(tind));
        xlabel('Non-dimensional time');
        ylabel('Water depth');
        title(runs.name);
    end
    % y,t scales (corrected for earlier reference shift)
    yscl = y0;
    % T is a timescale for the tanh. I can do corrections later.
    tscl = T * runs.eddy.turnover;

    runs.traj.use_my = use_my;
    runs.traj.yscl = yscl;
    runs.traj.tscl = tscl;
    runs.traj.tcrit = tcrit;
    runs.traj.tind = tind;
    runs.traj.y0 = y0;
    runs.traj.y1 = y1;
    runs.traj.yref = yref;
    runs.traj.tref = tref;
    runs.traj.H = H;
    runs.traj.Y = Y;
    runs.traj.T = T;
    runs.traj.htraj = htraj;
    runs.traj.ytraj = ytraj;
    runs.traj.str = str;
    runs.traj.yerr = sqrt(mean( (yvec(1:tind)-ytraj(1:tind)).^2));
    runs.traj.herr = runs.bathy.sl_slope * runs.traj.yerr;
    disp([runs.traj.yerr/1000 runs.traj.herr runs.traj.T])
    runs.traj.comment = ['Fit y = y0*tanh((t-tref)/T) + y1*((t-tref)/T) + yref| ' ...
                        'Use y = water depth (hcen) if use_my =0, ' ...
                        'y = eddy.my otherwise | ' ...
                        '(H,Y) = interpolated location / water-depth ' ...
                        'at t = tcrit | (y0,y1,T) are parameters of ' ...
                        'the fit in a different reference frame | ' ...
                        '(yscl,tscl) are (y0,T) corrected for ' ...
                        'reference shift. | (htraj,ytraj) are actual ' ...
                        'fits. ytraj is meaningless when fitting to ' ...
                        'hcen i.e., with use_my = 0'];
    %runs.traj.hash = githash([mfilename('fullpath') '.m']);

    traj = runs.traj;
    save([runs.dir '/traj.mat'], 'traj');
end