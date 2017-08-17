#! /usr/bin/ruby -w

# test Rosenblatt Perceptron
# Process dots in two half-circle area

BEGIN {
    print("Test Rosenblatt Perceptron.\n");
}

require("../test_sample/two_half_circle.rb");
require("./perceptron.rb");

neuron = Perceptron.new(3, 0.7, 5);
print(neuron.to_s, "\n");

END {
    print("Program end.\n");
}
__END__
2017.08.17
