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

x_comete = 4544199999.67859;
y_comete = 9439.99999977744;

x_soleil = 1.61599990888563e-022;
y_soleil = 1.1190117175243e-028;

figure
plot(x1, y1, 'b', x_comete, y_comete, 'o', x2, y2, 'r', x_soleil, y_soleil, 'o')
axis equal
xlabel('x [m]')
ylabel('y [m]')

end