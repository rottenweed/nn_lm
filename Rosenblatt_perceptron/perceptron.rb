#! /usr/bin/ruby -w

# Rosenblatt Perceptron
# Process dots in two half-circle area

class Perceptron
    attr_accessor(:delta);  # ration in step-to-step delta
    attr_accessor(:xn);     # input x1 ~ xn

    def initialize(n = 2, delta = 0.5, b = 0)
        @n = n;
        @delta = delta;
        @wn = Array.new(@n, 0);
        @b = b;
    end

    def value()
        @n.times {|i|
            val += @xn[i] * @wn[i];
        }
        val += @b;
    end

    def to_s()
        "dimension: #{@n}, " + @wn.to_s + ", b: #{@b}, delta: #{@delta}";
    end

end
