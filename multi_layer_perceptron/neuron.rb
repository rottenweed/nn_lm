#! /usr/bin/ruby -w

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

__END__
2017.08.30
