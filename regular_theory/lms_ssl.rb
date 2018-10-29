#! /usr/bin/ruby -w

def val_f(x)
    # continuous version: Math.tanh(x)
    val_f = (x == 0) ? 0.0 :
            (x > 0) ? 1.0 : -1.0; 
end

print("Test two half circle in Semi-Supervised Learning.\n");

# config samples generator
require("../test_sample/two_half_circle.rb");
CIRCLE_R = 10.0;
CIRCLE_WIDTH = 6.0;
CIRCLE_DIS = 1.0;

# generate points in two half-circles for training
TRAIN_CNT = 10;
SUPERVISE_CNT = 4;
train_point_xy = [];
train_point_d = [];
(TRAIN_CNT / 2).times {|i|
    point_pair = random_dot_pair_half_circle(CIRCLE_R, CIRCLE_WIDTH, CIRCLE_DIS);
    train_point_xy << point_pair[0];
    train_point_d << 1.0;
    train_point_xy << point_pair[1];
    train_point_d << -1.0;
}
