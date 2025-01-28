% Paramètres de simulation
N = 7; % Longueur des mots codés
R = K / N; % Taux de codage
EbN0_dB = 0:7; % Plage de Eb/N0 en dB
num_bits = 1e4; % Nombre de bits simulés
ber_no_coding = zeros(size(EbN0_dB)); % BER sans codage
ber_with_coding = zeros(size(EbN0_dB)); % BER avec codage
ber_theoretical_coding = zeros(size(EbN0_dB)); % BER théorique avec codage

% Simulation pour chaque Eb/N0
for idx = 1:length(EbN0_dB)
    % Convertir Eb/N0 dB en Eb/N0 linéaire
    EbN0 = 10^(EbN0_dB(idx)/10);
    noise_variance = 1/(2*R*EbN0); % Variance du bruit pour le codage

    % Générer des messages aléatoires
    msg = randi([0 1], num_bits/K, K); % Messages aléatoires (par paquets de K)

    % Sans codage : Modulation BPSK
    tx_no_coding = 2*msg(:) - 1; % Modulation BPSK
    noise = sqrt(noise_variance) * randn(size(tx_no_coding)); % Bruit AWGN
    rx_no_coding = tx_no_coding + noise; % Signal reçu
    detected_no_coding = rx_no_coding > 0; % Décision
    ber_no_coding(idx) = sum(msg(:) ~= detected_no_coding) / num_bits;

    % Avec codage : Encoder, moduler, bruiter, et décoder
    coded_msg = mod(msg * G, 2); % Codage avec la matrice génératrice
    tx_coding = 2*reshape(coded_msg', [], 1) - 1; % Modulation BPSK
    noise_coding = sqrt(noise_variance) * randn(size(tx_coding)); % Bruit AWGN
    rx_coding = tx_coding + noise_coding; % Signal reçu
    detected_coding = rx_coding > 0; % Décision
    detected_coding = reshape(detected_coding, N, [])'; % Reshape en mots codés

    % Décodage en utilisant la table des syndromes
    syndromes = mod(detected_coding * H', 2); % Table des syndromes
    corrected_msg = zeros(size(msg));
    for j = 1:size(syndromes, 1)
        [~, error_idx] = ismember(syndromes(j, :), mod(eye(N) * H', 2), 'rows');
        if error_idx ~= 0
            detected_coding(j, error_idx) = mod(detected_coding(j, error_idx) + 1, 2);
        end
        corrected_msg(j, :) = detected_coding(j, 1:K);
    end

    % Calcul du BER avec codage
    ber_with_coding(idx) = sum(sum(msg ~= corrected_msg)) / num_bits;

    % BER théorique avec codage
    ber_theoretical_coding(idx) = 0.5 * erfc(sqrt(R * EbN0));
end

% Tracé des résultats : BER avec et sans codage
figure;
semilogy(EbN0_dB, ber_no_coding, 'r-o', 'LineWidth', 2); hold on;
semilogy(EbN0_dB, ber_with_coding, 'b-s', 'LineWidth', 2);
xlabel('E_b/N_0 (dB)');
ylabel('BER');
legend('Sans codage', 'Avec codage C(7,4)');
grid on;
title('BER avec et sans codage');

% Tracé des résultats : BER théorique avec codage
figure;
semilogy(EbN0_dB, ber_theoretical_coding, 'k--', 'LineWidth', 2);
xlabel('E_b/N_0 (dB)');
ylabel('BER théorique (avec codage)');
grid on;
title('BER théorique avec codage');

