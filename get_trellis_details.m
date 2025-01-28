function [next_states, output_bits] = get_trellis_details(trellis)
    num_states = trellis.numStates;
    num_inputs = trellis.numInputSymbols;
    num_outputs = trellis.numOutputSymbols;

    next_states = zeros(num_states, num_inputs);
    output_bits = zeros(num_states, num_inputs, num_outputs);

    for state = 1:num_states
        for input = 0:(num_inputs - 1)
            next_state = trellis.nextStates(state, input + 1) + 1;
            output = trellis.outputs(state, input + 1);
            next_states(state, input + 1) = next_state;
            output_bits(state, input + 1, :) = de2bi(output, num_outputs, 'left-msb');
        end
    end
end
