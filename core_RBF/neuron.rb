#! /usr/bin/ruby -w

# Module for neuron library
module Neuron

# A neuron with virtual feadback.
# v: linear output
class Neuron
    attr_accessor(:xn);     # input x1 ~ xn
    attr_reader(:wn);       # rations for xn
    attr_reader(:v);        # linear calcualation value

    # Parameters:
    #   n:  input dimensionality.
    #   xn: input x, x1 as 1.0 forever.
    # Object variable:
    #   wn: rations for every input.
    #   v:  value of linear calculation
    def initialize(n = 2)
        @n = n;
        @xn = Array.new(@n, 0.0);
        @wn = Array.new(@n, 0.0);
        @v = 0.0;
    end

    # setup wn value by external
    def set_w(wn)
        @wn = wn;
    end

    # linear sum calculation for the inputs
    def cal()
        @v = 0.0;
        @n.times {|i|
            @v +=  @wn[i] * @xn[i];
        }
        nil;
    end

end

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

end

__END__
2017.09.13
