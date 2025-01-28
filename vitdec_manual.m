function decoded_bits = vitdec_manual(received, trellis, num_bits)
    num_states = trellis.numStates; % Nombre d'états dans le treillis
    num_output_bits = log2(trellis.numOutputSymbols); % Nombre de bits de sortie par transition

    % Initialisation des métriques de chemin
    path_metrics = inf(num_states, num_bits + 1);
    path_metrics(1, 1) = 0; % État initial à coût 0

    % Initialisation des chemins survivants
    survivor_paths = zeros(num_states, num_bits);

    % Algorithme de Viterbi
    for bit_idx = 1:num_bits
        for current_state = 1:num_states
            for input_bit = 0:1
                % Trouver l'état suivant et la sortie
                next_state = trellis.nextStates(current_state, input_bit + 1) + 1;
                output = de2bi(trellis.outputs(current_state, input_bit + 1), num_output_bits, 'left-msb');

                % Coût de transition (Hamming distance)
                received_bits = received((bit_idx - 1) * num_output_bits + (1:num_output_bits));
                hamming_dist = sum(received_bits ~= output);

                % Mettre à jour la métrique de chemin
                new_metric = path_metrics(current_state, bit_idx) + hamming_dist;
                if new_metric < path_metrics(next_state, bit_idx + 1)
                    path_metrics(next_state, bit_idx + 1) = new_metric;
                    survivor_paths(next_state, bit_idx) = current_state;
                end
            end
        end
    end

    % Backtracking pour reconstruire le chemin
    decoded_bits = zeros(1, num_bits);
    [~, current_state] = min(path_metrics(:, end));
    for bit_idx = num_bits:-1:1
        prev_state = survivor_paths(current_state, bit_idx);
        decoded_bits(bit_idx) = find(trellis.nextStates(prev_state, :) == current_state - 1) - 1;
        current_state = prev_state;
    end
end
