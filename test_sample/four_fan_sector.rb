# /usr/bin/ruby -w

# generate a random dot in 4 fan-shaped sectors
# circle formula: x ** 2 + y ** 2 = 1
# w: width of gap between sectors
def create_dot(w = 0.1)
    raise("The value of circle width is illegal.") if(w < 0);
    in_circle = false;
    while(!in_circle)
        x = 2 * (rand() - 0.5);
        y = 2 * (rand() - 0.5);
        in_circle = true if(x ** 2 + y ** 2 <= 1.0);
    end
    (x >= 0) ? (x += w) : (x -= w);
    (y >= 0) ? (y += w) : (y -= w);
    return x, y;
end
