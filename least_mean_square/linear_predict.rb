#! /usr/bin/ruby -w

require './adaptive_filter.rb'

class Predict_Test < Adaptive_Filter
    def feedback()
        print("New feedback of Sub_Filter.\n");
    end
end

print("Test method inherit\n");

neuron = Predict_Test.new(2);
neuron.feedback;

