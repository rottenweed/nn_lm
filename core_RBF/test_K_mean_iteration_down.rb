#! /usr/bin/ruby -w

# Use K-mean alogrithm.
# Divide points to 4 fan-shaped sectors.

require('../test_sample/four_fan_sector.rb')
CSV = File.open("set_avg.csv", "w");
CSV_point = File.open("set_point.csv", "w");

GAP = 0.1;
PointCnt = 10000;
SetCnt = 4;
OptCNT = 20;

# create points for test
point_samples = [];
PointCnt.times {|i|
    point_samples << create_dot(GAP);
}

# init the sets
# average [x, y] of the set
set_avg = [];
SetCnt.times {|i| set_avg[i] = [0.0, 0.0];}
# the points in this set
set_point = [];
SetCnt.times {|i| set_point[i] = [];}
# randomly put 1/4 points to every set
PointCnt.times {|i|
    set_point[i % SetCnt] << point_samples[i];
}

# optimize cycle
OptCNT.times {|i|
    # calculation the average vector of the set (for Min||x-avg||)
    SetCnt.times {|j|
        if(set_point[j].size == 0)  # empty set
            set_avg[j] = [0.0, 0.0];
        else
            sum_pos = set_point[j].inject([0.0, 0.0]) {|sum, pos|
                [sum[0] + pos[0], sum[1] + pos[1]];}
            set_avg[j] = [sum_pos[0] / set_point[j].size, sum_pos[1] / set_point[j].size];
        end
    }

    # output the core of the sets
    CSV.print("#{i},");
    SetCnt.times {|j| CSV.print("#{set_avg[j][0]},#{set_avg[j][1]},");}
    CSV.print("\n");

    # divide the points into sets again
    SetCnt.times {|j| set_point[j] = [];}   # clear the sets at first
    point_samples.size.times {|k|
        dis = [];
        SetCnt.times {|j|
            dis[j] = (point_samples[k][0] - set_avg[j][0]) ** 2 + (point_samples[k][1] - set_avg[j][1]) ** 2;
        }
        set_sel = 0;
        # select the nearest set core
        1.upto(SetCnt - 1) {|j| set_sel = j if(dis[j] < dis[set_sel]);}
        # add the point to the nearset set
        set_point[set_sel] << point_samples[k];
    }
}

CSV.close;
SetCnt.times {|j| print("#{set_avg[j][0]}, #{set_avg[j][1]}\n");}

set_point[0].each {|pos|
    CSV_point.print("#{pos[0]},#{pos[1]}\n");
}
CSV_point.close;
