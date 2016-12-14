% Ce script Matlab automatise la production de resultats
% lorsqu'on doit faire une serie de simulations en
% variant un des parametres d'entree.
% 
% Il utilise les arguments du programme (voir ConfigFile.h)
% pour remplacer la valeur d'un parametre du fichier d'input
% par la valeur scannee.
%

%% Parametres %%
%%%%%%%%%%%%%%%%

repertoire = ''; % Chemin d'acces au code compile
executable = 'Exercice4.exe'; % Nom de l'executable
input = 'configuration.in'; % Nom du fichier d'entree

nsimul = 20; % Nombre de simulations a faire

dt = logspace(5,6,nsimul); % crea vettore con nsimul componenti spaziati egualmente tra 10^5 e 10^6

paramstr = 'dt'; % Nom du parametre a scanner, par exemple dt, w, x0, etc
param = dt; % Valeurs du parametre a scanner

%% Simulations %%
%%%%%%%%%%%%%%%%%

output = cell(1, nsimul);

for i = 1:nsimul
    filename = [paramstr, '=', num2str(param(i))];
    output{i} = [filename, '.out'];
    eval(sprintf('!%s%s %s %s=%.15g output=%s', repertoire, executable, input, paramstr, param(i), output{i}));
    disp('Done.')
end

%% Analyse %%
%%%%%%%%%%%%%

% Parcours des resultats de toutes les simulations

if(strcmp(paramstr,'dt'))
    dE = zeros(1,nsimul); % Non-conservation de l'energie
end

% Boucle pour la position finale
for i = 1:nsimul
    data = load(output{i});
    if(strcmp(paramstr,'dt'))
        xFin = data(:,2);
        yFin = data(:,3);
        convX(i) = abs(xFin(end) - 4544199898.95299);
        convY(i) = abs(yFin(end) + 167383.023676207);
    end
end

% Boucle pour l'energie
Etheo=2.965654481e10;
for i = 1:nsimul
    data = load(output{i});
    if(strcmp(paramstr,'dt'))
        a=data(:,14);
        en(i)=abs(Etheo-a(end));
    end
end

%% Plot convergence position x et y %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a = 5.768e-17;
b = 4.129;
for i = 1:nsimul
    f(i) = a*dt(i)^b;
end

if(strcmp(paramstr,'dt'))
    figure
    loglog(dt,convX,'kx',dt,convY,'ko',dt,f,'r')
    grid on
    xlabel('\Deltat')
    ylabel('Erreur absolue pour la position en x')
end

% if(strcmp(paramstr,'dt'))
%     figure
%     loglog(dt,convY,'ko')
%     grid on
%     xlabel('\Deltat')
%     ylabel('Erreur absolue pour la position en y')
% end

%% Plot convergence énergie %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a = 5.768e-17;
b = 4.129;
for i = 1:nsimul
    f(i) = a*dt(i)^b;
end

if(strcmp(paramstr,'dt'))
    figure
    loglog(dt,en,'x', dt, f, 'r')
    grid on
    xlabel('\Deltat [s]')
    ylabel('Energie [J]')
end