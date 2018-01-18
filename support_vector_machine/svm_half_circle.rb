#! /usr/bin/ruby -w
# Train in two steps:
# 1. Use K-mean iteration-down to divide samples into sets.
# 2. Use core-base functions as middle layer.
# 3. Use SVM algorithm.

require 'matrix'
require './smo'

DIMENSION_CNT = 2;
# core function by Gauss
def phi_ij(omicron, core, point)
    dis2 = 0.0;
    DIMENSION_CNT.times {|i|
        dis2 += (core[i] - point[i]) ** 2;
    }
    Math.exp(dis2 / (-2 * omicron ** 2));
end

puts("K-mean + SVM for two half-circle.");

# config samples generator
require("../test_sample/two_half_circle.rb");
# circle parameter
CIRCLE_R = 10.0;
CIRCLE_WIDTH = 6.0;
CIRCLE_DIS = -5.0;

puts("Start to train the neuron network...");
# Train step I: K-mean iteration down.
# numbers of the point sets
SetCnt = 20;
# iteration times in K-mean
OptCnt = 100;
# iteration limit
Limit_avg_delta = 0.001;
# point count
PointTrainCnt = 300;
CSV1 = File.open("set_avg.csv", "w");
CSV2 = File.open("set_avg_delta.csv", "w");
CSV3 = File.open("vector.csv", "w");
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
    # add every sample to the corresponding set
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

# Train step II: SVM by SMO
# middle-layer output: coordinate exchange to RBF
# coordinates of all the points, dimension count as SetCnt
x = [];
# value of all the points
d = [];
PointTrainCnt.times {|i|
    # points is generated as "up, down, up, down, ..."
    d[i] = (i % 2 == 0) ? 1 : -1;
    # x[i] after coordinate exchange
    temp = [];
    SetCnt.times {|dim|
        temp << phi_ij(omicron, set_avg[dim], train_samples[i]);
    }
    x << temp;
}
# setup kernal matrix
k = Matrix.build(PointTrainCnt, PointTrainCnt) {|i, j|
    k_ij = 0.0;
    SetCnt.times {|m|
        k_ij += x[i][m] * x[j][m];
    }
    k_ij;
};

# use SMO algorithm
point_cnt = SMO.init_point(d, k);
print "Point count = #{point_cnt}\n";
cycle = SMO.iterate;
print "Iterate times: #{cycle}\n";
# output value of a
a = SMO.result;
# generate wn and b
wn = Array.new(SetCnt, 0.0);
b = 0.0;
# count of the support vectors
sv_cnt = 0;
# calculate wn
PointTrainCnt.times {|i|
    if(a[i] > 1E-4)
        sv_cnt += 1;
        CSV3.print("#{train_samples[i][0]},#{train_samples[i][1]},#{d[i]},#{a[i]}\n");
        SetCnt.times {|j|
            wn[j] += a[i] * d[i] * x[i][j];
        }
    else
        a[i] = 0.0;
    end
}
# calculate b as average
PointTrainCnt.times {|i|
    if(a[i] > 1E-4)
        b += 1;
        SetCnt.times {|j|
            b += wn[j] * x[i][j];
        }
    end
}
b /= sv_cnt;

CSV3.close;
# Train end.

# test the neuron network
print("Start to test the neuron network...\n");
TestCount = 1000;
err_cnt = 0;
(TestCount / 2).times {
    dot = random_dot_pair_half_circle(CIRCLE_R, CIRCLE_WIDTH, CIRCLE_DIS);
    2.times {|i|
        # coordinate exchange
        x = [];
        SetCnt.times {|dim|
            x << phi_ij(omicron, set_avg[dim], dot[i]);
        }
        val = b;
        SetCnt.times {|dim|
            val += wn[dim] * x[dim];
        }
        y = (val >= 0.0) ? 1 : -1;
        d_n = (i == 0) ? 1 : -1;
        if(y != d_n)
            err_cnt += 1;
            CSV4.print("#{val},#{d_n},#{dot[i][0]},#{dot[i][1]}\n");
        end
    }
}
CSV4.close;
print("Error judgement count: #{err_cnt}\n");
print("Error percent: #{err_cnt * 100.0 / TestCount}\%\n");

