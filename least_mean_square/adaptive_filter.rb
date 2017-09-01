#! /usr/bin/ruby -w

# Adaptive Filter.
# A linear neuron with feadback
class Adaptive_Filter
    attr_accessor(:xn);     # input x1 ~ xn
    attr_accessor(:di);     # desired response
    attr_reader(:wn);       # rations for xn
    attr_reader(:e);        # error value
    attr_reader(:sign);     # sign of the value

    # Parameters:
    #   n:  input dimensionality.
    #   xn: input x, x1 as 1.0 forever.
    #   di: desired response (target), input from external system.
    # Object variable:
    #   wn: rations for every input.
    #   y:  value of linear calculation
    #   e:  error between di and calculation
    #   sign:   output of sign function
    def initialize(n = 2)
        @n = n;
        @xn = Array.new(@n, 0.0);
        @wn = Array.new(@n, 0.0);
        @di = 0.0;
        @y = 0.0;
        @e = 0.0;
        @sign = 1.0;
    end

    # setup wn value from external
    def set_w(wn)
        @wn = wn;
    end

    # sum calculation for the inputs
    def cal()
        @y = 0.0;
        @n.times {|i|
            @y +=  @wn[i] * @xn[i];
        }
        @e = @di - @y;
        @sign = (@y >= 0) ? 1.0 : -1.0;
        nil;
    end

    # virtual feedback method.
    # This method must be realized by the sub-class
    def feedback()
        raise("Not defined method for feedback!");
    end

end

__END__
2017.08.30
