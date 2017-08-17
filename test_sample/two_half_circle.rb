# /usr/bin/ruby -w

# generate a random dot in the 1/4 circle positive area
# circle formula: x ** 2 + y ** 2 = 1
# w: circle width / r
def create_dot(w)
    raise("The value of circle width is illegal.") if((w >= 1) || (w <= 0))
    in_circle = false;
    while(!in_circle)
        x = 2 * rand();
        y = 2 * rand();
        if((x ** 2 + y ** 2 < (1 - w / 2.0) ** 2) ||
                (x ** 2 + y ** 2 > (1 + w / 2.0) ** 2));
            in_circle = false;
        else
            in_circle = true;
        end
    end
    return x, y;
end

# generate a pair of random dots
# change the dot to assigned two half-cirlce areas
# all the parameters and the return values are Float/Rational
# r: circle center line R
# w: circle width
# d: lower half_circle distance
# return as: [[xp, yp], [xn, yn]]
def random_dot_pair_half_circle(r, w, d)
    dot_pos_p = create_dot(w / r);
    # upper half
    x_sign = rand();
    dot_pos_p[0] *= -1 if(x_sign < 0.5);
    dot_pos_p[0] *= r;
    dot_pos_p[1] *= r;
    # lower half
    dot_pos_n = create_dot(0.6);
    x_sign = rand();
    dot_pos_n[0] *= -1 if(x_sign < 0.5);
    dot_pos_n[0] += 1;
    dot_pos_n[0] *= r;
    dot_pos_n[1] *= -r;
    dot_pos_n[1] -= d;
    return dot_pos_p, dot_pos_n;
end

