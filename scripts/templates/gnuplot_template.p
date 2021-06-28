#! /usr/local/bin/gnuplot -c

# This is a gnuplot script which expect file to plot as argument
set grid
plot ARG1 using 1:2 with linespoint title columnheader
pause -1
