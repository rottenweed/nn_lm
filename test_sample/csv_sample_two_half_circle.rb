# /usr/bin/ruby -w

# Function:
# Create 2000 pairs of dots in two half-circle areas

require("./two_half_circle.rb");

BEGIN {
    print("Start to generate samples in two half-circle areas.\n");
    CSV = File.open("circle_dot.csv", "w");
    raise("File \"circle_dot.csv\" open failed!") if(!CSV);
}

cnt = 2000;
cnt.times {|i|
    dot_pos = random_dot_pair_half_circle(10.0, 6.0, 4.0);
    CSV.print(dot_pos[0][0], ",", dot_pos[0][1], "\n");
    CSV.print(dot_pos[1][0], ",", dot_pos[1][1], "\n");
}

END {
    print("Program end.\n");
    CSV.close;
}
__END__
2017.08.17
