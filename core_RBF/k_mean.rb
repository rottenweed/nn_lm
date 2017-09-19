#! /usr/bin/ruby -w

# Use K-mean alogrithm

# calculate Gauss distribution
# parameter omega

def gauss(x, omega = 1.0)
    Math.exp(- x * x / (2.0 * omega * omega)) / (omega * Math.sqrt(2 * Math::PI));
end

