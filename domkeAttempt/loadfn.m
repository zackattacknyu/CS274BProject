function odat = loadfn(ifn)
% loadfn	does a load on a filename input.
%
%	SYNTAX:  odat = loadfn(filename)
%
%	By DKB (dank) 12/2/94
%

vers = version;
if(strcmp(vers(1:3),'5.2'))
	odat = load(ifn);
elseif(strcmp(vers(1:3),'5.1'))
  eval(['load ' ifn ' -ascii'])

  pnt = find(ifn == '.');
  if isempty(pnt)
        pnt = length(ifn);
  else
        pnt = pnt - 1;
  end

  ipnt = find(ifn == '/');
  if isempty(ipnt)
	ipnt = 1;
  else
	ipnt = ipnt(length(ipnt))+1;
  end

  bnam = ifn(ipnt:pnt);

  eval(['odat = ' bnam ';']);
  
else
  eval(['load -ascii ' ifn])

  pnt = find(ifn == '.');
  if isempty(pnt)
        pnt = length(ifn);
  else
        pnt = pnt - 1;
  end

  ipnt = find(ifn == '/');
  if isempty(ipnt)
	ipnt = 1;
  else
	ipnt = ipnt(length(ipnt))+1;
  end

  bnam = ifn(ipnt:pnt);

  eval(['odat = ' bnam ';']);
end
