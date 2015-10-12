% plots average velocity seen by shelf-slope water at a given isobath
function [] = avgStreamerVelSection(runs, isobath, source)

    debug = 1;
    if ~exist('source', 'var')
        warning('Using source = isobath');
        source = isobath;
    end

    if isobath > length(runs.csflux.ix)
        error(['Choose a lower isobath number. Max = ' ...
               length(runs.csflux.ix)])
    end

    if source > isobath
        error('Source is offshore of isobath.');
    end

    [start,stop] = runs.flux_tindices(runs.csflux.west.slope(:, isobath, source));
    tindices = [start stop];
    ix = runs.csflux.ix(isobath) + 1; % WORKAROUND FOR CSFLUXES BUG
    volr = {runs.bathy.axis ix ix};
    volv = {runs.bathy.axis ix-1 ix};
    xivec = -200:runs.rgrid.dx/1000:200;
    zvec = runs.csflux.vertbins(:,isobath);

    if runs.bathy.axis == 'x'
        xvec = runs.rgrid.y_rho(2:end-1,1)/1000;
        mx = runs.eddy.my(start:stop)/1000;
        bathyax = 1;
    else
        xvec = runs.rgrid.x_rho(1,2:end-1)/1000;
        mx = runs.eddy.mx(start:stop)/1000;
        bathyax = 2;
    end

    tic; disp([runs.name ': Reading data...'])
    v = squeeze(avg1(dc_roms_read_data(runs, runs.csvelname, tindices, volv), bathyax));
    csdye = dc_roms_read_data(runs, runs.csdname, tindices, volr);
    toc;

    % interpolate onto common grid centered on eddy center
    % this is not working well!!!
    tic; disp([runs.name ': interpolating data...']);
    clear vi csdyei
    for tt=1:size(v,3)
        for zz=1:size(v,2)
            vi(:,zz,tt) = interp1(xvec-mx(tt), v(2:end-1,zz,tt), xivec);
            csdyei(:,zz,tt) = interp1(xvec-mx(tt), csdye(2:end-1,zz,tt), xivec);
        end
    end
    toc;

    vmeanwest = mean(bsxfun(@times, vi .* (csdyei < runs.csflux.x(source)), ...
                            xivec' < 0), 3);
    vmean = mean(vi .* (csdyei < runs.csflux.x(source)), 3);
    pmean = trapz(xivec, repnan(vmeanwest,0), 1); % mean profile
    pint = runs.csflux.west.slopewater.vertitrans(:,isobath,source);

    hf = figure;
    insertAnnotation([runs.name '.avgStreamerVelSection']);
    if debug, ax1 = subplot(2,3,[4 5]); end
    pcolorcen(xivec, zvec, vmean');
    xlabel('X - X_{eddy} (km)'); ylabel('Z (m)');
    liney(-runs.bathy.hsb);
    linex(0);
    title([runs.name ' | y/R = ' num2str(runs.csflux.ndloc(isobath))]);
    hcb = center_colorbar;

    L = runs.eddy.rhovor.lmaj(1)/1000;
    R = runs.csflux.R/1000;

    if debug
        a = 3; Ln = L/3;
        yoR = runs.csflux.ndloc(isobath); % y/R - used in csflux
        y0oL = R/L * (1 - yoR); % y0/L - used in derivation
        ideal = runs.streamer_ideal_profile(isobath);
        idealx = trapz(zvec, ideal) *  ...
                 diff(exp(-abs(xivec'/Ln).^a))./diff(xivec'/Ln) ...
                 * exp(-y0oL.^2);
        actualx = trapz(zvec, vmean, 2);

        ax2 = subplot(2,3,[1 2]);
        plot(xivec, actualx./max(actualx));
        hold on;
        plot(avg1(xivec), idealx./max(idealx), 'k-');
        linex(0); liney(0);
        ylabel('Flux (m^2/s)');

        ax3 = subplot(236);
        plot(pmean./max(pmean), zvec);
        hold on;
        plot(pint./max(pint), zvec);
        plot(ideal, zvec);
        legend('Mean', 'Integrated', 'Idealized', 'Location', 'SouthEast');

        colorbar(hcb, 'hide');
        linkaxes([ax1 ax2], 'x');
        linkaxes([ax1 ax3], 'y');
    end

end