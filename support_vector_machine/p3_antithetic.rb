#! /usr/bin/ruby -w
# On x-y plane, 3 or more points is used for SVM test.
# Antithetic algorithm is used.

# Use Matrix lib
require "matrix"
# add method []= to class Matrix.
# modify an assigned element.
class Matrix
    def []=(i, j, x)
        @rows[i][j] = x;
    end
end

print("Support Vector Machine for points on x-y plane.\n");
print("Use antithetic algorithm & sum(a(i)d(i)) = 0.\n");

Dimension = 2;  # dimension of w and X
PointCnt = 3;   # count of vectors
# the coordinates of the 3 points
X = [[-1.0, 0.0], [-1.0, -2.0], [0.0, 1.0], [1.0, 0.0]];
# the d values of the points
D = [1.0, -1.0, 1.0, -1.0];

# Q(a) parameter matrix for maximum equation
# variables as [a(n)]
var_ratio = Matrix.build(PointCnt + 1, PointCnt + 1) {0.0};
# right constant value for the equations
value = Matrix.build(PointCnt + 1, 1) {1.0};

# Q(a) matrix formula: sum of a(i)d(i)d(j)X(i)X(j) = 1
PointCnt.times {|i|
    PointCnt.times {|j|
        Dimension.times {|k|
            var_ratio[i, j] += X[i][k] * X[j][k];
        }
        var_ratio[i, j] *= D[i] * D[j];
    }
    # Lagrange ratio of sum(a(i)d(i)) = 0
    var_ratio[i, PointCnt] = D[i];
}
# sum(a(i)d(i)) = 0
PointCnt.times {|i|
    var_ratio[PointCnt, i] = D[i];
}
value[PointCnt, 0] = 0.0;

print var_ratio, "\n"
print "matrix rank: #{var_ratio.rank}\n"
an = Matrix.build(PointCnt, 1) {0.0};
an = var_ratio.inv * value;
print("an: #{an}\n");

wn = Array.new(Dimension, 0.0);
Dimension.times {|i|
    PointCnt.times {|j|
        wn[i] += an[j, 0] * D[j] * X[j][i];
    }
}
print("wn: #{wn}\n");

b = 0;
cnt_support_vector = 0;
PointCnt.times {|i|
    if(an[i, 0] != 0)  # support vector
        cnt_support_vector += 1;
        b += D[i];
        Dimension.times {|j|
            b -= wn[j] * X[i][j];
        }
    end
}
b /= cnt_support_vector;
print("b: #{b}\n");

