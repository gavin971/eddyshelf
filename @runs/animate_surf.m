% animate variables at the surface

function [] = animate_surf(runs, varname, t0, ntimes)

    if ~exist('ntimes', 'var'), ntimes = length(runs.time); end
    if ~exist('t0', 'var'), t0 = 1; end

    dt = 4;

    runs.video_init(['surf-' varname]);

    % cross-shelf dye?
    if strcmpi(varname, runs.csdname)
        if isempty(runs.csdsurf) | isnan(runs.zeta(:,:,t0))
            if ntimes == 1
                tindices = t0;
            else
                tindices = [];
            end
            runs.csdsurf = dc_roms_read_data(runs.dir, runs.csdname, tindices, {'z' ...
                                runs.rgrid.N runs.rgrid.N}, [], runs.rgrid, ...
                                             'his');

            name = 'runs.csdsurf';
            varname = 'cross-shelf dye conc.';
         end
    end

    % eddy dye?
    if strcmpi(varname, runs.eddname)
        if isempty(runs.eddsurf) | isnan(runs.eddsurf(:,:,t0))
            if ntimes == 1
                tindices = t0;
            else
                tindices = [];
            end

            runs.eddsurf = dc_roms_read_data(runs.dir, runs.eddname, tindices, {'z' ...
                                runs.rgrid.N runs.rgrid.N}, [], runs.rgrid, ...
                                             'his');

            name = 'runs.eddsurf';
            varname = 'eddy dye conc.';
        end
    end

    titlestr = ['Surface ' varname];

    xr = runs.rgrid.x_rho'/1000;
    yr = runs.rgrid.y_rho'/1000;
    tt = t0;

    figure;
    eval(['hpc = pcolorcen(xr, yr, ' name '(:,:,tt));']);
    hold on; colorbar; freezeColors;

    he = runs.plot_eddy_contour('contour', tt);
    hbathy = runs.plot_bathy('contour', 'k');
    ht = runs.set_title(titlestr, tt);

    linex(runs.asflux.loc/1000);

    if ntimes > 1
        runs.video_update();
        for tt=t0+1:dt:ntimes
            eval(['set(hpc, ''CData'', ' name '(:,:,tt));']);
            runs.update_eddy_contour(he, tt);
            runs.update_title(ht, titlestr, ii);
            runs.video_update();
            pause(1);
        end
        runs.video_write();
    end
end