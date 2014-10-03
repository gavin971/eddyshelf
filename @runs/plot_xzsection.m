function [] = plot_xzsection(runs, days)

    tind = vecfind(runs.time, days*86400);
    yind = runs.bathy.isb + [0 10 20 30];

    xr = runs.rgrid.x_v(1,:)/1000;

    zmin = min(runs.rgrid.z_v(:,max(yind),1));
    for ii=1:4
        figure; maximize;
        for jj=1:4
            eddye = dc_roms_read_data(runs.dir, 'v', tind(ii), ...
                                      {runs.bathy.axis yind(jj) ...
                                yind(jj)}, [], runs.rgrid, 'his', ...
                                      'single');

            zr = runs.rgrid.z_r(:, yind(jj), 1);

            subplot(2,2,jj)
            pcolorcen(xr, zr, eddye');
            hold on
            contour(xr, zr, eddye', [1 1]*runs.eddy_thresh, 'k', ...
                    'LineWidth', 2);
            title(['Day = ' num2str(days(ii)) ' | y = ' ...
                   num2str(runs.rgrid.y_rho(yind(jj),1)/1000) ' ' ...
                   'km']);
            ylim([zmin 0]);
            caxis([-1 1]*0.05);
            liney(-1*runs.bathy.hsb);
        end
    end
end