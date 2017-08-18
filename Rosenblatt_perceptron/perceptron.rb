#! /usr/bin/ruby -w

# Rosenblatt Perceptron
# Process dots in two half-circle area

class Perceptron
    attr_accessor(:delta);  # ration for step-to-step delta
    attr_accessor(:xn);     # input x1 ~ xn
    attr_accessor(:wn);     # rations for xn
    attr_accessor(:b);      # offset

    # Parameters:
    #   n: dimension.
    #   delta: ration for step-to-step delta.
    #   b: offset.
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

    # calculation for the inputs and offset
    def y()
        val = @b;
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
        if((expect == 1) && (output == 0))
            @n.times {|i|
                wn[i] += @delta * xn[i];
            }
            @b += @delta;   # as w0, x0
        elsif((expect == 0) && (output == 1))
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
