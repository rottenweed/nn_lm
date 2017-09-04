#! /usr/bin/ruby -w

# Test for 2-layer perceptron.
# To recognize the dots in Quadrant I.
# 2 perceptrons in the first layer,
#   and 1 perceptron in output layer.

require('./neuron.rb');
class Perceptron < Neuron
    # Heaviside function
    def sign()
        (@v >= 0) ? 1.0 : 0.0;
    end

    # Const for sigmoid function (tanh is used.)
    A = 1.7159;
    B = 2.0 / 3.0;
    # use tanh() as sigmoid function
    def sigmoid()
        A * Math.tanh(B * @v);
    end
end

BEGIN {
    print("Recognize the dots in Quadrant (x > 0, y > 0)\n");
}

# input layer: includes 2 perceptrons
layer_in = [Perceptron.new(3), Perceptron.new(3)];
layer_in[0].set_w([0.0, 1.0, 0.0]);
layer_in[1].set_w([0.0, 0.0, 1.0]);
# output layer: 1 perceptron
layer_out = Perceptron.new(3);
layer_out.set_w([-1.5, 1.0, 1.0]);

# check the recognition
10.times {|i|
    x = 2.0 * (rand() - 0.5);
    y = 2.0 * (rand() - 0.5);
    xn = [1.0, x, y];
    yn = [1.0];
    layer_in.each_index {|j|
        layer_in[j].xn = xn;
        layer_in[j].cal();
        yn[j + 1] = layer_in[j].sign;
    }
    layer_out.xn = yn;
    layer_out.cal();
    print(i, ": ", xn, " ", layer_out.sign, "\n");
}

END {
    print("Program end.\n");
}
__END__
2017.09.04
