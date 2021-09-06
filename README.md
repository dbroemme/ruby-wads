# ruby-wads

A number of Ruby Gosu-based (W)idgets (a)nd (D)ata (S)tructures for your applications.

![alt Screenshot](https://github.com/dbroemme/ruby-wads/blob/main/media/WadsScreenshot.png?raw=true)
## Installation

Add this line to your application’s Gemfile:

```
gem 'wads'
```
And then run bundle install.

## Sample Application

To see ruby wads in use, run the sample application using the following commands:

```
git clone https://github.com/dbroemme/ruby-wads.git
cd ruby-wads
./bin/setup
./run
./run-sample-app -s
```

This will run the sample NASDAQ stocks analysis that features the use of the 
Stats class, and a table Gosu widget used to display the results of the analysis.

You can also see the graph capabilities by running the Star Wars analysis example.
This uses a data set that captures all character interactions within Episode 4.

```
./run-sample-app -j
```

There is also a sample Graph display using the following command.
```
./run-sample-app -g
```

## References

The Star Wars data set is courtesy of:
Gabasova, E. (2016). Star Wars social network. DOI: https://doi.org/10.5281/zenodo.1411479.
