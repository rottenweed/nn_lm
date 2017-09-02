#! /usr/bin/ruby -w

# A neuron with virtual feadback.
# v: linear output
class Neuron
    attr_accessor(:xn);     # input x1 ~ xn
    attr_accessor(:di);     # desired response
    attr_reader(:wn);       # rations for xn
    attr_reader(:v);        # linear calcualation value

    # Parameters:
    #   n:  input dimensionality.
    #   xn: input x, x1 as 1.0 forever.
    #   di: desired response (target), input from external system.
    # Object variable:
    #   wn: rations for every input.
    #   v:  value of linear calculation
    def initialize(n = 2)
        @n = n;
        @xn = Array.new(@n, 0.0);
        @wn = Array.new(@n, 0.0);
        @di = 0.0;
        @v = 0.0;
    end

    # setup wn value by external
    def set_w(wn)
        @wn = wn;
    end

    # sum calculation for the inputs
    def cal()
        @v = 0.0;
        @n.times {|i|
            @v +=  @wn[i] * @xn[i];
        }
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
