#! /usr/bin/ruby -w

require './adaptive_filter.rb'

class Predict_Test < Adaptive_Filter
    def feedback()
        print("New feedback of Sub_Filter.\n");
    end
end

BEGIN {
    print("Linear predict of LMS.\n");
}

neuron = Predict_Test.new(2);
neuron.feedback;

END {
    print("Program End.\n");
}
__END__
2017.08.31
