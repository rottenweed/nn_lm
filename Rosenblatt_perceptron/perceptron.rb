#! /usr/bin/ruby -w

# Rosenblatt Perceptron

class Perceptron
    attr_accessor(:delta);  # ration for step-to-step delta
    attr_accessor(:xn);     # input x1 ~ xn
    attr_accessor(:wn);     # rations for xn
    attr_accessor(:b);      # bias

    # Parameters:
    #   n: dimension.
    #   delta: ration for step-to-step delta.
    #   b: bias.
    # Object variable:
    #   wn: rations for every input
    def initialize(n = 2, delta = 0.5, b = 0.0)
        raise("delta must >0.") if (delta < 0.0);
        @n = n;
        @delta = delta;
        @xn = Array.new(@n, 0.0);
        @wn = Array.new(@n, 0.0);
        @b = b;
        print(@xn, @wn, "\n");
    end

    # sum calculation for the inputs and bias
    def y()
        val = @b;
        @n.times {|i|
            val +=  @wn[i] * @xn[i];
        }
        return val;
    end

    # activation function: sign function
    def act_f()
        (y() >= 0) ? 1.0 : -1.0;
    end

    # train the neuron
    def train(expect)
        if((expect == 1) && (act_f == -1))
            @n.times {|i|
                wn[i] += @delta * xn[i];
            }
            @b += @delta;   # as w0, x0
        elsif((expect == -1) && (act_f == 1))
            @n.times {|i|
                wn[i] -= @delta * xn[i];
            }
            @b -= @delta;   # as w0, x0
        end
    end

    def to_s()
        "dimension: #{@n}, " + @wn.to_s + ", b: #{@b}, delta: #{@delta}";
    end

end
