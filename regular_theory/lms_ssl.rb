#! /usr/bin/ruby -w

# core function by Gauss
def phi_ij(omicron, core, point)
    dis2 = (core[0] - point[0]) ** 2 + (core[1] - point[1]) ** 2;
    Math.exp(dis2 / (-2 * omicron ** 2));
end

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

# CSV files for internal values
CSV_core = File.open("core.csv", "w");

# generate points in two half-circles for training
TRAIN_CNT = 1000;
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
#3.times {|i|
    # save the last set_avg results
    # cannot copy the array!
    set_avg_old.each_index {|j|
        set_avg_old[j][0] = set_avg[j][0];
        set_avg_old[j][1] = set_avg[j][1];
    }
    # calculation the average vector of the set (for Min||x-avg||)
    set_avg.map! {|value|
        value = [0.0, 0.0]
    }
    set_point_cnt.map! {|value|
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
SET_CNT.times {|i|
    CSV_core.print("#{set_avg[i][0]}, #{set_avg[i][1]}, #{set_point_cnt[i]}\n");
}
CSV_core.close();

# calc the omicron value for phi function
# select the max distance between two set cores
d2max = 0;
SET_CNT.times {|i|
    i.upto(SET_CNT - 1) {|j|
        temp = (set_avg[i][0] - set_avg[j][0]) ** 2 + (set_avg[i][1] - set_avg[j][1]) ** 2;
        d2max = temp if(d2max < temp);
    }
}
omicron = Math.sqrt(d2max) / Math.sqrt(2 * SET_CNT);
print("Omicron value: #{omicron}\n");

# exchange the dimension space
# each sample has SET_CNT position variables
samples = Array.new(TRAIN_CNT) {|xn| Array.new(SET_CNT, 0.0)};

TRAIN_CNT.times {|i|
    SET_CNT.times {|j|
        samples[i][j] = phi_ij(omicron, set_avg[j], train_point[i]);
    }
}

require('matrix');
matrix_Gram = Matrix.build(TRAIN_CNT, TRAIN_CNT) {|i, j|
    sum = 0.0;
    SET_CNT.times {|k|
        sum += samples[i][k] * samples[j][k];
    }
    sum;
}
