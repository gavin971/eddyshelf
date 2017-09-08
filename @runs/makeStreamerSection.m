% makes streamer mask for numerical parameterization
function [v, mask, rho, xvec, zvec] = ...
        makeStreamerSection(runs, isobath, maxloc, V0, L0, Lz0)

    debug = 0;
    circle_kink = 0;

    phys = runs.params.phys;

    if ~exist('V0', 'var') || isempty(V0)
        if ~exist('maxloc', 'var') || isempty(maxloc)
            [~,maxloc] = runs.calc_maxflux(isobath);
        end

        %V0 = runs.eddy.rhovor.Vke(maxloc);
        vel = smooth(hypot(runs.eddy.fitx.V0, runs.eddy.fity.V0), 20) / 2.3 / sqrt(2);
        V0 = vel(maxloc);
    end

    if ~exist('L0', 'var') || isempty(L0)
        if ~exist('maxloc', 'var') || isempty(maxloc)
            [~,maxloc] = runs.calc_maxflux(isobath);
        end

        L0 = median(runs.eddy.rhovor.dia(1:maxloc))/2;
    end

    if ~exist('Lz0', 'var') || isempty(Lz0)
        if ~exist('maxloc', 'var') || isempty(maxloc)
            [~,maxloc] = runs.calc_maxflux(isobath);
        end

        Lz0 = runs.eddy.Lgauss(maxloc);
    end

    zvec = runs.csflux.vertbins(:, isobath);
    xvec = runs.rgrid.x_rho(1,2:end-1) - mean(runs.rgrid.x_rho(1,:));

    % normalized grid matrices to create mask
    [xmat, zmat] = ndgrid(xvec/L0, zvec/Lz0);

    R = runs.csflux.R;
    yoR = runs.csflux.ndloc(isobath); % y/R - used in csflux
                                      %y0oL =  R/L0 * (1 - yoR); % y0/L - used in derivation
                              %xfrac = sqrt(1 - y0oL^2);
    %y0oL = (runs.eddy.my(maxloc) - runs.csflux.x(isobath))/L0;

    % this works - compares ok with runs.eddy.fity.rho0(1)
    % RhoAmp = -1 * runs.sgntamp * V0 * phys.f0 * phys.R0/phys.g * L0/Lz0;

    % eddy fields
    a = 2;
    v = -sqrt(2*exp(1)) * runs.sgntamp * V0 * xmat.^(a-1) .* exp(-xmat.^a) .* (1-erf(-zmat));
    % rho = RhoAmp .* exp(-xmat.^2 - y0oL^a) .* exp(-zmat.^2);

    % % calculate background density profiles
    % [rhoshelf, zshelf] = runs.getDensityProfile(runs.bathy.isb);
    % [rhoslope, zslope] = runs.getDensityProfile(runs.csflux.ix(isobath));

    % rhobot = rhoshelf(1);
    % rhoedge = RhoAmp * exp(-y0oL^a) * exp(-1/2) * exp(-(zslope/Lz0).^2);
    % zind = find_approx(rhoslope + rhoedge, rhobot, 1);
    % width = zvec(zind);

    % [width, zpeak] = runs.predict_zpeak(isobath, 'use', maxloc);
    % width = abs(width/Lz0); % zpeak = abs(zpeak/Lz0);

    % if circle_kink
    %     kzrad = width/2; % kink radius - z
    %     kxrad = kzrad; % kink radius - x
    %     x0 = -xfrac-kxrad; -xfrac-kxrad;
    %     z0 = -1 * width/3;
    %     if ~isreal(xfrac)
    %         % complex xfrac -- cannot be trusted
    %         % make the kink (semi-circle) intersect the eddy contour
    %         xfrac = sqrt(1 - (width)^2);
    %         x0 = -xfrac;
    %         xline = 0;
    %     end
    % end

    xline = 0;

    if isobath == 0
        % if close to shelfbreak use barotropic mask
        % account for sloping shelf by integrating only
        % to Rhines length scale (L_β). This needs to be
        % normalized by L0, of course.
        % I use x/L = -1 as a reference for where there is almost
        % no velocity. So, starting at -1, integrate a distance of L_β.
        % So, mask is x/L < -(1-L_β)
        % If no shelf slope, L_β is set to 1, so that I integrate over all
        % offshore flow.
        if runs.bathy.sl_shelf ~= 0
            betash = runs.params.phys.f0/runs.bathy.hsb * runs.bathy.sl_shelf;
            Lbeta = 1.37*sqrt(V0/betash) - 3300;

            Lcorr = 1 - 1.42*runs.rrshelf*pi/L0;
            %Lcorr = sqrt((1-Lbeta)^2 - 1/2);

            if Lcorr > 1
                % for gentle slopes, I shouldn't do anything.
                Lcorr = 1;
            end
        else
            Lcorr = 1;
        end

        Lcorr = 1;
        mask = xmat < -(1-Lcorr);
    else
        eddymask = ((xmat.^a + zmat.^a) > 1.0^a);
        % if circle_kink
        %     kinkmask = (((xmat-x0)/kxrad).^2 + ((zmat-z0)/kzrad).^2) <= 1;
        % else
        %     kinkmask = ((xmat.^a + zmat.^a) > (1)^a) .* (zmat >= -width);
        % end
        mask = (xmat < xline) & (eddymask);
    end

    if debug
        figure;
        pcolorcen(xmat, zmat, v);
        center_colorbar;
        hold on
        try
            contour(xmat, zmat, kinkmask, 'k');
            contour(xmat, zmat, eddymask, 'r');
            linex(xline);
        catch ME
        end
        contour(xmat, zmat, mask, 'b');
    end
end
