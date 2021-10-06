# ruby-wads

A number of Ruby Gosu-based (W)idgets (a)nd (D)ata (S)tructures for your applications.

Wads (Widgets and Data Structures) is intended to help you quickly build native Ruby applications using the Gosu gem.
GUI widgets, such as tables and buttons, are provided to simplify building graphical applications.
Widgets in wads can be used independently within your Gosu app, or you can use wads as a holistic GUI framework.
Wads includes basic features found in many GUI toolkits including The use of themes and a layout manager.

One of the motivations for creating wads is to making data analysis, games, and productivity applications using Ruby easier to do.
Data structures are included that can be used for statistical analysis or graph-based applications.
The samples provided illustrate both use cases (Stocks - stats) and Star Wars character interactions (graphs).

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

![alt Screenshot](https://github.com/dbroemme/ruby-wads/blob/main/media/StocksSample.png?raw=true)


You can also see the graph capabilities by running the Star Wars analysis example.
This uses a data set that captures all character interactions within Episode 4.

```
./run-sample-app -j
```

There is also a sample Graph display using the following command.
```
./run-sample-app -g
```
Note that you can construct graphs in one of two ways. The first approach uses Nodes directly.
```
root = Node.new("a")
b = root.add("b")
b.add("d")
b.add("e").add("f")
root.add("c")
Graph.new(root)
```
The second approach uses an overarching Graph object. 
```
g = Graph.new 
g.add("a")
g.add("b")
g.add("c")
g.add("d")
g.add("e")
g.add("f")
g.connect("a", "b")
g.connect("a", "c")
g.connect("b", "d")
g.connect("b", "e")
g.connect("e", "f")
```

Currently, the Graph object is used by the Graph Widget for display. For the code above, this appears by default as follows:

![alt Screenshot](https://github.com/dbroemme/ruby-wads/blob/main/media/SampleGraph.png?raw=true)

## References

The Star Wars data set is courtesy of:
Gabasova, E. (2016). Star Wars social network. DOI: https://doi.org/10.5281/zenodo.1411479.
