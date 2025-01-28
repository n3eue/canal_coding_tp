% Paramètres de simulation
N = 1e4; % Longueur du message aléatoire
EbN0_dB = 0:7; % Plage de Eb/N0 en dB

% Définition du codeur convolutif (nouveau)
constraint_length = 4; % Longueur de contrainte 4
generator_poly = [15 13]; % Polynômes générateurs en octal

% Création du treillis
trellis = poly2trellis(constraint_length, generator_poly);

% Génération du message aléatoire
message = randi([0 1], 1, N);

% Encodage convolutif
coded_message = convenc(message, trellis);

% Initialisation des BER
ber_simulated = zeros(size(EbN0_dB));
ber_theoretical = zeros(size(EbN0_dB));

% Boucle sur les valeurs de SNR
for i = 1:length(EbN0_dB)
    EbN0 = 10^(EbN0_dB(i) / 10); % Convertir Eb/N0 de dB à linéaire
    noise_variance = 1 / (2 * EbN0); % Variance du bruit pour BPSK avec R = 1/2

    % Modulation BPSK
    tx_signal = 2 * coded_message - 1;

    % Ajout de bruit AWGN
    noise = sqrt(noise_variance) * randn(size(tx_signal));
    rx_signal = tx_signal + noise;

    % Démodulation (Décision dure)
    rx_decision = rx_signal > 0;

    % Décodage convolutif avec Viterbi manuel
    decoded_message = vitdec_manual_v2(rx_decision, trellis, N);

    % Calcul du BER
    num_errors = sum(decoded_message ~= message);
    ber_simulated(i) = num_errors / N;

    % Calcul du BER théorique pour BPSK
    ber_theoretical(i) = 0.5 * erfc(sqrt(EbN0));
end

% Tracé des résultats
figure;
semilogy(EbN0_dB, ber_simulated, 'r-o', 'LineWidth', 2); hold on;
semilogy(EbN0_dB, ber_theoretical, 'b--', 'LineWidth', 2);
xlabel('E_b/N_0 (dB)');
ylabel('BER');
legend('Simulation (Codage convolutif)', 'Théorique (BPSK)');
grid on;
title('Performance du code convolutif C(1/2,4)');
