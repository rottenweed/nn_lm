#! /usr/bin/ruby -w
# test SMO module

require './smo'

SMO.MAX_LIMIT_C = 1E6;
point_cnt = 8;
dimension = 2;
#x = [[-1, 1], [0, 2], [1, 1], [0, -1], [2, -2]];
x = [[-1, 1], [-10, -4], [0, 3], [2, -2], [1, 1], [0, 2], [0, -1], [3, 9]];
d = [];
x.size.times {|i|
    d[i] = if(x[i][1] >= 0) then 1  # y >= 0
           else -1;
    end
}
k = Matrix.build(point_cnt, point_cnt) {|i, j|
    k_ij = 0.0;
    dimension.times {|m|
        k_ij += x[i][m] * x[j][m];
    }
    k_ij;
};

#SMO.a_init_value = 0.1;
print "SMO parameters: #{SMO.show_parameter()}\n";
print "Point count = #{SMO.init_point(point_cnt, d, k)}\n";
#SMO.a = [0.25, 0, 0.25, 0.5, 0];
cycle = SMO.iterate;
print "Iterate times: #{cycle}\n";
a = SMO.result;
print "a value: #{a}\n";

# calculate w and b
w = Array.new(dimension, 0.0);
point_cnt.times {|i|
    dimension.times {|j|
        w[j] += a[i] * d[i] * x[i][j];
    }
}
b = 0.0;
b_div = 0.0;
point_cnt.times {|i|
    b += d[i] * a[i];
    b_div += a[i];
    dimension.times {|j|
        b -= a[i] * w[j] * x[i][j];
    }
}
b /= b_div;
print "#{w}, #{b}\n";

point_cnt.times {|i|
    d[i] = b;
    dimension.times {|j|
        d[i] += w[j] * x[i][j];
    }
}
print "d = ["
point_cnt.times {|i|
    print "#{d[i]} "
}
print "]\n"
