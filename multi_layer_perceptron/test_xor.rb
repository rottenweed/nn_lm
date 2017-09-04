#! /usr/bin/ruby -w

# Two layers of neutrons are used.
# 4 points are used to test XOR: [0, 0], [1, 0], [0, 1], [1, 1].
# Use perceptron in the output layer to judge the polygon.

require("./neuron.rb");

class Perceptron < Neuron
    # paramter for sigmoid function
    ALPHA = 1.0;

    # Heaviside function
    def sign()
        (@v >= 0) ? 1.0 : 0.0;
    end
end

BEGIN {
    print("Test for XOR.\n");
}

# create input layer
perceptron = Array.new();
2.times {|i|
    perceptron << Perceptron.new(3);
}
perceptron[0].set_w([-1.5, 1.0, 1.0]);   # x + y >= 1.5
perceptron[1].set_w([-0.5, 1.0, 1.0]);   # x + y >= 0.5

# create output layer
perceptron_out = Perceptron.new(3);
perceptron_out.xn[0] = 1.0;
perceptron_out.set_w([-0.5, -2.0, 1.0]);

input_logic = [[0, 0], [0, 1], [1, 0], [1, 1]];
input_logic.size.times {|i|
    x = input_logic[i][0];
    y = input_logic[i][1];
    perceptron.size.times {|j|
        perceptron[j].xn = [1.0, x, y];
        perceptron[j].cal();
        # connect input layer to output layer
        perceptron_out.xn[j + 1] = perceptron[j].sign;
    }
    perceptron_out.cal();
    print(input_logic[i], ": ", perceptron_out.sign, "\n");
}

END {
    print("Program end.\n");
}
__END__
2017.09.02
