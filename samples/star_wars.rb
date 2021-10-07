require 'gosu'
require 'json'
require_relative '../lib/wads'

include Wads 

class SampleStarWarsApp < WadsApp
    
    STAR_WARS_DATA_FILE = "./data/starwars-episode-4-interactions.json"

    def initialize
        super(800, 800, "Wads Sample Star Wars App", StarWarsDisplay.new(process_star_wars_data))
    end 

    def process_star_wars_data 
        star_wars_json = File.read(STAR_WARS_DATA_FILE)
        data_hash = JSON.parse(star_wars_json)
        characters = data_hash['nodes']
        interactions = data_hash['links']

        # The interactions in the data set reference the characters by their
        # zero based index, so we keep a reference in our graph by index.
        # The character's value is the number of scenes in which they appear.
        graph = Graph.new
        characters.each do |character|
            node_tags = {}
            node_color_str = character['colour']
            # This is a bit of a hack, but our background is black so black text
            # will not show up. Change this to white
            if node_color_str == "#000000"
                node_color_str = "#FFFFFF"
            end
            # Convert hex string (ex. "#EE00AA") into int hex representation
            # understood by Gosu color (ex. 0xFFEE00AA)
            node_color = "0xFF#{node_color_str[1..-1]}".to_i(16)
            node_tags['color'] = node_color
            graph.add_node(Node.new(character['name'], character['value'], node_tags))
        end
        interactions.each do |interaction| 
            character_one = graph.node_by_index(interaction['source'])
            character_two = graph.node_by_index(interaction['target'])
            number_of_scenes_together = interaction['value']
            edge_tags = {}
            edge_tags["scenes"] = number_of_scenes_together
            graph.add_edge(character_one, character_two, edge_tags)
        end
        graph
    end
end

class StarWarsDisplay < Widget
    attr_accessor :graph

    def initialize(graph)
        super(0, 0, 800, 800)
        set_layout(LAYOUT_TOP_MIDDLE_BOTTOM)
        @graph = graph

        image = get_layout.add_image("./media/Banner.png", { ARG_SECTION => LAYOUT_TOP})
        image.add_text("Wads Sample App", 10, 20, nil, true)
        image.add_text("Version #{Wads::VERSION}", 13, 54)

        get_layout.add_document(sample_content, { ARG_SECTION => LAYOUT_CENTER})

        panel = get_layout.add_horizontal_panel({ ARG_SECTION => LAYOUT_BOTTOM})
        panel.add_button("Exit", 0, panel.height - 30) do
            WidgetResult.new(true)
        end
        panel.center_children
        panel.disable_border

        @data_table = get_layout.add_single_select_table(
            ["Character", "Number of Scenes"], 4, { ARG_SECTION => LAYOUT_CENTER})

        @graph.node_list.each do |character|
            @data_table.add_row([character.name, character.value], character.get_tag(ARG_COLOR))
        end
        @graph_display = get_layout.add_graph_display(@graph, GRAPH_DISPLAY_EXPLORER,
                                                      { ARG_SECTION => LAYOUT_CENTER})

        disable_border
    end

    def sample_content
        <<~HEREDOC
          This sample analysis shows the interactions between characters in the Star Wars
          Episode 4: A New Hope. Click on a character to see more detail.
        HEREDOC
    end

    def handle_key_press id, mouse_x, mouse_y
        if id == Gosu::KbUp
            @data_table.scroll_up
        elsif id == Gosu::KbDown
            @data_table.scroll_down
        end 
        WidgetResult.new(false)
    end

    def handle_mouse_down mouse_x, mouse_y
        if @data_table.contains_click(mouse_x, mouse_y)
            val = @data_table.set_selected_row(mouse_y, 0)
            if not val.nil?
                node = @graph.find_node(val)
                #@graph_display.set_center_node(node, 2)
                @graph_display.set_explorer_display(node)
            end  
        end
    end
end

SampleStarWarsApp.new.show