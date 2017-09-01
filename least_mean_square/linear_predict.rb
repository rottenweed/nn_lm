#! /usr/bin/ruby -w

require './adaptive_filter.rb'

class Predict_Test < Adaptive_Filter
    # feedback to wn parameters.
    # eta: stepsize / learning-rate parameter
    def feedback(eta)
        @n.times {|i|
            @wn[i] += eta * @e * @xn[i];
        }
    end
end

BEGIN {
    print("Linear predict of LMS.\n");
    CSV = File.open("wn_e.csv", "w");
}

Neuron_Cnt = 100;
Iterate_Cnt = 5000;
array_neuron = Array.new(Neuron_Cnt, Predict_Test.new(1));
avg_wn = 0.0;
avg_e = 0.0;
ETA = 0.001;
A = 0.99;
Iterate_Cnt.times {|i|
    Neuron_Cnt.times {|j|
        # use rand() to replace Gausian distribution
        e = 2.0 * (rand() - 0.5) * 0.02;
        x = 2.0 * (rand() - 0.5) * 0.995;
        y = A * x + e;
        # setup neuron input and target
        array_neuron[j].xn = [x];
        array_neuron[j].di = y;
        array_neuron[j].cal();
        array_neuron[j].feedback(ETA);
    }
    val_sum = array_neuron.inject(0.0) {|sum, neuron|
        sum += neuron.wn[0];
    }
    avg_wn = val_sum / Neuron_Cnt;
    val_sum = array_neuron.inject(0.0) {|sum, neuron|
        sum += neuron.e;
    }
    avg_e = val_sum / Neuron_Cnt;
    CSV.printf("%f, %f\n", avg_wn, avg_e * avg_e);
}
printf("wn = %f, e = %f\n", avg_wn, avg_e);

END {
    print("Program End.\n");
    CSV.close;
}
__END__
2017.08.31
