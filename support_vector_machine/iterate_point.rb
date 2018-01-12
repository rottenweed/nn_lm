#! /usr/bin/ruby -w
# Iterate a(n) in dual question

require 'matrix'
print("Solve dual question in iterate loop.\n")

point_cnt = 4;
MAX_A_VALUE = 1E10;
# Point positon
X = [[-1, 1], [1, 1], [0, -1], [0, 2]];
# Value
D = [1, 1, -1, 1];
# Kernel as x(i)*x(j)
k = Matrix.build(point_cnt, point_cnt) {|i, j|
    X[i][0] * X[j][0] + X[i][1] * X[j][1];
};
# Lagrange multiple number
a = [0.25, 0.25, 0.5, 0.0];

n1 = 2;
n2 = n1 + 1;
aidi_else = 0;
point_cnt.times {|i|
    if((i != n1) && (i != n2))
        aidi_else += a[i] * D[i];
    end
}
if(D[n1] * D[n2] > 0)
    a1_min = 0;
    a1_max = - aidi_else * D[n1];
    raise("Error! a1_max < 0!") if(a1_max < 0);
else
    a1_min = [0, - aidi_else * D[n1]].max;
    a1_max = MAX_A_VALUE;
end

#calculate a1 for the max point
a1 = D[n1] - D[n2] - (k[n2, n2] - k[n1, n2]) * aidi_else;
point_cnt.times {|i|
    if((i != n1) && (i != n2))
        a1 -= a[i] * D[i] * (k[n1, i] - k[n2, i]);
    end
}
a1 *= D[n1];
a1 /= k[n1, n1] + k[n2, n2] - 2 * k[n1, n2];
# a1 value limit
a1 = a1_min if(a1 < a1_min);
a1 = a1_max if(a1 > a1_max);
a2 = -a1 * D[n1] * D[n2] - aidi_else * D[n2];
a[n1] = a1;
a[n2] = a2;

print "#{a}\n";
