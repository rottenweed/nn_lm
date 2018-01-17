#! /usr/bin/ruby -w
# Module for SMO algorithm

require 'matrix'

module SMO
    # parameters
    @@max_limit_c = 1E8;
    @@dimension = 2;
    @@delta_limit = 1E-6;

    # variables
    @@point_cnt = 0;
    # position X
    @@x = [];
    # D value
    @@d = [];
    # kernel
    @@k = Matrix.build(2, 2);
    # Lagrange multiple number
    @@a = [];

    def self.MAX_LIMIT_C=(max_limit_c)
        @@max_limit_c = max_limit_c;
    end

    def self.show_parameter
        return @@max_limit_c, @@dimension, @@delta_limit;
    end

    def self.init_point(x, d, k)
        # save the object pointer
        @@x = x;
        @@d = d;
        @@k = k;
        @@point_cnt = d.size;
        # init Lagrange multiple number >= 1.0
        @@a = Array.new(@@point_cnt, 0.0);
        # record last points of +1/-1 d value
        d_pos_last = nil;
        d_neg_last = nil;
        # sum of a[i] * d[i] = 0
        sum = 0.0;
        @@point_cnt.times {|i|
            @@a[i] = 1.0;
            sum += @@a[i] * @@d[i];
            if(d[i] == 1)
                d_pos_last = i;
            elsif(d[i] == -1)
                d_neg_last = i;
            else
                raise "Error!!! d[#{i}] != +1/-1";
            end
        }
        raise "Error!!! No +1 point!" if(d_pos_last == nil);
        raise "Error!!! No -1 point!" if(d_neg_last == nil);
        if(sum < 0)
            @@a[d_pos_last] -= sum;
        else
            @@a[d_neg_last] += sum;
        end
        @@point_cnt;
    end

    def self.iterate()
        cycle = 0;
        delta = 1.0;
        n1 = 0;
        while((n1 != 0) || (delta > @@delta_limit))
            n2 = n1 + 1;
            n2 -= @@point_cnt if(n2 >= @@point_cnt);
            # clear delta when cycle start
            delta = 0.0 if(n1 == 0);
            aidi_else = 0;
            @@point_cnt.times {|i|
                if((i != n1) && (i != n2))
                    aidi_else += @@a[i] * @@d[i];
                end
            }
            if(@@d[n1] * @@d[n2] > 0)
                a1_min = 0.0;
                a1_max = - aidi_else * @@d[n1];
                raise("Error!!! a_max[#{n1}] < 0!") if(a1_max < 0);
            else
                a1_min = [0.0, - aidi_else * @@d[n1]].max;
                a1_max = @@max_limit_c;
            end
    
            #calculate a1 for the max point
            a1 = @@d[n1] - @@d[n2];
            a1 -= (@@k[n2, n2] - @@k[n1, n2]) * aidi_else;
            @@point_cnt.times {|i|
                if((i != n1) && (i != n2))
                    a1 -= @@a[i] * @@d[i] * (@@k[n1, i] - @@k[n2, i]);
                end
            }
            a1 *= @@d[n1];
            a1 /= @@k[n1, n1] + @@k[n2, n2] - 2 * @@k[n1, n2];
            # a1 value limit
            a1 = a1_min if(a1 < a1_min);
            a1 = a1_max if(a1 > a1_max);
            a2 = -a1 * @@d[n1] * @@d[n2] - aidi_else * @@d[n2];
            delta = [delta, (@@a[n1] - a1).abs].max;
            @@a[n1] = a1;
            @@a[n2] = a2;
            # to next cycle
            n1 += 1;
            if(n1 == @@point_cnt)
                n1 = 0;
                cycle += 1;
            end
        end
        cycle;
    end

    def self.result()
        @@a;
    end
end

