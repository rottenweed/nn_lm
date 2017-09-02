#! /usr/bin/ruby -w

# Two layers of neutrons are used.
# Use every perceptrons in the input layer to decide a line.
# Use perceptron in the output layer to judge the polygon.

require("./neuron.rb");

class Perceptron < Neuron
    # paramter for sigmoid function
    ALPHA = 1.0;

    # Heaviside function
    def sign()
        (@v >= 0) ? 1.0 : 0.0;
    end

    # Use logistic() function
    def sigmoid()
        1 / (1 + Math.exp(-@v * ALPHA));
    end
end

BEGIN {
    print("Test for polygon decided by perceptron.\n");
}

# create input layer
perceptron = Array.new();
4.times {|i|
    perceptron << Perceptron.new(3);
}
perceptron[0].set_w([1.0, 0.0, 1.0]);   # y >= -1 
perceptron[1].set_w([1.0, 1.0, 0.0]);   # x >= -1
perceptron[2].set_w([1.0, 0.0, -1.0]);  # y <= 1
perceptron[3].set_w([1.0, -1.0, 0.0]);  # x <= 1

# create output layer
perceptron_out = Perceptron.new(5);
perceptron_out.xn[0] = 1.0;
perceptron_out.set_w([-3.5, 1.0, 1.0, 1.0, 1.0]);

right_cnt, error_cnt = 0, 0;
1000.times {|i|
    x = 2 * (rand() - 0.5) * 10;
    y = 2 * (rand() - 0.5) * 10;
    perceptron.size.times {|j|
        perceptron[j].xn = [1.0, x, y];
        perceptron[j].cal();
        # connect input layer to output layer
        perceptron_out.xn[j + 1] = perceptron[j].sign;
    }
    perceptron_out.cal();
    if(((x.abs <= 1) && (y.abs <= 1)) && (perceptron_out.sign == 1))
        right_cnt += 1;
    elsif(((x.abs > 1) || (y.abs > 1)) && (perceptron_out.sign == 0))
        right_cnt += 1;
    else
        error_cnt += 1;
        printf("[x, y] = [%f, %f]\n", x, y);
        print(perceptron_out.sign, "\n");
    end
}
print("Right cnt = ", right_cnt, "\n");
print("Error cnt = ", error_cnt, "\n");

END {
    print("Program end.\n");
}
__END__
2017.09.02
