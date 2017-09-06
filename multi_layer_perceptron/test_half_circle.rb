#! /usr/bin/ruby -w

# Test for 2-layer perceptron.
# To divide the dots in two half circle band.
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
    print("Pattern recognition of the dots in two half circle.\n");
    CSV1 = File.open("circle_w.csv", "w");
    CSV2 = File.open("circle_o.csv", "w");
}

# count of Layer_In perceptrons
Layer_In_Count = 20;

# initial wn value
# input layer: includes some perceptrons
layer_in = Array.new();
Layer_In_Count.times {|i|
    layer_in << Perceptron.new(3);
    layer_in[i].set_w([0.0, rand() - 0.5, rand() - 0.5]);
}
# output layer: 1 perceptron
layer_out = Perceptron.new(Layer_In_Count + 1);
layer_out_init_wn = [0.0];
Layer_In_Count.times {|i|
    layer_out_init_wn << rand() - 0.5;
}
layer_out.set_w(layer_out_init_wn);

require("../test_sample/two_half_circle.rb");

# circle parameter
CIRCLE_R = 10.0;
CIRCLE_WIDTH = 6.0;
CIRCLE_DIS = -6.5;

# learning parameter
Eta1 = 0.01;
Eta2 = 0.001;
Eta3 = 0.0001;
# Back Propagation Iteration
Stage_Cnt = 200;
Stage_Size = 1000;
# adjust the learning parameter dynamically
error_cnt = Stage_Size;
Stage_Cnt.times {|stage|
    eta = (error_cnt < Stage_Size / 100) ? Eta3 :
        (error_cnt < Stage_Size / 10) ? Eta2 : Eta1;
    error_cnt = 0;
    Stage_Size.times {|i|
        dot = random_dot_pair_half_circle(CIRCLE_R, CIRCLE_WIDTH, CIRCLE_DIS);
        2.times {|k|
            # [1, x, y, y_sign] of dot value
            xn = [1.0, dot[k][0], dot[k][1]];      # select a point
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
            real_judge = (k == 0) ? 1.0 : -1.0;
            # only train for the error samples
            if(real_judge != layer_out.sign)
                layer_out.feedback(eta, (real_judge - layer_out.sigmoid));
                layer_in.each_index {|j|
                    layer_in[j].feedback(eta, layer_out.grad * layer_out.wn[j]);
                }
                error_cnt += 1;
            end
        }
    }
    # Output the parameter
    CSV1.printf("%f,%d,%f\n", eta, error_cnt, layer_out.wn[0]);
    break if(error_cnt == 0);
}

# show the parameters
#layer_in.each {|neuron|
#    print(neuron.wn, "\n");
#}
print(layer_out.wn, "\n");

right_cnt = 0;
error_cnt = 0;
1000.times {|i|
    dot = random_dot_pair_half_circle(CIRCLE_R, CIRCLE_WIDTH, CIRCLE_DIS);
    2.times {|k|
        # [1, x, y, y_sign] of dot value
        xn = [1.0, dot[k][0], dot[k][1]];      # select a point
        yn = [1.0];
        layer_in.each_index {|j|
            layer_in[j].xn = xn;
            layer_in[j].cal();
            yn[j + 1] = layer_in[j].sigmoid;
        }
        layer_out.xn = yn;
        layer_out.cal();
        real_judge = (k == 0) ? 1.0 : -1.0;
        if(real_judge == layer_out.sign)
            right_cnt += 1;
        else
            error_cnt += 1;
            CSV2.printf("%f,%f\n", xn[1], xn[2]);
        end
    }
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
