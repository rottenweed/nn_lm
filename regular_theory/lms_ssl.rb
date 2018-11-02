#! /usr/bin/ruby -w

ZERO_LIMIT = 1e-8;
def val_f(x)
    # continuous version: Math.tanh(x)
    val_f = (x.abs < ZERO_LIMIT) ? 0.0 :
            (x > 0) ? 1.0 : -1.0; 
end

print("Test two half circle in Semi-Supervised Learning.\n");

# config samples generator
require("../test_sample/two_half_circle.rb");
CIRCLE_R = 10.0;
CIRCLE_WIDTH = 6.0;
CIRCLE_DIS = 1.0;

# generate points in two half-circles for training
TRAIN_CNT = 200;
SUPERVISE_CNT = 4;
train_point = []; # point saved as [x, y, val]
(TRAIN_CNT / 2).times {|i|
    point_pair = random_dot_pair_half_circle(CIRCLE_R, CIRCLE_WIDTH, CIRCLE_DIS);
    train_point << [point_pair[0][0], point_pair[0][1], 1.0];
    train_point << [point_pair[1][0], point_pair[1][1], -1.0];
}

# K-mean algorithm
SET_CNT = 20; # count of point sets
OPTI_TIMES = 20; # optimize cycle time
AVG_DELTA_LIMIT = 1e-4;
set_avg = []; # [x, y] of the set average
set_point = []; # points in the set
SET_CNT.times {|i| set_avg << [0.0, 0.0]};
SET_CNT.times {|i| set_point[i] = [];}
# randomly put points to every set
TRAIN_CNT.times {|i|
    set_point[i % SET_CNT] << train_point[i];
}

# optimize cycles
OPTI_TIMES.times {|i|
    set_avg_delta_sum = 0.0;
    # calculation the average vector of the set (for Min||x-avg||)
    SET_CNT.times {|j|
        set_avg_old = set_avg[j];
        if(set_point[i].size == 0) # empty set
            set_avg[j] = [0.0, 0.0];
        else
            sum_pos = set_point[j].inject([0.0, 0.0]) {|sum, pos|
                [sum[0] + pos[0], sum[1] + pos[1]];}
            set_avg[j] = [sum_pos[0] / set_point[j].size, sum_pos[1] / set_point[j].size];
        end
        set_avg_delta_sum += (set_avg[j][0] - set_avg_old[0]) ** 2;
        set_avg_delta_sum += (set_avg[j][1] - set_avg_old[1]) ** 2;
    }

    print(i, ",", set_avg_delta_sum, "\n");
    break if(set_avg_delta_sum < AVG_DELTA_LIMIT * SET_CNT);
}
