require 'gosu'
require_relative '../lib/wads'

include Wads 

class SampleGraphApp < WadsApp

    SAMPLE_GRAPH_DEFINITION_FILE = "./data/sample_graph.csv"

    def initialize
        super(800, 600, "Wads Sample Graph App")
        set_display(GraphDisplay.new(create_sample_graph))
    end 

    #
    # Below are three different ways you can construct a graph
    #
    def create_sample_graph
        g = Graph.new 
        g.add("A")
        g.add("B")
        g.add("C")
        g.add("D")
        g.add("E")
        g.add("F")
        g.connect("A", "B")
        g.connect("A", "C")
        g.connect("B", "D")
        g.connect("B", "E")
        g.connect("E", "F")
        g
    end

    def create_sample_graph_using_nodes
        root = Node.new("A")
        b = root.add("B")
        b.add("D")
        b.add("E").add("F")
        root.add("C")
        Graph.new(root)
    end

    def create_sample_graph_from_file
        Graph.new(SAMPLE_GRAPH_DEFINITION_FILE)
    end
end

class GraphDisplay < Widget

    def initialize(graph)
        super(0, 0, 800, 600)
        set_layout(LAYOUT_TOP_MIDDLE_BOTTOM)
        @graph = graph

        image = get_layout.add_image("./media/Banner.png", { ARG_SECTION => LAYOUT_TOP})
        image.add_text("Wads Sample App", 10, 20, nil, true)
        image.add_text("Version #{Wads::VERSION}", 13, 54)

        panel = get_layout.add_horizontal_panel({ ARG_SECTION => LAYOUT_BOTTOM})
        panel.add_button("Exit", 0, panel.height - 30) do
            WidgetResult.new(true)
        end
        panel.center_children
        panel.disable_border

        @graph_display = get_layout.add_graph_display(@graph, GRAPH_DISPLAY_TREE,
                                                      { ARG_SECTION => LAYOUT_CENTER})
        disable_border
    end 
end

SampleGraphApp.new.show