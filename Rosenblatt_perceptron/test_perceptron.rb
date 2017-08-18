#! /usr/bin/ruby -w

# test Rosenblatt Perceptron
# Process dots in two half-circle area

BEGIN {
    print("Test Rosenblatt Perceptron.\n");
    CSV = File.open("wn.csv", "w");
}

require("../test_sample/two_half_circle.rb");
require("./perceptron.rb");

neuron = Perceptron.new(2, 0.5, 0);
print(neuron.to_s, "\n");

right_cnt = 0;
error_cnt = 0;
10000.times {|i|
    dot = random_dot_pair_half_circle(10.0, 6.0, 1.0);
    neuron.xn = dot[0];
    if(neuron.output == 1)
        right_cnt += 1;
    else
        error_cnt += 1;
    end
    neuron.train(1);
    neuron.xn = dot[1];
    if(neuron.output == 0)
        right_cnt += 1;
    else
        error_cnt += 1;
    end
    neuron.train(0);
    CSV.print("#{neuron.wn[0]},#{neuron.wn[1]},#{neuron.b}\n");
}
    print("End: ", neuron.to_s, "\n");
    print("Right: #{right_cnt}, Error: #{error_cnt}\n");

right_cnt = 0;
error_cnt = 0;
2000.times {|i|
    dot = random_dot_pair_half_circle(10.0, 6.0, 1.0);
    neuron.xn = dot[0];
    if(neuron.output == 1)
        right_cnt += 1;
    else
        error_cnt += 1;
    end
    neuron.xn = dot[1];
    if(neuron.output == 0)
        right_cnt += 1;
    else
        error_cnt += 1;
    end
}
    print("Right: #{right_cnt}, Error: #{error_cnt}\n");


END {
    print("Program end.\n");
    CSV.close;
}
__END__
2017.08.17
