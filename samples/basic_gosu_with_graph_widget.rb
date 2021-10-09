require 'gosu'
require_relative '../lib/wads'

include Wads
    #
    # The WadsApp class provides a simple starting point to quickly build a native
    # Ruby application using Gosu as an underlying library. It provides all the necessary
    # hooks to get started. All you need to do is supply the parent Wads widget using
    # the set_display(widget) method. See one of the Wads samples for example usage.
    #
    class BasicGosuAppWithGraph < Gosu::Window
        def initialize
            super(800, 600)
            self.caption = 'Basic Gosu App with Graph Widget'
            @font = Gosu::Font.new(22)
            @graph_widget = GraphWidget.new(10, 110,           # x, y coordinate of top left corder
                                            780, 480,          # width x height
                                            create_graph,
                                            GRAPH_DISPLAY_EXPLORER) 
            @update_count = 0
        end 

        def create_graph
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

        def update
            # Calling handle_update on the grpah widget is required if you want interactivity
            # specifically, for drag and drop of the nodes
            @update_count = @update_count + 1
            @graph_widget.handle_update @update_count, mouse_x, mouse_y
        end 
    
        def draw
            @font.draw_text("Sample App with Wads Graph Widget", 240, 49, 1, 1, 1, COLOR_WHITE)
            @graph_widget.draw
        end

        def button_down id
            close if id == Gosu::KbEscape
            # Delegate button events to the graph widget if you want the
            # user to be able to interact with it
            @graph_widget.button_down id, mouse_x, mouse_y
        end
    
        def button_up id
            # Delegate button events to the graph widget if you want the
            # user to be able to interact with it
            @graph_widget.button_up id, mouse_x, mouse_y
        end
    end 


BasicGosuAppWithGraph.new.show
