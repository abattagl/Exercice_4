function multicomet(varargin)
%COMET  Comet-like trajectory.
%   COMET(Y) displays an animated comet plot of the vector Y.
%   COMET(X,Y) displays an animated comet plot of vector Y vs. X.
%   COMET(X,Y,p) uses a comet of length p*length(Y).  Default is p = 0.10.
%
%   COMET(AX,...) plots into AX instead of GCA.
%
%   Example:
%       t = -pi:pi/200:pi;
%       comet(t,tan(sin(t))-sin(tan(t)))
%
%   See also COMET3.

%   Charles R. Denham, MathWorks, 1989.
%   Revised 2-9-92, LS and DTP; 8-18-92, 11-30-92 CBM.
%   Copyright 1984-2015 MathWorks, Inc.

% Parse possible Axes input
[ax,args,nargs] = axescheck(varargin{:});
if nargs < 1
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif nargs > 3
    error(message('MATLAB:narginchk:tooManyInputs'));
end

% Parse the rest of the inputs
if nargs < 2, x = args{1}; y = x; x = repmat((1:size(y,1))',1,size(y,2)); end
if nargs == 2
    [x,y] = deal(args{:});
    if size(x,2) == 1
        x = repmat(x,1,size(y,2));
    end
end
if nargs < 3, p = 0.10; end
if nargs == 3, [x,y,p] = deal(args{:}); end

if ~isscalar(p) || ~isreal(p) ||  p < 0 || p >= 1
    error(message('MATLAB:comet:InvalidP'));
end
figure;
ax = newplot(ax);
if ~ishold(ax)
    [minx,maxx] = minmax(x);
    [miny,maxy] = minmax(y);
    axis(ax,[minx maxx miny maxy])
end
colorsh = [0,0.6000,1.0000;1.0000,0.5372,0.0000;0.4660,0.6740,0.1880];
colorsb = [0,0.6000,1.0000;1.0000,0.5372,0.0000;0.2862,0.8352,0.0627];
colorst = [0,0.3607,0.6000;0.8500,0.3250,0.2941;0.2470,0.5450,0.1529];

C = size(colorsh);
C = C(1);

lstyle = '-';

[m,n] = size(x);
k = round(p*m);
for i= 1:n
    head(i) = line('parent',ax,'color',colorsh(mod(i-1,C)+1,:),'marker','o','linestyle','none', ...
                'xdata',x(1,i),'ydata',y(1,i),'Tag','head');
    body(i) = matlab.graphics.animation.AnimatedLine('color',colorst(mod(i-1,C)+1,:),...
        'linestyle',lstyle,...
        'Parent',ax,...
        'MaximumNumPoints',max(1,k),'tag','body');
    tail(i) = matlab.graphics.animation.AnimatedLine('color',colorsb(mod(i-1,C)+1,:),...
        'linestyle','-',...
        'Parent',ax,...
        'MaximumNumPoints',1+m,'tag','tail'); %Add 1 for any extra points
end

if ( length(x) < 2000 )
    updateFcn = @()drawnow;
else
    updateFcn = @()drawnow('limitrate');
end

% Grow the body

for i = 1:k
    for j = 1:n
        set(head(j),'xdata',x(i,j),'ydata',y(i,j));
        addpoints(body(j),x(i,j),y(i,j));
    end
    updateFcn();
end
% Add a drawnow to capture any events / callbacks
drawnow;
% Primary loop
for i = k+1:m
    for j = 1:n
        set(head(j),'xdata',x(i,j),'ydata',y(i,j));
        addpoints(body(j),x(i,j),y(i,j));
        addpoints(tail(j),x(i-k,j),y(i-k,j));
    end
    updateFcn();
end

drawnow;
% Clean up the tail
for i = m+1:m+k
    for j = 1:n
        addpoints(tail(j),x(i-k,j),y(i-k,j));
    end
    updateFcn();
end
drawnow;
end
    

function [minx,maxx] = minmax(x)
minx = min(x(isfinite(x)));
maxx = max(x(isfinite(x)));
if minx == maxx
    minx = maxx-1;
    maxx = maxx+1;
end
end
