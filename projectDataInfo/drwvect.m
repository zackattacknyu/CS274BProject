function oh = drwvect(bounds,dim,vfilnam,clr)
% drwvect -- given a rectangle, a dimension [nr nc], and a file,
%	of coords generated from arcs ungenerate and ug2mat
%	draw the vectors on the current figure.
%	Assume that the coords are in dd
%	
%	by DKB 3/18/96

hold on
vec = loadfn(vfilnam);

clrstr=1;
if nargin < 4
	clr = 'y';
else
	if (isstr(clr))
		clrstr=1;
	else
		clrstr=0;
	end
end

nm = bounds(1);
tm = bounds(2);
nx = bounds(3);
tx = bounds(4);

ind = find((vec(:,1) >= nm & vec(:,2) >= tm & ...
	    vec(:,1) <= nx & vec(:,2) <= tx) | isnan(vec(:,1)));
vec = vec(ind,:);

dy = tx - tm;
dx = nx - nm;
ypp = dy/dim(1);
xpp = dx/dim(2);

vec(:,1) = (vec(:,1) - nm)/xpp;
vec(:,2) = (tx - vec(:,2))/ypp;

if nargout > 0
	if(clrstr)
		oh = plot(vec(:,1),vec(:,2),clr);
	else
		oh = plot(vec(:,1),vec(:,2));
		set(oh,'color',clr);
	end
else
	if(clrstr)
		plot(vec(:,1),vec(:,2),clr);
	else
		temph = plot(vec(:,1),vec(:,2));
		set(temph,'color',clr);
	end
end
