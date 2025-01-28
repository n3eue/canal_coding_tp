% Paramètres de simulation
N = 1e5; % Nombre total de bits
EbN0_dB = 0:10; % Plage de Eb/N0 en dB

% Définition des codes cycliques (n, k, t)
codes_cycliques = [
    7, 4, 1;
    15, 11, 1;
    15, 7, 2;
    15, 5, 3
];

% Simulation sans codage pour référence
ber_uncoded = zeros(size(EbN0_dB));

for i = 1:length(EbN0_dB)
    EbN0 = 10^(EbN0_dB(i) / 10);
    noise_variance = 1 / (2 * EbN0);

    % Génération du signal
    msg = randi([0 1], 1, N);
    tx_signal = 2 * msg - 1; % BPSK

    % Ajout du bruit AWGN
    noise = sqrt(noise_variance) * randn(size(tx_signal));
    rx_signal = tx_signal + noise;

    % Décision et calcul du BER
    rx_decision = rx_signal > 0;
    ber_uncoded(i) = sum(rx_decision ~= msg) / N;
end

% Boucle sur chaque code cyclique
for idx = 1:size(codes_cycliques, 1)
    n = codes_cycliques(idx, 1);
    k = codes_cycliques(idx, 2);
    t = codes_cycliques(idx, 3);

    % Détermination du polynôme générateur
    g_poly = cyclpoly(n, k);

    % Initialisation du BER codé
    ber_coded = zeros(size(EbN0_dB));

    for i = 1:length(EbN0_dB)
        EbN0 = 10^(EbN0_dB(i) / 10);
        noise_variance = 1 / (2 * EbN0);

        % Génération du message (Doit être une matrice avec K colonnes)
        num_blocks = floor(N / k);  % Nombre de blocs de k bits
        msg = randi([0 1], num_blocks, k);  % Génère une matrice de (num_blocks x k)

        % Codage cyclique
        codeword = encode(msg, n, k, 'cyclic', g_poly);

        % Modulation BPSK
        tx_signal = 2 * codeword(:) - 1;  % Convertir en vecteur colonne

        % Ajout du bruit AWGN
        noise = sqrt(noise_variance) * randn(size(tx_signal));
        rx_signal = tx_signal + noise;

        % Démodulation
        rx_decision = rx_signal > 0;
        rx_decision = reshape(rx_decision, num_blocks, n);  % Reformater en blocs de n bits

        % Décodage du code cyclique
        decoded_msg = decode(rx_decision, n, k, 'cyclic', g_poly);

        % Calcul du BER
        num_errors = sum(decoded_msg(:) ~= msg(:));
        ber_coded(i) = num_errors / numel(msg);
    end

    % Affichage des résultats
    figure;
    semilogy(EbN0_dB, ber_uncoded, 'r--', 'LineWidth', 2); hold on;
    semilogy(EbN0_dB, ber_coded, 'b-o', 'LineWidth', 2);
    xlabel('E_b/N_0 (dB)');
    ylabel('BER');
    legend('Sans codage', sprintf('Code (%d,%d) t=%d', n, k, t));
    grid on;
    title(sprintf('Performance du Code Cyclique (%d,%d) t=%d', n, k, t));
end

