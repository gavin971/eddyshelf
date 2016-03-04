% some quick and dirty estimates for the MAB

woa = load('../datasets/woa05.mat');
load('data/etopo2_extract.mat');
latdeep = 40;
londeep = -62.5;

latshelf = 41.5;
lonshelf = -67.5;

f0 = 2 * (2*pi/86400) * sind(latdeep);

% deep water point
ixdtopo = find_approx(topo.x, londeep);
iydtopo = find_approx(topo.y, latdeep);
ixdwoa = find_approx(woa.X, 360 + londeep);
iydwoa = find_approx(woa.Y, latdeep);

% shelf point
ixstopo = find_approx(topo.x, lonshelf);
iystopo = find_approx(topo.y, latshelf);
ixswoa = find_approx(woa.X, 360 + lonshelf);
iyswoa = find_approx(woa.Y, latshelf);

% figure out indices for bathymetry / N² cross-section
[ixt, iyt] = bresenham(ixdtopo, iydtopo, ixstopo, iystopo);
[ixw, iyw] = bresenham(ixdwoa, iydwoa, ixswoa, iyswoa);
% subsample
ixt = ixt(1:3:end); iyt = iyt(1:3:end);

zind = sub2ind(size(topo.z), ixt, iyt);

%% distance for gradient calculation
nsmooth = 3;
dist = sw_dist(topo.x(ixt), topo.y(iyt), 'km')*1000;
h = topo.z(zind);
dhdx = diff(smooth(h,nsmooth))./dist;
dh2dx2 = diff( dhdx) ./ diff(dist);
% bottom slope
alpha = max(abs(dhdx));

% plot location
figure
subplot(1,2,1)
contour(topo.x, topo.y, topo.z', [-100 -200 -500 -1000 -2000 -3000 -4000], 'k');
hold on
contour(topo.x, topo.y, topo.z', [0 0], 'k', 'LineWidth', 3);
plot(londeep, latdeep, 'r*', lonshelf, latshelf, 'b.', 'MarkerSize', 16);
plot(topo.x(ixt), topo.y(iyt), 'r-');

subplot(1,2,2);
plot([0;cumsum(dist)]/1000,h,'k-'); hold on
plot([0; cumsum(dist)]/1000,smooth(h,nsmooth) ,'r*-')
plot([cumsum(dist)]/1000, dhdx * -1e5, 'b-');
liney( alpha * -1e5);
legend('raw h', 'smoothed h','dhdx * -1e5');

%%
% make sure I'm in deep enough water
%topo.z(ixtopo, iytopo)

% 1st index is deep water, last is shelf water
for ii=1:length(ixw)
    ii
    N2mat(ii,:) = bfrq(woa.sal(:,iyw(ii),ixw(ii)), ...
                       woa.temp(:,iyw(ii), ixw(ii)), ...
                       woa.Z, latdeep);
end

[Vmode, Hmode, c] = vertmode(N2mat(1,:)', woa.Z, 1, 0);
%subplot(1,3,3);
%liney(abs(zbc1))
znew = avg1(woa.Z);
zbc1 = znew(find_approx(Hmode,0,1));

Ndeep = sqrt(max(N2mat(1,:)));

% now for slope - find N² at location of max dh/dx
[~,imax] = max(dhdx);
% convert indices to woa grid
ixslw = find_approx(woa.X, 360+topo.x(ixt(imax)))-1;
iyslw = find_approx(woa.Y, topo.y(iyt(imax)))-1;
% calculate N2
N2slope = bfrq(woa.sal(:,iyslw, ixslw), woa.temp(:,iyslw, ixslw), ...
               woa.Z, woa.Y(iyslw));
Nslope = sqrt(max(N2slope));

%% N² profiles



%% find zero crossing of horizontal velocity mode

disp(['Total depth = ' num2str(topo.z(ixdtopo, iydtopo)) ' m | ' ...
      'Zero crossing of BC1 at approx. ' ...
       num2str(zbc1), ' m']);
fprintf('Max N2 = %.3e s^{-2} | N/f = %.2f | L_D = %.3f km \n', ...
         max(N2mat(1,:)), Ndeep/f0, c/f0/1000)
fprintf('Burger_slope = %.4f | alpha = %.4f \n', Ndeep/f0*alpha, alpha)
fprintf('Shelfbreak depth = 130 m | Shelfbreak depth / zero crossing depth = %.4f\n ', ...
         130/zbc1)
fprintf('Slope width = 175 km | Slope width / L_D = %.2f \n', 175000/c*f0)
fprintf('But above Lsl/Ld scaling doesn''t work for constant slope.\n');
fprintf('for constant max.(dhdx) slope, Lsl = 80km | Lsl/Ld = %.2f \n', 80000/c*f0);