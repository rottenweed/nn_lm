#! /usr/bin/ruby -w
# Train in two steps:
# 1. Use K-mean iteration-down to divide samples into sets.
# 2. Use core-base functions as middle layers, and RLS(Recursive Least Square) in the output layer.

puts("K-mean + RLS for two half-circle.");

# config samples generator
require("../test_sample/two_half_circle.rb");
# circle parameter
CIRCLE_R = 10.0;
CIRCLE_WIDTH = 6.0;
CIRCLE_DIS = -6.5;

puts("Start to train the neuron network...");
# Step I
# numbers of the point sets
SetCnt = 20;
# iteration times in K-mean
OptCnt = 10;
# point count
PointTrainCnt = 6;

# initiate the samples for train process.
# divide the samples to sets randomly.
train_samples = [];
(PointTrainCnt / 2).times {|i|
    dot = random_dot_pair_half_circle(CIRCLE_R, CIRCLE_WIDTH, CIRCLE_DIS);
    # sample point is saved as [x, y, set_No]
    train_samples << [dot[0][0], dot[0][1], i % SetCnt];
    train_samples << [dot[1][0], dot[1][1], i % SetCnt];
}
print train_samples
