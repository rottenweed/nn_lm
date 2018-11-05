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
TRAIN_CNT = 20;
SUPERVISE_CNT = 4;
train_point = []; # point saved as [x, y, val, set_sel]
(TRAIN_CNT / 2).times {|i|
    point_pair = random_dot_pair_half_circle(CIRCLE_R, CIRCLE_WIDTH, CIRCLE_DIS);
    train_point << [point_pair[0][0], point_pair[0][1], 1.0, 0];
    train_point << [point_pair[1][0], point_pair[1][1], -1.0, 0];
}

# K-mean algorithm
SET_CNT = 20; # count of point sets
OPTI_TIMES = 20; # optimize cycle time
AVG_DELTA_LIMIT = 1e-4;
set_avg = []; # [x, y] of the set average
SET_CNT.times {|i| set_avg << [0.0, 0.0]};
set_avg_old = []; # old value of set_avg
SET_CNT.times {|i| set_avg_old << [0.0, 0.0]};
set_point_cnt = Array.new(SET_CNT, 0); # the count of points in every set
# randomly put points to every set
TRAIN_CNT.times {|i|
    train_point[i][3] = i % SET_CNT;
}

# optimize cycles
OPTI_TIMES.times {|i|
    # save the last set_avg results
    # cannot copy the array!
    SET_CNT.times {|j|
        set_avg_old[j][0] = set_avg[j][0];
        set_avg_old[j][1] = set_avg[j][1];
    }
    # calculation the average vector of the set (for Min||x-avg||)
    set_avg.each {|value|
        value = [0.0, 0.0]
    }
    set_point_cnt.each {|value|
        value = 0;
    }
    train_point.each {|sample|
        set_sel = sample[3];
        set_avg[set_sel][0] += sample[0];
        set_avg[set_sel][1] += sample[1];
        set_point_cnt[set_sel] += 1;
    }
    set_avg_delta_sum = 0.0;
    SET_CNT.times {|j|
        if(set_point_cnt[j] != 0)
            set_avg[j][0] /= set_point_cnt[j];
            set_avg[j][1] /= set_point_cnt[j];
        end
        set_avg_delta_sum += (set_avg[j][0] - set_avg_old[j][0]) ** 2;
        set_avg_delta_sum += (set_avg[j][1] - set_avg_old[j][1]) ** 2;
    }

    print(i, ",", set_avg_delta_sum, "\n");
    break if(set_avg_delta_sum < AVG_DELTA_LIMIT * SET_CNT);

    # divide the points to sets
    train_point.each {|sample|
        dis = Array.new(SET_CNT, 0.0);
        set_sel = 0;
        SET_CNT.times {|j|
            dis[j] = (sample[0] - set_avg[j][0]) ** 2 + (sample[1] - set_avg[j][1]) ** 2;
            set_sel = j if(dis[j] < dis[set_sel]);
        }
        # add the point to the nearest core
        sample[3] = set_sel;
    }
}

# save the core position to CSV
CSV_core = File.open("core.csv", "w");
SET_CNT.times {|i|
    CSV_core.print("#{set_avg[i][0]}, #{set_avg[i][1]}\n");
}

