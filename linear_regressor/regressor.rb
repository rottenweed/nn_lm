#! /usr/bin/ruby -w

# Linear Regressor Neuron

class Perceptron
    attr_accessor(:xn);     # input x1 ~ xn
    attr_accessor(:wn);     # rations for xn
    attr_accessor(:e);      # random error

    # Parameters:
    # Object variable:
    #   wn: rations for every input
    def initialize(n = 2, delta = 0.5, b = 0.0)
        raise("delta must >0.") if (delta < 0.0);
        @n = n;
        @delta = delta;
        @xn = Array.new(@n, 0.0);
        @wn = Array.new(@n, 0.0);
        @e = e;
        print(@xn, @wn, "\n");
    end

    # calculation for the inputs and offset
    def y()
        val = @e;
        @n.times {|i|
            val +=  @wn[i] * @xn[i];
        }
        return val;
    end

    # output sign function
    def output()
        (y() >= 0) ? 1 : 0;
    end

    # train the neuron
    def train(expect)
    end

    def to_s()
        "dimension: #{@n}, " + @wn.to_s + ", b: #{@e}, delta: #{@delta}";
    end

end
