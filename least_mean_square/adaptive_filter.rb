#! /usr/bin/ruby -w

# Adaptive Filter.
# A linear neuron with feadback
class Adaptive_Filter
    attr_accessor(:xn);     # input x1 ~ xn
    attr_accessor(:wn);     # rations for xn
    attr_accessor(:di);     # desired response
    attr_reader(:e);        # error value

    # Parameters:
    #   n:  input dimensionality.
    #   xn: input x, x1 as 1.0 forever.
    #   di: desired response (target), input from external system.
    # Object variable:
    #   wn: rations for every input.
    #   e:  error between di and calculation
    def initialize(n = 2)
        @n = n;
        @xn = Array.new(@n, 0.0);
        @wn = Array.new(@n, 0.0);
        @di = 0.0;
        @e = 0.0;
    end

    # setup wn value from external
    def set_w(wn)
        @wn = wn;
    end

    # sum calculation for the inputs
    def y()
        val = 0.0;
        @n.times {|i|
            val +=  @wn[i] * @xn[i];
        }
        @e = @di - val;
        return val;
    end

    # signum output
    def signum()
        (y() >= 0) ? 1.0 : -1.0;
    end

    # virtual feedback method.
    # This method must be realized by the sub-class
    def feedback()
        raise("Not defined method for feedback!");
    end

end

__END__
2017.08.30
