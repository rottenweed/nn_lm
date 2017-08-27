#! /usr/bin/ruby -w

# Linear Regressor Neuron

# Use Matrix lib
require "matrix"
# add method []= to class Matrix.
# modify an assigned element.
class Matrix
    def []=(i, j, x)
        @rows[i][j] = x;
    end
end

# add method []= to class Vector.
# modify an assigned element.
class Vector
    def []=(i, x)
        @elements[i] = x;
    end
end

class Neuron
    attr_accessor(:xn);     # input x1 ~ xn
    attr_accessor(:wn);     # rations for xn

    # Parameters:
    #   n: count of input.
    #   xn: input x.
    # Object variable:
    #   wn: rations for every input, w0 as bias.
    def initialize(n = 2)
        @n = n;
        @xn = Array.new(@n, 0.0);
        @wn = Array.new(@n, 0.0);
    end

    # setup wn value from external
    def set_w(wn)
        @wn = wn;
    end

    # sum calculation for the inputs and bias
    def y()
        val = 0.0;
        @n.times {|i|
            val +=  @wn[i] * @xn[i];
        }
        return val;
    end

    # activation function: signum function
    def act_f()
        (y() >= 0) ? 1.0 : -1.0;
    end

    def to_s()
        "dimension: #{@n}, " + @wn.to_s;
    end

end

BEGIN {
    print("regularized least-squares(RLS) solution\n");
}

require("../test_sample/two_half_circle.rb");

neuron = Neuron.new(3);
matrix_ration = Matrix[[0.0, 0.0, 0.0],   # x[n] matrix
                       [0.0, 0.0, 0.0],
                       [0.0, 0.0, 0.0]];
vector_output = Vector[0.0, 0.0, 0.0];

1000.times {|i|
    dot = random_dot_pair_half_circle(10.0, 6.0, 1.0);
    # [1, x, y, y_sign] of dot value
    dot0 = [1.0, dot[0][0], dot[0][1]];     # positive
    dot1 = [1.0, dot[1][0], dot[1][1]];     # negative
    # mul & add the value of new dot to matrix_ration
    3.times {|j|
        3.times {|k|
            matrix_ration[j, k] += dot0[j] * dot0[k];
            matrix_ration[j, k] += dot1[j] * dot1[k];
        }
        vector_output[j] += dot0[j] * 1.0;
        vector_output[j] += dot1[j] * -1.0;
    }
}

vector_w = matrix_ration.inv * vector_output;
print("vector_w = ", vector_w, "\n");

END {
    print("Program end.\n");
}

__END__
2017.8.28
