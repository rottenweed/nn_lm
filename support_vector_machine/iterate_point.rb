#! /usr/bin/ruby -w
# Iterate a(n) in dual question

require 'matrix'
print("Solve dual question in iterate loop  (SMO algorithm).\n")

#point_cnt = 4;
point_cnt = 3;
dimension = 2;
MAX_A_VALUE = 1E10;
DELTA_LIMIT = 1E-6;
# Point positon
#x = [[-1, 1], [1, 1], [0, -1], [0, 2]];
x = [[0, 1], [0, -1], [0, 2]];
# Value
#d = [1, 1, -1, 1];
d = [1, -1, 1];
# Kernel as x(i)*x(j)
k = Matrix.build(point_cnt, point_cnt) {|i, j|
    k_ij = 0.0;
    dimension.times {|m|
        k_ij += x[i][m] * x[j][m];
    }
    k_ij;
};
# Lagrange multiple number
#a = [1, 2, 6, 3];
a = [1, 3, 2];

delta = 1.0;
n1 = 0;
while((n1 != 0) || (delta > DELTA_LIMIT))
    n2 = n1 + 1;
    n2 -= point_cnt if(n2 >= point_cnt);
    delta = 0.0 if(n1 == 0);
    aidi_else = 0;
    point_cnt.times {|i|
        if((i != n1) && (i != n2))
            aidi_else += a[i] * d[i];
        end
    }
    if(d[n1] * d[n2] > 0)
        a1_min = 0.0;
        a1_max = - aidi_else * d[n1];
        raise("Error! a1_max < 0!") if(a1_max < 0);
    else
    a1_min = [0.0, - aidi_else * d[n1]].max;
    a1_max = MAX_A_VALUE;
    end
    
    #calculate a1 for the max point
    a1 = d[n1] - d[n2] - (k[n2, n2] - k[n1, n2]) * aidi_else;
    point_cnt.times {|i|
        if((i != n1) && (i != n2))
            a1 -= a[i] * d[i] * (k[n1, i] - k[n2, i]);
        end
    }
    a1 *= d[n1];
    a1 /= k[n1, n1] + k[n2, n2] - 2 * k[n1, n2];
    # a1 value limit
    a1 = a1_min if(a1 < a1_min);
    a1 = a1_max if(a1 > a1_max);
    a2 = -a1 * d[n1] * d[n2] - aidi_else * d[n2];
    delta = [delta, (a[n1] - a1).abs].max;
    a[n1] = a1;
    a[n2] = a2;
    # to next cycle
    n1 += 1;
    n1 = 0 if(n1 == point_cnt);
    print "#{a}, #{delta}\n" if(n1 == 0);
end

print "#{a}\n";
