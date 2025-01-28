clear all;
clc;

% Création de la matrice de parité P
P = [1 1 0; 0 1 1; 1 0 1; 1 1 1];

% Formation de la matrice génératrice systématique G et la matrice de contrôle de parité H
I = eye(4); % Matrice identité 4x4
G = [I P]; % Matrice génératrice systématique
H = [P' eye(3)]; % Matrice de contrôle de parité

% Création de la table des mots messages et des mots codes
K = 4; % Longueur des mots information
L = 2^K; % Nombre de mots codes

% Generation de tous les mots messages possibles

for i = 1:L
    M(i,:) = deci2bin(i-1, K);
end

% Table des mots codes
code = rem(M*G,2)

% Détermination des erreurs de poids 1 et table des syndromes
error_patterns = eye(7); % Toutes les erreurs de poids 1
syndromes = rem(error_patterns * H', 2); % Table des syndromes

% Affichage des résultats
disp('Matrice génératrice G :');
disp(G);
csvwrite('matrice_G.txt',G);

disp('Matrice de contrôle de parité H :');
disp(H);
csvwrite('matrice_H.txt',H);

disp('Table des mots codes :');
disp(code);
csvwrite('table_des_mots_codes.txt',code);

disp('Table des syndromes :');
disp(syndromes);
csvwrite('table_des_syndromes.txt',syndromes);
