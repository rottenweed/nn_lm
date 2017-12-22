#! /usr/bin/ruby -w
# On x-y plane, some points is used for SVM test.
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

# read n float values from the string.
def read_float(str, n)
    float_ptn = /[+-]?\d*\.?\d+/;
    i = 0;
    val = [0];
    while((str =~ float_ptn) && (i < n))
        i += 1;
        val << $&.to_f;
        str = $'
    end
    raise "Not enough float numbers in the string." if(i < n);
    val[0] = i;
    return val;
end

# Gause elimination with maximal column pivoting algorithm for linear equations.
# the lowest limit
ZERO_LIMIT = 1e-8;
# linear equations: AX = B
# A: n*m matrix, B: n*1 matrix
def Gause_elimination(mat_A, mat_B, n, m)
    # [row, col]: the left-upper element of the sub-matrix which needs to be eliminated.
    row = 0;
    col = 0;
    while((row < n) && (col < m))
        # select the maximum in the column
        max_index = row;
        max = mat_A[row, col].abs;
        row.upto(n - 1) {|i|
            if(mat_A[i, col].abs > max)
                max = mat_A[i, col].abs;
                max_index = i;
            end
        }
        # check the column, clear if the total parameter column are zero
        if(max < ZERO_LIMIT)
            row.upto(n - 1) {|i|
                mat_A[i, col] = 0.0;
            }
        # elimination of the sub matrix
        else
            ratio = 1.0 / mat_A[max_index, col];
            # adjust the max head value to 1
            mat_A[max_index, col] = 1.0;
            (col + 1).upto(m - 1) {|j|
                mat_A[max_index, j] *= ratio;
            }
            mat_B[max_index, 0] *= ratio;
            if(max_index != row)
                # swap the line to the first
                m.times {|j|
                    temp = mat_A[row, j];
                    mat_A[row, j] = mat_A[max_index, j];
                    mat_A[max_index, j] = temp;
                }
                temp = mat_B[row, 0];
                mat_B[row, 0] = mat_B[max_index, 0];
                mat_B[max_index, 0] = temp;
            end
            # clear head elements of all the following lines
            (row + 1).upto(n - 1) {|i|
                ratio = mat_A[i, col];
                mat_A[i, col] = 0.0;
                # sub the line
                (col + 1).upto(m - 1) {|j|
                    mat_A[i, j] -= mat_A[row, j] * ratio;
                }
                mat_B[i, 0] -= mat_B[row, 0] * ratio;
            }
            row += 1;
        end
        col += 1;
    end
    return row; # as rank of mat_A
end

# Dual problem, antithetic equation.
print("Support Vector Machine for points on x-y plane.\n");
print("Use dual-problem algorithm & sum(a(i)d(i)) = 0.\n");
print("Input the count of points: ");
Dimension = 2;  # dimension of w and X
pointCnt = gets.to_i;
print("Input the [x, y, d] of the Points:\n");

a_X = [];   # coordinates
a_D = [];   # d values
pointCnt.times {|i|
    a_X << [];    # add a new line
    print("Point #{i}: ");
    data_point = read_float(gets(), 3);
    Dimension.times {|k|
        a_X[i] << data_point[k + 1];
    }
    a_D << data_point[Dimension + 1];
}
# Q(a) parameter matrix for maximum equation
# variables as [a(n)]
var_ratio = Matrix.build(pointCnt + 1, pointCnt + 1) {0.0};
# right constant value for the equations
value = Matrix.build(pointCnt + 1, 1) {1.0};

# Q(a) matrix formula: sum of a(i)d(i)d(j)X(i)X(j) = 1
pointCnt.times {|i|
    pointCnt.times {|j|
        Dimension.times {|k|
            var_ratio[i, j] += a_X[i][k] * a_X[j][k];
        }
        var_ratio[i, j] *= a_D[i] * a_D[j];
    }
    # Lagrange ratio of sum(a(i)d(i)) = 0
    var_ratio[i, pointCnt] = a_D[i];
}
# sum(a(i)d(i)) = 0
pointCnt.times {|i|
    var_ratio[pointCnt, i] = a_D[i];
}
value[pointCnt, 0] = 0.0;

(pointCnt + 1).times {|i|
    print("#{var_ratio.row(i)} = #{value[i, 0]}, \n");
}

rank = Gause_elimination(var_ratio, value, pointCnt + 1, pointCnt + 1);
print("rank = #{rank}\n");
(pointCnt + 1).times {|i|
    print("#{var_ratio.row(i)} = #{value[i, 0]}, \n");
}

if(rank == pointCnt + 1)    # full rank
    a_solution = var_ratio.inv * value;
    print("a[] = #{a_solution}\n");
    # Calculate [w..., b]
    wn = Array.new(Dimension, 0.0);
    Dimension.times {|i|
        pointCnt.times {|j|
            wn[i] += a_solution[j, 0] * a_D[j] * a_X[j][i];
        }
    }
    print("wn: #{wn}\n");
    b = 0;
    cnt_support_vector = 0;
    pointCnt.times {|i|
        if(a_solution[i, 0] != 0)  # support vector
            cnt_support_vector += 1;
            b += a_D[i];
            Dimension.times {|j|
                b -= wn[j] * a_X[i][j];
            }
        end
    }
    b /= cnt_support_vector;
    print("b: #{b}\n");
else
    lms_process = false;
    rank.upto(pointCnt) {|i|
        if(value[i, 0].abs > ZERO_LIMIT)
            printf("No resolution.\n");
            value = var_ratio.t * value;
            var_ratio = var_ratio.t * var_ratio;
            print("Make least mean square\n");
            rank = Gause_elimination(var_ratio, value, pointCnt + 1, pointCnt + 1);
            print("rank = #{rank}\n");
            lms_process = true;
            break;
        end
    }
    if(lms_process == true)
        (pointCnt + 1).times {|i|
            print("#{var_ratio.row(i)} = #{value[i, 0]}, \n");
        }
    end
end

