function code = generateBinaryCode(msg, poly)
    % Longueur du message
    msg_length = length(msg);

    % Longueur du polynôme
    poly_length = length(poly);

    % Ajouter des zéros à la fin du message pour la division polynomiale
    msg_padded = [msg, zeros(1, poly_length - 1)];

    % Effectuer la division polynomiale dans un corps binaire (modulo 2)
    [~, remainder] = deconv(msg_padded, poly);
    remainder = mod(remainder, 2); % Appliquer modulo 2 pour rester dans le corps binaire

    % Le mot de code est le message original suivi du reste de la division
    code = [msg, remainder(end - (poly_length - 2):end)];
end
