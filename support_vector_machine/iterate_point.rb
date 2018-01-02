#! /usr/bin/ruby -w
# Iterate a(n) in dual question

require 'matrix'
print("Solve dual question in iterate loop.\n")

def w()
    val = 0;
    4.times {|i| val += A[i];}
    4.times {|m|
        m.upto(3) {|n|
            val -= Kij[m, n] * A[m] * A[n];
        }
    }
    return val;
end

# Point positon
X = [[-1, 1], [1, 1], [0, -1], [0, 2]];
# Value
D = [1, 1, -1, 1];
# Kernel as x(i)*x(j)
Kij = Matrix.build(4, 4) {|i, j|
    if(i < j)
        2 * (X[i][0] * X[j][0] + X[i][1] * X[j][1]) * D[i] * D[j];
    elsif(i == j)
        (X[i][0] * X[j][0] + X[i][1] * X[j][1]) * D[i] * D[j];
    else
        0;
    end
};
# Lagrange multiple number
A = [0.5, 0.5, 1.0, 0.0];

print(Kij, "\n");
print w;
