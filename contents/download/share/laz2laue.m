function laz2laue(datafile)
%
% function laz2laue(datafile)
% 
%   Script to generate '.lau' type datafile from '.laz' (generates
%   multiples and sorts by h.^2+k.^2+l.^2 )
%
%   Example:
%      laz2laue('/usr/local/lib/mcstas/data/Cu.laz')
%   
% Important details:
%   1) Does NOT change F2 units etc.   
%   2) No clever spacegroup considerations etc. copies every
%   reflection to the other 7 octants...
%   3) Unix specific as it relies on having a 'grep' command on the
%   system path
%   4) Saves resulting datafile to current directory
%

[Path,Name,Ext] = fileparts(datafile);

if isempty(Path)
    Path = '.';
end

% Hack to generate seperate files for header and data blocks
unix(['grep \# ' datafile ' > /tmp/' Name '.hdr']);
unix(['grep -v \# ' datafile ' > /tmp/' Name '.raw']);

% Load the data columns
Laz=load(['/tmp/' Name '.raw']);

% Get the Miller indices and the rest of the data block
h=Laz(:,1);
k=Laz(:,2);
l=Laz(:,3);
rest=Laz(:,4:18);

Lau=Laz;
% Repeat the "first octant" reflections in the other octants...
Lau=[Lau; -h k l rest];
Lau=[Lau; h -k l rest];
Lau=[Lau; h k -l rest];
Lau=[Lau; -h -k l rest];
Lau=[Lau; -h k -l rest];
Lau=[Lau; h -k -l rest];
Lau=[Lau; -h -k -l rest];

% Tau length
Laz=Lau;
h=Laz(:,1);
k=Laz(:,2);
l=Laz(:,3);
nrm=h.^2+k.^2+l.^2;
idx=1:length(nrm);

% Sort by Tau
[nrm0 idx0] = sort(nrm);
idx0=idx(idx0);

% Sort data matrix by Tau and store a temporary list of reflections
Lau=Laz(idx0,:);
save(['/tmp/' Name '.tmp'],'Lau','-ascii');

% Copy back header etc. to .
unix(['cp /tmp/' Name '.hdr ./' Name '.lau']);
unix(['cat /tmp/' Name '.tmp >> ./' Name '.lau']);
