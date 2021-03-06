% finds shelfbreak or end of continental slope (type = 'slope')
%       [xsb,isb,hsb,ax] = find_shelfbreak(fname,type)

function [xsb,isb,hsb,ax] = find_shelfbreak(fname,type)

    h = ncread(fname,'h');

    % flat bottom case
    if isequal(h, max(h(:)) * ones(size(h)))
        xsb = 0;
        isb = 1;
        hsb = max(h(:));
        ax = 'y';
        return
    end
    
    if max(max(diff(h,1,1))) < 1e-3
        try
            xr = ncread(fname,'y_rho')';
        catch
            xr = ncread(fname,'lat_rho')';
        end
        hvec = h(1,:)';
        ax = 'y';
    else
        try
            xr = ncread(fname,'x_rho'); 
        catch
            xr = ncread(fname,'lon_rho');
        end
        hvec = h(:,1);
        ax = 'h';
    end
    dx = avg1(diff(xr(:,1),1,1), 1);
    dh2dx2 = diff(hvec,2,1)./dx.^2;
    if exist('type','var') && strcmpi(type,'slope')
        [~,isb] = min(dh2dx2);
    else
        [~,isb] = max(dh2dx2);
    end
    
    isb = isb-1;
    xsb = xr(isb,1);
    hsb = hvec(isb);