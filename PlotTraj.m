function PlotTraj(out)

output = load(out);
t = output(:,1);
x1 = output(:,2);
y1 = output(:,3);
x2 = output(:,4);
y2 = output(:,5);
x3 = output(:,6);
y3 = output(:,7);
vx1 = output(:,8);
vy1 = output(:,9);
vx2 = output(:,10);
vy2 = output(:,11);
vx3 = output(:,12);
vy3 = output(:,13);

clear output

figure
plot(x1, y1, 'b', x2, y2, 'r')
xlabel('x [m]')
ylabel('y [m]')

end