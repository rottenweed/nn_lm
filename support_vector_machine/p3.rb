#! /usr/bin/ruby -w
# On x-y plane, 3 points is used for SVM test.

# Use Matrix lib
require "matrix"
# add method []= to class Matrix.
# modify an assigned element.
class Matrix
    def []=(i, j, x)
        @rows[i][j] = x;
    end
end

print("Support Vector Machine for 3 points on x-y plane.\n");

Dimension = 2;  # dimension of w and X
PointCnt = 3;   # count of support vectors
# the coordinates of the 3 points
X = [[-1.0, 0.0], [-1.0, -2.0], [0.0, 1.0], [1.0, 0.0]];
# the d values of the 3 points
D = [1.0, -1.0, 1.0, -1.0];

# parameter matrix for minimum equation
# variables as [w0, w1, b, a1, a2, a3]
var_ratio = Matrix.build(Dimension + PointCnt + 1, Dimension + PointCnt + 1) {0.0};
# right constant value for the equations
value = Matrix.build(Dimension + PointCnt + 1, 1) {0.0};
# wn formulas
Dimension.times {|i|
    var_ratio[i, i] = 1;
    PointCnt.times {|j|
        var_ratio[i, Dimension + 1 + j] = -D[j] * X[j][i];
    }
}
# formula: sum of a(i)d(i) = 0
PointCnt.times {|i|
    var_ratio[Dimension, Dimension + 1 + i] = D[i];
}
# constraint of support vectors
PointCnt.times {|i|
    Dimension.times {|j|
        var_ratio[Dimension + 1 + i, j] = X[i][j];
    }
    var_ratio[Dimension + 1 + i, Dimension] = 1.0;
}
# right value of every formula
PointCnt.times {|i|
    value[Dimension + 1 + i, 0] = D[i];
}

print var_ratio, "\n"
print "matrix rank: #{var_ratio.rank}\n"
result = Matrix.build(Dimension + PointCnt + 1, 1) {0.0};
result = var_ratio.inv * value;
print("wn, b, an:\n", result, "\n");

# Antithetic condition equation is not full to judge the extremum.
# It can be used as limits.
