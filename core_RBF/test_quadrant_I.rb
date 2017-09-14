#! /usr/bin/ruby -w

# test for quadrant I after coordinary exchangement

BEGIN {
    print("Test for quadrant after coordinate exchangement.\n");

    # pattern division output
    def expect_val(x, y)
        ((x >= 0) && (y >= 0)) ? 1.0 : -1.0;
    end

    require('./neuron.rb');
}


# the function is similiar to logical AND
and_check = Neuron::Perceptron.new(3);
print(and_check.class, "\n");
CSV = File.open("quadrant.csv", "w");

# learning parameter
Eta1 = 0.01;
Eta2 = 0.001;
Eta3 = 0.0001;
# Back Propagation Iteration
Stage_Cnt = 10;
Stage_Size = 100;
# adjust the learning parameter dynamically
error_cnt = Stage_Size;
# Back Propagation Iteration
Stage_Cnt.times {|stage|
    eta = (error_cnt < Stage_Size / 100) ? Eta3 :
        (error_cnt < Stage_Size / 10) ? Eta2 : Eta1;
    error_cnt = 0;
    sum_error = 0.0;
    Stage_Size.times {|i|
        x = 2.0 * (rand() - 0.5);
        y = 2.0 * (rand() - 0.5);
        xn = [1.0, 0, 0];
        # coordinate un_linear exchange
        xn[1] = (x >= 0.0) ? 1.0 : -1.0;
        xn[2] = (y >= 0.0) ? 1.0 : -1.0;
        and_check.xn = xn;
        and_check.cal();
        if(expect_val(x, y) != and_check.sign)
            error_cnt += 1;
        end
        cur_error = expect_val(xn[1], xn[2]) - and_check.sign;
        sum_error += cur_error * cur_error; 
        and_check.feedback(eta, cur_error);
        CSV.print("#{and_check.wn[0]},#{and_check.wn[1]},#{and_check.wn[2]}\n");
    }
    print("Error cnt = ", error_cnt, "\n");
}

CSV.close;

END {
    print("Program end.\n");
}
__END__
2017.09.13
