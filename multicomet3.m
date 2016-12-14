function comet3(varargin)
%COMET3 3-D Comet-like trajectories.
%   COMET3(Z) displays an animated three dimensional plot of the vector Z.
%   COMET3(X,Y,Z) displays an animated comet plot of the curve through the
%   points [X(i),Y(i),Z(i)].
%   COMET3(X,Y,Z,p) uses a comet of length p*length(Z). Default is p = 0.1.
%
%   COMET3(AX,...) plots into AX instead of GCA.
%
%   Example:
%       t = -pi:pi/500:pi;
%       comet3(sin(5*t),cos(3*t),t)
%
%   See also COMET.

%   Charles R. Denham, MathWorks, 1989.
%   Revised 2-9-92, LS and DTP; 8-18-92, 11-30-92 CBM.
%   Copyright 1984-2015 MathWorks, Inc.

% Parse possible Axes input
[ax,args,nargs] = axescheck(varargin{:});

if nargs < 1
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif nargs > 4
    error(message('MATLAB:narginchk:tooManyInputs'));
end

% Parse the rest of the inputs
if nargs < 2, x = args{1}; end
if nargs == 2, y = args{2}; end
if nargs < 3, z = x; x = 1:length(z); y = 1:length(z); end
if nargs == 3, [x,y,z] = deal(args{:}); end
if nargs < 4, p = 0.10; end
if nargs == 4, [x,y,z,p] = deal(args{:}); end

if ~isscalar(p) || ~isreal(p) || p < 0 || p >= 1
    error(message('MATLAB:comet3:InvalidP'));
end

ax = newplot(ax);
if ~ishold(ax),
    [minx,maxx] = minmax(x);
    [miny,maxy] = minmax(y);
    [minz,maxz] = minmax(z);
    axis(ax,[minx maxx miny maxy minz maxz])
end

colorsh = [0,0.6000,1.0000;1.0000,0.5372,0.0000;0.4660,0.6740,0.1880];
colorsb = [0,0.6000,1.0000;1.0000,0.5372,0.0000;0.2862,0.8352,0.0627];
colorst = [0,0.3607,0.6000;0.8500,0.3250,0.2941;0.2470,0.5450,0.1529];

lstyle = '-';

[m,n] = size(x);
k = round(p*m);
for i= 1:n
    head = line('parent',ax,'color',colorsh(1,:),'marker','o', ...
        'xdata',x(1,i),'ydata',y(1,i),'zdata',z(1,i),'tag','head');

    % Choose first three colors for head, body, and tail
    body = animatedline('parent',ax,'color',colorsb(2,:),'linestyle',lstyle,...
                        'MaximumNumPoints',max(1,k),'Tag','body');
    tail = animatedline('parent',ax,'color',colorst(3,:),'linestyle','-',...
                        'MaximumNumPoints',1+m, 'Tag','tail');
end
if ( length(x) < 2000 )
    updateFcn = @()drawnow;
else
    updateFcn = @()drawnow('limitrate');
end

% Grow the body
for i = 1:k
    for j = 1:n
        set(head,'xdata',x(i,j),'ydata',y(i,j),'zdata',z(i,j))
        addpoints(body,x(i),y(i),z(i));
    end
    updateFcn();
end
drawnow;

% Primary loop
m = length(x);
for i = k+1:m
    for j = 1:n
        set(head,'xdata',x(i,j),'ydata',y(i,j),'zdata',z(i,j))
        addpoints(body,x(i,j),y(i,j),z(i,j));
        addpoints(tail,x(i-k,j),y(i-k,j),z(i-k,j));
    end
    updateFcn();
end
drawnow;
% Clean up the tail
for i = m+1:m+k
    for j = 1:n
        addpoints(tail, x(i-k,j),y(i-k,j),z(i-k,j));
    end
    updateFcn();
end
drawnow

% same subfunction as in comet
function [minx,maxx] = minmax(x)
minx = min(x(isfinite(x)));
maxx = max(x(isfinite(x)));
if minx == maxx
    minx = maxx-1;
    maxx = maxx+1;
end
