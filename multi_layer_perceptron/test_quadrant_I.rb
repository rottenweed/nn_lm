#! /usr/bin/ruby -w

# Test for 2-layer perceptron.
# To recognize the dots in Quadrant I.
# The count of perceptrons in the first layer can be modified,
#   and 1 perceptron in output layer.

require('./neuron.rb');
class Perceptron < Neuron
    # Const for sigmoid function (tanh is used).
    A = 1.7159;
    B = 2.0 / 3.0;

    # Heaviside function as sign function
    attr_reader(:sign);         # sign value as 0.0 or 1.0
    # use tanh() as sigmoid function
    attr_reader(:sigmoid);      # sigmoid value can be read
    # output grad for back propagation
    attr_reader(:grad);
    def cal()
        super();
        @sign = (@v >= 0) ? 1.0 : -1.0;
        @sigmoid = A * Math.tanh(B * @v);
    end

    # Feedback function.
    # delta = eta * grad
    def feedback(eta, delta)
        @grad = delta * (B / A) * (A - @sigmoid) * (A + @sigmoid);
        eta_grad = eta * @grad;
        @wn.each_index {|i|
            @wn[i] += eta_grad * @xn[i];
        }
    end
end

BEGIN {
    print("Recognize the dots in Quadrant (x > 0, y > 0)\n");
    CSV1 = File.open("quadrant_w.csv", "w");
    CSV2 = File.open("quadrant_o.csv", "w");
}

# fix value test
=begin
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
=end

# count of Layer_In perceptrons
Layer_In_Count = 2;
# learning parameter
Eta1 = 0.01;
Eta2 = 0.0001;

# initial wn value
layer_in_wn = [[0.0, 0.0, 0.0],
               [0.0, 0.0, 0.0]];
# input layer: includes some perceptrons
layer_in = Array.new();
Layer_In_Count.times {|i|
    layer_in << Perceptron.new(3);
    layer_in[i].set_w(layer_in_wn[i]);
}
# output layer: 1 perceptron
layer_out = Perceptron.new(Layer_In_Count + 1);
layer_out_init_wn = [0.0];
Layer_In_Count.times {|i|
    layer_out_init_wn << rand() - 0.5;
}
layer_out.set_w(layer_out_init_wn);
print(layer_out_init_wn, "\n");

# Back Propagation Iteration
20000.times {|i|
    x = 2.0 * (rand() - 0.5);
    y = 2.0 * (rand() - 0.5);
    xn = [1.0, x, y];
    yn = [1.0];
    # Forword Calculation
    layer_in.each_index {|j|
        layer_in[j].xn = xn;
        layer_in[j].cal();
        yn[j + 1] = layer_in[j].sigmoid;
    }
    layer_out.xn = yn;
    layer_out.cal();
    # Back Propagration
    real_judge = ((x >=0) && (y >= 0)) ? 1.0 : -1.0;
    eta = (i > 10000) ? Eta2 : Eta1;
    layer_out.feedback(eta, (real_judge - layer_out.sigmoid));
    layer_in.each_index {|j|
        layer_in[j].feedback(eta, layer_out.grad * layer_out.wn[j]);
    }
    # Output the parameter
    CSV1.printf("%f,%f,%f,%f,%f,%f,%f,%f,%f\n",
               layer_in[0].wn[0], layer_in[0].wn[1], layer_in[0].wn[2],
               layer_in[1].wn[0], layer_in[1].wn[1], layer_in[1].wn[2],
               layer_out.wn[0], layer_out.wn[1], layer_out.wn[2]);
}

# ideal wm value
=begin
layer_in[0].set_w([0.0, 100.0, 0.0]);
layer_in[1].set_w([0.0, 0.0, 100.0]);
layer_out.set_w([-1.5, 1.0, 1.0]);
=end

# check the recognition
# show the parameters
layer_in.each {|neuron|
    print(neuron.wn, "\n");
}
print(layer_out.wn, "\n");

right_cnt = 0;
error_cnt = 0;
1000.times {|i|
    x = 2.0 * (rand() - 0.5);
    y = 2.0 * (rand() - 0.5);
    xn = [1.0, x, y];
    yn = [1.0];
    layer_in.each_index {|j|
        layer_in[j].xn = xn;
        layer_in[j].cal();
        yn[j + 1] = layer_in[j].sigmoid;
    }
    layer_out.xn = yn;
    layer_out.cal();
    real_judge = ((x >=0) && (y >= 0)) ? 1.0 : -1.0;
    if(real_judge == layer_out.sign)
        right_cnt += 1;
    else
        error_cnt += 1;
        CSV2.printf("%f,%f\n", x, y);
    end
}
print("Right cnt = ", right_cnt, "\n");
print("Error cnt = ", error_cnt, "\n");

END {
    print("Program end.\n");
    CSV1.close();
    CSV2.close();
}
__END__
2017.09.04
