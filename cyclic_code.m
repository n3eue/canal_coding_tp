% ------------------- Paramètres de simulation pour les codes cycliques -------------------
codes = [
    7, 4, 1;  % Code (7,4,1)
    15, 7, 2; % Code (15,7,2)
    15, 11, 1; % Code (15,11,1)
    15, 5, 3 % Code (15,5,3) avec pouvoir correcteur de 3
];
EbN0_dB = 0:7; % Plage de Eb/N0 en dB
num_bits = 1e5; % Nombre total de bits simulés

% Initialisation des résultats
ber_no_coding = zeros(length(EbN0_dB), size(codes, 1));
ber_with_coding = zeros(length(EbN0_dB), size(codes, 1));
ber_theoretical = zeros(length(EbN0_dB), size(codes, 1));

% ------------------- Simulation pour chaque code -------------------
for code_idx = 1:size(codes, 1)
    % Récupérer les paramètres (n, k, t)
    n = codes(code_idx, 1);
    k = codes(code_idx, 2);
    t = codes(code_idx, 3); % Pouvoir correcteur
    R = k / n; % Taux de codage
    disp(['Simulation pour le code cyclique C(', num2str(n), ',', num2str(k), ') avec t = ', num2str(t)]);

    % Choix du polynôme générateur en fonction du code (n, k)
    if n == 7 && k == 4
        gen_poly = [1 0 1 1]; % Polynôme pour (7, 4)
    elseif n == 15 && k == 11
        gen_poly = [1 0 0 1 1]; % Polynôme pour (15, 11)
    elseif n == 15 && k == 7
        gen_poly = [1 1 1 0 1 0 0 0 1]; % Polynôme pour (15, 7)
    elseif n == 15 && k == 5
        gen_poly = [1 0 1 0 0 1 1 0 1 1 1]; % Polynôme pour (15, 5)
    else
        error('Polynôme générateur non défini pour ce code (n, k).');
    end
    disp(['Polynôme générateur : ', mat2str(gen_poly)]);

    % Initialisation des BER
    ber_no_coding_code = zeros(size(EbN0_dB));
    ber_with_coding_code = zeros(size(EbN0_dB));
    ber_theoretical_code = zeros(size(EbN0_dB));

    % Simulation pour chaque Eb/N0
    for idx = 1:length(EbN0_dB)
        % Convertir Eb/N0 dB en Eb/N0 linéaire
        EbN0 = 10^(EbN0_dB(idx)/10);
        noise_variance = 1 / (2 * R * EbN0); % Variance du bruit

        % Génération des messages aléatoires
        num_blocks = ceil(num_bits / k); % Nombre de blocs de k bits
        msg = randi([0 1], num_blocks, k);

        % Sans codage
        tx_no_coding = 2 * msg(:) - 1; % Modulation BPSK
        noise = sqrt(noise_variance) * randn(size(tx_no_coding)); % Bruit AWGN
        rx_no_coding = tx_no_coding + noise; % Signal reçu
        detected_no_coding = rx_no_coding > 0; % Décision
        ber_no_coding_code(idx) = sum(msg(:) ~= detected_no_coding) / num_bits;

        % Avec codage cyclique
        coded_msg = encode(msg, n, k, 'cyclic', gen_poly); % Codage
        tx_coding = 2 * coded_msg(:) - 1; % Modulation BPSK
        noise_coding = sqrt(noise_variance) * randn(size(tx_coding)); % Bruit AWGN
        rx_coding = tx_coding + noise_coding; % Signal reçu
        detected_coding = rx_coding > 0; % Décision
        detected_coding = reshape(detected_coding, n, [])'; % Reshape en mots codés
        corrected_msg = decode(detected_coding, n, k, 'cyclic', gen_poly); % Décodage
        ber_with_coding_code(idx) = sum(sum(msg ~= corrected_msg)) / num_bits;

        % BER théorique avec codage
        ber_theoretical_code(idx) = 0.5 * erfc(sqrt(R * EbN0));
    end

    % Stocker les résultats pour ce code
    ber_no_coding(:, code_idx) = ber_no_coding_code;
    ber_with_coding(:, code_idx) = ber_with_coding_code;
    ber_theoretical(:, code_idx) = ber_theoretical_code;

    % Tracé des résultats pour ce code
    figure;
    semilogy(EbN0_dB, ber_no_coding(:, code_idx), 'r-o', 'LineWidth', 2); hold on;
    semilogy(EbN0_dB, ber_with_coding(:, code_idx), 'b-s', 'LineWidth', 2);
    semilogy(EbN0_dB, ber_theoretical(:, code_idx), 'k--', 'LineWidth', 2);
    xlabel('E_b/N_0 (dB)');
    ylabel('BER');
    legend('Sans codage', 'Avec codage', 'Théorique avec codage');
    grid on;
    title(['Code C(', num2str(n), ',', num2str(k), ') avec t = ', num2str(t)]);
end

