#! /usr/bin/ruby -w
# Train in two steps:
# 1. Use K-mean iteration-down to divide samples into sets.
# 2. Use core-base functions as middle layer.
# 3. Use SVM algorithm.

require 'matrix'

# core function by Gauss
def phi_ij(omicron, core, point)
    dis2 = (core[0] - point[0]) ** 2 + (core[1] - point[1]) ** 2;
    Math.exp(dis2 / (-2 * omicron ** 2));
end

puts("K-mean + SVM for two half-circle.");

# config samples generator
require("../test_sample/two_half_circle.rb");
# circle parameter
CIRCLE_R = 10.0;
CIRCLE_WIDTH = 6.0;
CIRCLE_DIS = -6.0;

puts("Start to train the neuron network...");
# Train step I: K-mean iteration down.
# numbers of the point sets
SetCnt = 20;
# iteration times in K-mean
OptCnt = 100;
# iteration limit
Limit_avg_delta = 0.001;
# point count
PointTrainCnt = 1000;
CSV1 = File.open("set_avg.csv", "w");
CSV2 = File.open("set_avg_delta.csv", "w");
CSV3 = File.open("wn.csv", "w");
CSV4 = File.open("err_dot.csv", "w");

# initiate the samples for train process.
# divide the samples to sets randomly.
train_samples = [];
(PointTrainCnt / 2).times {|i|
    dot = random_dot_pair_half_circle(CIRCLE_R, CIRCLE_WIDTH, CIRCLE_DIS);
    # sample point is saved as [x, y, set_No]
    train_samples << [dot[0][0], dot[0][1], i % SetCnt];
    train_samples << [dot[1][0], dot[1][1], i % SetCnt];
}

# Sets optimize cycle
set_sum = [];
set_avg = [];
set_avg_delta = [];
square_sum_of_avg_delta = SetCnt * Limit_avg_delta + 1;
opt_times = 0;
# initiate the sets at first
SetCnt.times {|i|
    set_sum << [0.0, 0.0, 0]; # [sum_x, sum_y, count]
    set_avg << [0.0, 0.0];
    set_avg_delta << [0.0, 0.0];
}
# stop when the sets is stable
while((square_sum_of_avg_delta / SetCnt > Limit_avg_delta) && (opt_times < OptCnt))
    # calculation the average vector of the set (for Min||x-avg||)
    # clear the sum and count
    SetCnt.times {|i|
        set_sum[i] = [0.0, 0.0, 0]; # [sum_x, sum_y, count]
    }
    # add the sample to the corresponding set
    train_samples.each {|sample|
        set_sum[sample[2]][0] += sample[0];
        set_sum[sample[2]][1] += sample[1];
        set_sum[sample[2]][2] += 1;
    }
    # calc the avg as the set core
    SetCnt.times {|i|
        if(set_sum[i][2] != 0)
            temp = set_sum[i][0] / set_sum[i][2];
            set_avg_delta[i][0] = temp - set_avg[i][0];
            set_avg[i][0] = temp;
            temp = set_sum[i][1] / set_sum[i][2];
            set_avg_delta[i][1] = temp - set_avg[i][1];
            set_avg[i][1] = temp;
        else
            set_avg_delta[i] = [0.0, 0.0];
        end
        # record core (x, y) and set size
        CSV1.print("#{set_avg[i][0]},#{set_avg[i][1]},#{set_sum[i][2]},");
        CSV2.print("#{set_avg_delta[i][0]},#{set_avg_delta[i][1]},");
    }
    CSV1.print("\n");
    square_sum_of_avg_delta = 0.0;
    SetCnt.times {|i|
        square_sum_of_avg_delta += set_avg_delta[i][0] ** 2;
        square_sum_of_avg_delta += set_avg_delta[i][1] ** 2;
    }
    CSV2.print(square_sum_of_avg_delta / SetCnt, "\n");

    # divide samples to the set
    train_samples.each {|sample|
        dis = [];
        set_sel = 0;
        SetCnt.times {|i|
            dis[i] = (sample[0] - set_avg[i][0]) ** 2 + (sample[1] - set_avg[i][1]) ** 2;
            # select the nearest set core
            set_sel = i if(dis[i] < dis[set_sel]);
        }
        # add the sample to the nearest set
        sample[2] = set_sel;
    }
    opt_times += 1;
end
print("K_mean iteration times: #{opt_times}\n");
SetCnt.times {|i|
    CSV1.print(set_avg[i][0], ",", set_avg[i][1], "\n");
}
CSV1.close;
CSV2.close;

# calc the omicron value for phi function
# select the max distance between two set cores
d2max = 0;
SetCnt.times {|i|
    i.upto(SetCnt - 1) {|j|
        temp = (set_avg[i][0] - set_avg[j][0]) ** 2 + (set_avg[i][1] - set_avg[j][1]) ** 2;
        d2max = temp if(d2max < temp);
    }
}
omicron = Math.sqrt(d2max) / Math.sqrt(2 * SetCnt);
print("Omicron value: #{omicron}\n");

# Train step II: RLS for w(n).
# middle-layer output
# parameter for matrix initial value
LAMBDA = 0.01;
# create R(0) = lambda * I, P(0) = 1/R(n) = I / lambda
p_last = Matrix.scalar(SetCnt, 1.0 / LAMBDA);
# create W(0) = [all 0]T
w_last = Matrix.build(SetCnt, 1) {0.0};
PointTrainCnt.times {|i|
    # points is generated as "up, down, up, down, ..."
    d_n = (i % 2 == 0) ? 1.0 : 0.0;
    # x(n) after coordinate exchange
    phi_n = Matrix.build(SetCnt, 1) {|row, col|
        phi_ij(omicron, set_avg[row], train_samples[i]);
    }
    y_n = (phi_n.t * w_last)[0, 0];
    a_n = d_n - y_n;
    p_n = p_last - p_last * phi_n * phi_n.t * p_last / ( 1 + (phi_n.t * p_last * phi_n)[0, 0]);
    g_n = p_n * phi_n;
    w_n = w_last + g_n * a_n;
    p_last = p_n;
    w_last = w_n;
    CSV3.print(a_n, ",", w_n[0, 0], "\n");
}
w_last.each {|w| CSV3.print(",", w);}
CSV3.close;
# Train end.

# test the neuron network
print("Start to test the neuron network...\n");
TestCount = 10000;
err_cnt = 0;
(TestCount / 2).times {
    dot = random_dot_pair_half_circle(CIRCLE_R, CIRCLE_WIDTH, CIRCLE_DIS);
    2.times {|i|
        phi_n = Matrix.build(SetCnt, 1) {|row, col|
            phi_ij(omicron, set_avg[row], dot[i]);
        }
        val = (phi_n.t * w_last)[0, 0];
        y = (val > 0.5) ? 1.0 : 0.0;
        d_n = (i == 0) ? 1.0 : 0.0;
        if(y != d_n)
            err_cnt += 1;
            CSV4.print(dot[i][0], ",", dot[i][1], "\n");
        end
    }
}
CSV4.close;
print("Error judgement count: #{err_cnt}\n");
print("Error percent: #{err_cnt * 100.0 / TestCount}\%\n");
