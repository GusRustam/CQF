function plotdiff(zdata1, zdata2, zdata3)
%CREATEFIGURE(ZDATA1,ZDATA2,ZDATA3)
%  ZDATA1:  surface zdata
%  ZDATA2:  surface zdata
%  ZDATA3:  surface zdata

%  Auto-generated by MATLAB on 12-Jun-2013 19:04:43
if nargin < 3
    zdata3=zdata2-zdata1;
end
% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1,...
    'Position',[0.13 0.583837209302326 0.334659090909091 0.341162790697674]);
view(axes1,[-37.5 30]);
grid(axes1,'on');
hold(axes1,'all');

% Create mesh
mesh(zdata1,'Parent',axes1);

% Create subplot
subplot1 = subplot(2,2,2,'Parent',figure1);
view(subplot1,[-37.5 30]);
grid(subplot1,'on');
hold(subplot1,'all');

% Create mesh
mesh(zdata2,'Parent',subplot1);

% Create subplot
subplot2 = subplot(2,2,3,'Parent',figure1);
view(subplot2,[-37.5 30]);
grid(subplot2,'on');
hold(subplot2,'all');

% Create mesh
mesh(zdata3,'Parent',subplot2);

% Create subplot
subplot3 = subplot(2,2,4,'Parent',figure1);
view(subplot3,[-37.5 30]);
grid(subplot3,'on');

