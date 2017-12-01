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
# the coordinates of the 3 points
X = [[-1.0, 1.0], [0.0, -2.0], [1.0, 1.0]];
# the d values of the 3 points
d = [1.0, -1.0, 1.0];

Dimension = 2;  # dimension of w and X
PointCnt = 3;   # count of support vectors
# parameter matrix for minimum equation
# variables as [w0, w1, b, a1, a2, a3]
var_ratio = Matrix.build(Dimension + PointCnt + 1, Dimension + PointCnt + 1) {0.0};
# right constant value for the equations
value = Matrix.build(Dimension + PointCnt + 1, 1) {0.0};
# wn formulas
Dimension.times {|i|
    var_ratio[i, i] = 1;
    PointCnt.times {|j|
        var_ratio[i, Dimension + 1 + j] = -d[j] * X[j][i];
    }
}
# sum of a(i)d(i) formula
PointCnt.times {|i|
    var_ratio[Dimension, Dimension + 1 + i] = d[i];
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
    value[Dimension + 1 + i, 0] = d[i];
}

result = Matrix.build(Dimension + PointCnt + 1, 1) {0.0};
result = var_ratio.inv * value;
print("wn, b, an:\n", result, "\n");

# antithetic algorithem
print("Calculate with antithetic algorithem...\n");
var_ratio = Matrix.build(PointCnt, PointCnt) {0.0};
value = Matrix.build(PointCnt, 1) {1.0};
# From G(a), n-1 equations. Xij matrix is not full-rank.
# a(i)*a(j) -> no 1/2 ratio
(PointCnt - 1).times {|i|
    PointCnt.times {|j|
        x_dot_ij = 0.0;
        Dimension.times {|k|
            x_dot_ij += X[i][k] * X[j][k];
        }
        var_ratio[i, j] = x_dot_ij * d[i] * d[j];
    }
}
# sum of a(i)d(i) formula
PointCnt.times {|i|
    var_ratio[PointCnt - 1, i] = d[i];
}
value[PointCnt - 1, 0] = 0.0

an = Matrix.build(PointCnt, 1) {0.0};
an = var_ratio.inv * value;
print("an:\n", an, "\n");
wn = Array.new(Dimension, 0.0);
Dimension.times {|i|
    PointCnt.times {|j|
        wn[i] += an[j, 0] * d[j] * X[j][i];
    }
}
print("wn: #{wn}\n");
b = 0.0;
PointCnt.times {|i|
    b += 1 / d[i];
    Dimension.times {|j|
        b -= wn[j] * X[i][j];
    }
}
b /= PointCnt;
print("b: #{b}\n");

