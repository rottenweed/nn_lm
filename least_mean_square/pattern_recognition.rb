#! /usr/bin/ruby -w
# Recognize dots in two half-circle band.

require './adaptive_filter.rb'

# Sub-class definition
class LMS_pattern_recognition < Adaptive_Filter
    # feedback to wn parameters.
    # eta: stepsize / learning-rate parameter
    def feedback(eta)
        # add the next line, the neuron becomes Rosenblatt-perceptron
        # @e = @di - @sign;
        @n.times {|i|
            @wn[i] += eta * @e * @xn[i];
        }
    end
end

BEGIN {
    print("Pattern recognition with LMS neuron.\n");
}

require("../test_sample/two_half_circle.rb");

# circle parameter
CIRCLE_R = 10.0;
CIRCLE_WIDTH = 6.0;
CIRCLE_DIS = 1.0;
# learning parameter
ETA = 0.001;

neuron = LMS_pattern_recognition.new(3);
2000.times {|i|
    dot = random_dot_pair_half_circle(CIRCLE_R, CIRCLE_WIDTH, CIRCLE_DIS);
    # [1, x, y, y_sign] of dot value
    dot0 = [1.0, dot[0][0], dot[0][1], 1.0];    # positive
    dot1 = [1.0, dot[1][0], dot[1][1], -1.0];   # negative
    # positive dot
    neuron.xn = dot0[0..2];
    neuron.di = dot0[3];
    neuron.cal();
    neuron.feedback(ETA);
    # negative dot
    neuron.xn = dot1[0..2];
    neuron.di = dot1[3];
    neuron.cal();
    neuron.feedback(ETA);
}
print("wn = ", neuron.wn, "\n");

# statistics of the pattern recognition
right_cnt = 0;
error_cnt = 0;
5000.times {|i|
    dot = random_dot_pair_half_circle(CIRCLE_R, CIRCLE_WIDTH, CIRCLE_DIS);
    # [1, x, y, y_sign] of dot value
    dot0 = [1.0, dot[0][0], dot[0][1], 1.0];    # positive
    dot1 = [1.0, dot[1][0], dot[1][1], -1.0];   # negative
    neuron.xn = dot0[0..2];
    neuron.cal();
    if(neuron.sign == dot0[3])
        right_cnt += 1;
    else
        error_cnt += 1;
    end
    neuron.xn = dot1[0..2];
    neuron.cal();
    if(neuron.sign == dot1[3])
        right_cnt += 1;
    else
        error_cnt += 1;
    end
}
    print("Right: #{right_cnt}, Error: #{error_cnt}\n");
    error_cnt *= 1.0;   # tranfer to Float
    print("Error proportion = ");
    print(error_cnt * 100 / (right_cnt + error_cnt), "\%\n");

END {
    print("Program end.\n");
}

__END__
2017.09.01
