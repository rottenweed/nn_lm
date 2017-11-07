#! /usr/bin/ruby -w
# Train in two steps:
# 1. Use K-mean iteration-down to divide samples into sets.
# 2. Use core-base functions as middle layer, and RLS(Recursive Least Square) in the output layer.

def phi_ij(omicron, core, point)
    dis2 = (core[0] - point[0]) ** 2 + (core[1] - point[1]) ** 2;
    Math.exp(dis2 / (-2 * omicron ** 2));
end

puts("K-mean + RLS for two half-circle.");

# config samples generator
require("../test_sample/two_half_circle.rb");
# circle parameter
CIRCLE_R = 10.0;
CIRCLE_WIDTH = 6.0;
CIRCLE_DIS = -1.0;

puts("Start to train the neuron network...");
# Train step I: K-mean iteration down.
# numbers of the point sets
SetCnt = 20;
# iteration times in K-mean
OptCnt = 10;
# iteration limit
Limit_avg_delta = 0.1;
# point count
PointTrainCnt = 1000;
CSV1 = File.open("set_avg.csv", "w");
CSV2 = File.open("set_avg_delta.csv", "w");

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
# initiate the sets at first
SetCnt.times {|i|
    set_sum << [0.0, 0.0, 0]; # [sum_x, sum_y, count]
    set_avg << [0.0, 0.0];
    set_avg_delta << [0.0, 0.0];
}
while(square_sum_of_avg_delta / SetCnt > Limit_avg_delta) 
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
end
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

# Train step II: RLS for w(n).
# middle-layer output
phi = Array.new(SetCnt, 0.0);
#PointTrainCnt.times {|i|
1.times {|i|
    SetCnt.times {|j|
        phi[j] = phi_ij(omicron, set_avg[j], train_samples[i]);
    }
}
print phi;
