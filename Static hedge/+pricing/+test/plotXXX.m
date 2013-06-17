function plotXXX(data)

%  Auto-generated by MATLAB on 14-Jun-2013 21:01:56

% Create figure
figure1 = figure;

% Create axes
axes1 = axes('Parent',figure1);
box(axes1,'on');
hold(axes1,'all');

% Create multiple lines using matrix input to plot
plot1 = plot(data,'Parent',axes1);
set(plot1(1),'DisplayName','certain min');
set(plot1(2),'DisplayName','certain max');
set(plot1(3),'DisplayName','uncertain');

% Create legend
legend1 = legend(axes1,'show');
set(legend1,...
    'Position',[0.731867283950616 0.235964912280701 0.137731481481481 0.191228070175439]);