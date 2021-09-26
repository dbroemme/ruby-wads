require 'singleton'
require 'logger'
require_relative 'data_structures'

module Wads
    COLOR_PEACH = Gosu::Color.argb(0xffe6b0aa)
    COLOR_LIGHT_PURPLE = Gosu::Color.argb(0xffd7bde2)
    COLOR_LIGHT_BLUE = Gosu::Color.argb(0xffa9cce3)
    COLOR_LIGHT_GREEN = Gosu::Color.argb(0xffa3e4d7)
    COLOR_GREEN = COLOR_LIGHT_GREEN
    COLOR_LIGHT_YELLOW = Gosu::Color.argb(0xfff9e79f)
    COLOR_LIGHT_ORANGE = Gosu::Color.argb(0xffedbb99)
    COLOR_WHITE = Gosu::Color::WHITE
    COLOR_OFF_WHITE = Gosu::Color.argb(0xfff8f9f9)
    COLOR_PINK = Gosu::Color.argb(0xffe6b0aa)
    COLOR_LIME = Gosu::Color.argb(0xffDAF7A6)
    COLOR_YELLOW = Gosu::Color.argb(0xffFFC300)
    COLOR_MAROON = Gosu::Color.argb(0xffC70039)
    COLOR_PURPLE = COLOR_MAROON
    COLOR_LIGHT_GRAY = Gosu::Color.argb(0xff2c3e50)
    COLOR_LIGHTER_GRAY = Gosu::Color.argb(0xff364d63)
    COLOR_LIGHTEST_GRAY = Gosu::Color.argb(0xff486684)
    COLOR_GRAY = Gosu::Color::GRAY
    COLOR_OFF_GRAY = Gosu::Color.argb(0xff566573)
    COLOR_LIGHT_BLACK = Gosu::Color.argb(0xff111111)
    COLOR_LIGHT_RED = Gosu::Color.argb(0xffe6b0aa)
    COLOR_CYAN = Gosu::Color::CYAN
    COLOR_AQUA = COLOR_CYAN
    COLOR_HEADER_BLUE = Gosu::Color.argb(0xff089FCE)
    COLOR_HEADER_BRIGHT_BLUE = Gosu::Color.argb(0xff0FAADD)
    COLOR_BLUE = Gosu::Color::BLUE
    COLOR_DARK_GRAY = Gosu::Color.argb(0xccf0f3f4)
    COLOR_RED = Gosu::Color::RED
    COLOR_BLACK = Gosu::Color::BLACK
    COLOR_FORM_BUTTON = Gosu::Color.argb(0xcc2e4053)
    COLOR_ERROR_CODE_RED = Gosu::Color.argb(0xffe6b0aa)
    COLOR_BORDER_BLUE = Gosu::Color.argb(0xff004D80)

    Z_ORDER_BACKGROUND = 2
    Z_ORDER_BORDER = 3
    Z_ORDER_SELECTION_BACKGROUND = 4
    Z_ORDER_GRAPHIC_ELEMENTS = 5
    Z_ORDER_PLOT_POINTS = 6
    Z_ORDER_FOCAL_ELEMENTS = 8
    Z_ORDER_TEXT = 9

    EVENT_OK = "ok"
    EVENT_TEXT_INPUT = "textinput"
    EVENT_TABLE_SELECT = "tableselect"
    EVENT_TABLE_UNSELECT = "tableunselect"
    EVENT_TABLE_ROW_DELETE = "tablerowdelete"

    IMAGE_CIRCLE_SIZE = 104

    ELEMENT_TEXT = "text"
    ELEMENT_BUTTON = "button"
    ELEMENT_IMAGE = "image"
    ELEMENT_TABLE = "table"
    ELEMENT_HORIZONTAL_PANEL = "hpanel"
    ELEMENT_VERTICAL_PANEL = "vpanel"
    ELEMENT_MAX_PANEL = "maxpanel"
    ELEMENT_DOCUMENT = "document"
    ELEMENT_GRAPH = "graph"
    ELEMENT_GENERIC = "generic"
    ELEMENT_PLOT = "plot"

    ARG_SECTION = "section"
    ARG_COLOR = "color"
    ARG_DESIRED_WIDTH = "desired_width"
    ARG_DESIRED_HEIGHT = "desired_height"
    ARG_LAYOUT = "layout"

    LAYOUT_TOP = "north"
    LAYOUT_MIDDLE = "center"
    LAYOUT_BOTTOM = "south"
    LAYOUT_LEFT = "west"
    LAYOUT_RIGHT = "east"
    LAYOUT_NORTH = "north"
    LAYOUT_SOUTH = "south"
    LAYOUT_WEST = "west"
    LAYOUT_EAST = "east"
    LAYOUT_CENTER = "center"

    LAYOUT_VERTICAL_COLUMN = "vcolumn"
    LAYOUT_TOP_MIDDLE_BOTTOM = "top_middle_bottom"
    LAYOUT_HEADER_CONTENT = "header_content"
    LAYOUT_CONTENT_FOOTER = "content_footer"
    LAYOUT_BORDER = "border"
    LAYOUT_EAST_WEST = "east_west"
    LAYOUT_LEFT_RIGHT = LAYOUT_EAST_WEST

    FILL_VERTICAL_STACK = "fill_vertical"
    FILL_HORIZONTAL_STACK = "fill_horizontal"
    FILL_FULL_SIZE = "fill_vertical"


    class Coordinates 
        attr_accessor :x
        attr_accessor :y
        attr_accessor :width
        attr_accessor :height 
        def initialize(x, y, w, h) 
            @x = x 
            @y = y 
            @width = w 
            @height = h 
        end
    end 

    class GuiTheme 
        attr_accessor :text_color
        attr_accessor :graphic_elements_color
        attr_accessor :border_color
        attr_accessor :background_color
        attr_accessor :selection_color
        attr_accessor :use_icons
        attr_accessor :font
        attr_accessor :font_large

        def initialize(text, graphics, border, background, selection, use_icons, font, font_large) 
            @text_color = text 
            @graphic_elements_color = graphics
            @border_color = border 
            @background_color = background 
            @selection_color = selection 
            @use_icons = use_icons
            @font = font
            @font_large = font_large
        end

        def pixel_width_for_string(str)
            @font.text_width(str)
        end
    end

    class WadsConfig 
        include Singleton

        attr_accessor :logger

        def get_logger
            if @logger.nil?
                @logger = Logger.new(STDOUT)
            end 
            @logger 
        end

        # Valid values are 'debug', 'info', 'warn', 'error'
        def set_log_level(level)
            get_logger.level = level
        end
        
        #
        # Themes methods
        #
        def get_default_theme 
            if @default_theme.nil?
                @default_theme = GuiTheme.new(COLOR_WHITE,                # text color
                                              COLOR_HEADER_BRIGHT_BLUE,   # graphic elements
                                              COLOR_BORDER_BLUE,          # border color
                                              COLOR_BLACK,                # background
                                              COLOR_LIGHT_GRAY,           # selected item
                                              true,                       # use icons
                                              Gosu::Font.new(22),         # regular font
                                              Gosu::Font.new(38))         # large font
            end 
            @default_theme
        end

        def current_theme 
            if @current_theme.nil? 
                @current_theme = get_default_theme 
            end 
            @current_theme 
        end 

        def set_current_theme(theme) 
            @current_theme = theme 
        end

        #
        # Layouts
        #
        def default_dimensions(widget_type)
            if @default_dimensions.nil? 
                @default_dimensions = {}
                @default_dimensions[ELEMENT_TEXT] = [100, 20]
                @default_dimensions[ELEMENT_IMAGE] = [100, 100]
                @default_dimensions[ELEMENT_TABLE] = ["max", "max"]
                @default_dimensions[ELEMENT_HORIZONTAL_PANEL] = ["max", 100]
                @default_dimensions[ELEMENT_VERTICAL_PANEL] = [100, "max"]
                @default_dimensions[ELEMENT_MAX_PANEL] = ["max", "max"]
                @default_dimensions[ELEMENT_DOCUMENT] = ["max", "max"]
                @default_dimensions[ELEMENT_GRAPH] = ["max", "max"]
                @default_dimensions[ELEMENT_BUTTON] = [100, 26]
                @default_dimensions[ELEMENT_GENERIC] = ["max", "max"]
                @default_dimensions[ELEMENT_PLOT] = ["max", "max"]
            end
            @default_dimensions[widget_type]
        end
    
        def create_layout_for_widget(widget, layout_type = nil, args = {})
            create_layout(widget.x, widget.y, widget.width, widget.height, widget, layout_type, args)
        end 

        def create_layout(x, y, width, height, widget, layout_type = nil, args = {})
            if layout_type.nil? 
                if @default_layout_type.nil?
                    layout_type = LAYOUT_VERTICAL_COLUMN
                else 
                    layout_type = @default_layout_type 
                end 
            end
 
            if not @default_layout_args.nil?
                if args.nil? 
                    args = @default_layout_args 
                else 
                    args.merge(@default_layout_args)
                end 
            end

            if layout_type == LAYOUT_VERTICAL_COLUMN
                return VerticalColumnLayout.new(x, y, width, height, widget, args)
            elsif layout_type == LAYOUT_TOP_MIDDLE_BOTTOM
                return TopMiddleBottomLayout.new(x, y, width, height, widget, args)
            elsif layout_type == LAYOUT_BORDER
                return BorderLayout.new(x, y, width, height, widget, args)
            elsif layout_type == LAYOUT_HEADER_CONTENT
                return HeaderContentLayout.new(x, y, width, height, widget, args)
            elsif layout_type == LAYOUT_CONTENT_FOOTER
                return ContentFooterLayout.new(x, y, width, height, widget, args)
            elsif layout_type == LAYOUT_EAST_WEST
                return EastWestLayout.new(x, y, width, height, widget, args)
            end
            raise "#{layout_type} is an unsupported layout type" 
        end 
    
        def set_default_layout(layout_type, layout_args = {}) 
            @default_layout_type = layout_type 
            @default_layout_args = layout_args
        end

        #
        # Images methods
        #
        def circle(color)
            create_circles 
            img = @wads_image_circles[color]
            if img.nil?
                get_logger.error("ERROR: Did not find circle image with color #{color}")
            end
            img
        end 

        def create_circles
            return unless @wads_image_circles.nil?
            @wads_image_circle_aqua = Gosu::Image.new("./media/CircleAqua.png")
            @wads_image_circle_blue = Gosu::Image.new("./media/CircleBlue.png")
            @wads_image_circle_green = Gosu::Image.new("./media/CircleGreen.png")
            @wads_image_circle_purple = Gosu::Image.new("./media/CirclePurple.png")
            @wads_image_circle_red = Gosu::Image.new("./media/CircleRed.png")
            @wads_image_circle_yellow = Gosu::Image.new("./media/CircleYellow.png")
            @wads_image_circle_gray = Gosu::Image.new("./media/CircleGray.png")
            @wads_image_circle_white = Gosu::Image.new("./media/CircleWhite.png")
            @wads_image_circles = {}
            @wads_image_circles[COLOR_AQUA] = @wads_image_circle_aqua
            @wads_image_circles[COLOR_BLUE] = @wads_image_circle_blue
            @wads_image_circles[COLOR_GREEN] = @wads_image_circle_green
            @wads_image_circles[COLOR_PURPLE] = @wads_image_circle_purple
            @wads_image_circles[COLOR_RED] = @wads_image_circle_red
            @wads_image_circles[COLOR_YELLOW] = @wads_image_circle_yellow
            @wads_image_circles[COLOR_GRAY] = @wads_image_circle_gray
            @wads_image_circles[COLOR_WHITE] = @wads_image_circle_white
            @wads_image_circles[4294956800] = @wads_image_circle_yellow
            @wads_image_circles[4281893349] = @wads_image_circle_blue
            @wads_image_circles[4294967295] = @wads_image_circle_gray
            @wads_image_circles[4286611584] = @wads_image_circle_gray
            @wads_image_circles[4282962380] = @wads_image_circle_aqua
            @wads_image_circles[4294939648] = @wads_image_circle_red
            @wads_image_circles[4292664540] = @wads_image_circle_white    
        end
    end

    class GuiContainer 
        attr_accessor :start_x
        attr_accessor :start_y
        attr_accessor :next_x
        attr_accessor :next_y
        attr_accessor :max_width 
        attr_accessor :max_height 
        attr_accessor :padding 
        attr_accessor :fill_type 
        attr_accessor :elements

        def initialize(start_x, start_y, width, height, fill_type = FILL_HORIZONTAL_STACK, padding = 5)
            @start_x = start_x
            @start_y = start_y
            @next_x = start_x
            @next_y = start_y
            @max_width = width 
            @max_height = height 
            @padding = padding
            if [FILL_VERTICAL_STACK, FILL_HORIZONTAL_STACK, FILL_FULL_SIZE].include? fill_type
                @fill_type = fill_type 
            else 
                raise "#{fill_type} is not a valid fill type"
            end
            @elements = []
        end 

        def get_coordinates(element_type, args = {})
            # We would need to remember the original start x, y to do this
            # and then compare the next x y with the start x y plus max width or height
            # You would check at the beginning of the method
            #if elem.right_edge > max_width 
            #    raise "Cannot fit next element in container, x value is #{elem.right_edge}"
            #end
            #if elem.bottom_edge > max_height 
            #    raise "Cannot fit next element in container, y value is #{elem.bottom_edge}"
            #end

            default_dim =  WadsConfig.instance.default_dimensions(element_type)
            if default_dim.nil?
                raise "#{element_type} is an undefined element type"
            end
            default_width = default_dim[0]
            default_height = default_dim[1]
            specified_width = args[ARG_DESIRED_WIDTH]
            if specified_width.nil?
                if default_width == "max"
                    if fill_type == FILL_VERTICAL_STACK or fill_type == FILL_FULL_SIZE
                        the_width = max_width
                    else 
                        the_width = (@start_x + @max_width) - @next_x
                    end
                else
                    the_width = default_width 
                end
            else 
                if specified_width > @max_width 
                    the_width = @max_width
                else
                    the_width = specified_width
                end
            end

            specified_height = args[ARG_DESIRED_HEIGHT]
            if specified_height.nil?
                if default_height == "max"
                    if fill_type == FILL_VERTICAL_STACK
                        the_height = (@start_y + @max_height) - @next_y
                    else
                        the_height = max_height
                    end
                else
                    the_height = default_height 
                end
            else
                if specified_height > @max_height
                    the_height = @max_height 
                else
                    the_height = specified_height 
                end
            end

            # Not all elements require padding
            padding_exempt = [ELEMENT_IMAGE, ELEMENT_HORIZONTAL_PANEL,
                ELEMENT_VERTICAL_PANEL, ELEMENT_TABLE, ELEMENT_GENERIC,
                ELEMENT_PLOT, ELEMENT_MAX_PANEL].include? element_type
            if padding_exempt
                # No padding
                width_to_use = the_width
                height_to_use = the_height
                x_to_use = @next_x 
                y_to_use = @next_y
            else
                # Apply padding only if we are the max, i.e. the boundaries
                x_to_use = @next_x + @padding
                y_to_use = @next_y + @padding
                if the_width == @max_width 
                    width_to_use = the_width - (2 * @padding)
                else 
                    width_to_use = the_width
                end 
                if the_height == @max_height
                    height_to_use = the_height - (2 * @padding)
                else 
                    height_to_use = the_height
                end 
            end
            coords = Coordinates.new(x_to_use, y_to_use,
                                     width_to_use, height_to_use)

            if fill_type == FILL_VERTICAL_STACK
                @next_y = @next_y + the_height + (2 * @padding)
            elsif fill_type == FILL_HORIZONTAL_STACK
                @next_x = @next_x + the_width + (2 * @padding)
            end

            @elements << coords
            coords
        end
    end

    # A base class for all layouts
    class WadsLayout 
        attr_accessor :border_coords
        attr_accessor :parent_widget
        attr_accessor :args

        def initialize(x, y, width, height, parent_widget, args = {})
            @border_coords = Coordinates.new(x, y, width, height)
            @parent_widget = parent_widget
            @args = args
        end

        def get_coordinates(element_type, args = {})
            raise "You must use a subclass of WadsLayout"
        end

        def add_widget(widget, args = {})
            # The widget already has an x, y position, so we need to move it
            # based on the layout
            coordinates = get_coordinates(ELEMENT_GENERIC, args)
            widget.move_recursive_absolute(coordinates.x, coordinates.y)
            widget.base_z = @parent_widget.base_z
            @parent_widget.add_child(widget)
            widget
        end

        def add_text(message, args = {})
            default_dimensions = WadsConfig.instance.default_dimensions(ELEMENT_TEXT)
            text_width = WadsConfig.instance.current_theme.pixel_width_for_string(message)
            coordinates = get_coordinates(ELEMENT_TEXT,
                { ARG_DESIRED_WIDTH => text_width,
                  ARG_DESIRED_HEIGHT => default_dimensions[1]}.merge(args))
            new_text = Text.new(coordinates.x, coordinates.y, message, args[ARG_COLOR])
            new_text.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_text)
            new_text
        end 

        def add_image(filename, args = {})
            img = Gosu::Image.new(filename)
            coordinates = get_coordinates(ELEMENT_IMAGE,
                { ARG_DESIRED_WIDTH => img.width,
                  ARG_DESIRED_HEIGHT => img.height}.merge(args))
            new_image = ImageWidget.new(coordinates.x, coordinates.y, img)
            new_image.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_image)
            new_image
        end

        def add_button(label, args = {}, &block)
            text_width = WadsConfig.instance.current_theme.pixel_width_for_string(label) + 20
            coordinates = get_coordinates(ELEMENT_BUTTON,
                { ARG_DESIRED_WIDTH => text_width,}.merge(args))
            new_button = Button.new(coordinates.x, coordinates.y, label, coordinates.width)
            new_button.set_action(&block)
            new_button.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_button)
            new_button
        end

        def add_plot(args = {})
            coordinates = get_coordinates(ELEMENT_PLOT, args)
            new_plot = Plot.new(coordinates.x, coordinates.y,
                                coordinates.width, coordinates.height) 
            new_plot.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_plot)
            new_plot
        end

        def add_document(content, args = {})
            number_of_content_lines = content.lines.count
            height = (number_of_content_lines * 26) + 4
            coordinates = get_coordinates(ELEMENT_DOCUMENT,
                { ARG_DESIRED_HEIGHT => height}.merge(args))
            new_doc = Document.new(coordinates.x, coordinates.y,
                                   coordinates.width, coordinates.height,
                                   content)
            new_doc.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_doc)
            new_doc
        end

        def add_graph_display(graph, args = {})
            coordinates = get_coordinates(ELEMENT_GRAPH, args)
            new_graph = GraphWidget.new(coordinates.x, coordinates.y,
                                        coordinates.width, coordinates.height,
                                        graph) 
            new_graph.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_graph)
            new_graph
        end

        def add_single_select_table(column_headers, visible_rows, args = {})
            calculated_height = 30 + (visible_rows * 30)
            coordinates = get_coordinates(ELEMENT_TABLE,
                { ARG_DESIRED_HEIGHT => calculated_height}.merge(args))
            new_table = SingleSelectTable.new(coordinates.x, coordinates.y,
                                              coordinates.width, coordinates.height,
                                              column_headers, visible_rows)
            new_table.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_table)
            new_table
        end 

        def add_multi_select_table(column_headers, visible_rows, args = {})
            calculated_height = 30 + (visible_rows * 30)
            coordinates = get_coordinates(ELEMENT_TABLE,
                { ARG_DESIRED_HEIGHT => calculated_height}.merge(args))
            new_table = MultiSelectTable.new(coordinates.x, coordinates.y,
                                             coordinates.width, coordinates.height,
                                             column_headers, visible_rows)
            new_table.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_table)
            new_table
        end 

        def add_table(column_headers, visible_rows, args = {})
            calculated_height = 30 + (visible_rows * 30)
            coordinates = get_coordinates(ELEMENT_TABLE,
                { ARG_DESIRED_HEIGHT => calculated_height}.merge(args))
            new_table = Table.new(coordinates.x, coordinates.y,
                                coordinates.width, coordinates.height,
                                column_headers, visible_rows)
            new_table.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_table)
            new_table
        end 

        def add_horizontal_panel(args = {})
            internal_add_panel(ELEMENT_HORIZONTAL_PANEL, args)
        end 

        def add_vertical_panel(args = {})
            internal_add_panel(ELEMENT_VERTICAL_PANEL, args)
        end 

        def internal_add_panel(orientation, args)
            coordinates = get_coordinates(orientation, args)
            new_panel = Panel.new(coordinates.x, coordinates.y,
                                  coordinates.width, coordinates.height)
            new_panel.set_layout(LAYOUT_VERTICAL_COLUMN, args)
            new_panel.base_z = @parent_widget.base_z
            @parent_widget.add_child(new_panel)
            new_panel
        end
    end 

    class VerticalColumnLayout < WadsLayout
        attr_accessor :single_column_container

        def initialize(x, y, width, height, parent_widget, args = {})
            super
            @single_column_container = GuiContainer.new(x, y, width, height, FILL_VERTICAL_STACK)
        end

        # This is the standard interface for layouts
        def get_coordinates(element_type, args = {})
            @single_column_container.get_coordinates(element_type, args)
        end
    end 

    class SectionLayout < WadsLayout
        attr_accessor :container_map

        def initialize(x, y, width, height, parent_widget, args = {})
            super
            @container_map = {}
        end

        def get_coordinates(element_type, args = {})
            section = args[ARG_SECTION]
            if section.nil?
                raise "Layout addition requires the arg '#{ARG_SECTION}' with value #{@container_map.keys.join(', ')}"
            end
            container = @container_map[section]
            if container.nil? 
                raise "Invalid section #{section}. Value values are #{@container_map.keys.join(', ')}"
            end
            container.get_coordinates(element_type, args)
        end

        def add_east_west_panel(args)
            section = args[ARG_SECTION]
            if section.nil?
                raise "East west panels require the arg '#{ARG_SECTION}' with value #{@container_map.keys.join(', ')}"
            end
            container = @container_map[section]
            new_panel = Panel.new(container.start_x, container.start_y,
                                  container.max_width, container.max_height)
            new_panel.set_layout(LAYOUT_EAST_WEST, args)
            new_panel.base_z = @parent_widget.base_z
            new_panel.disable_border
            @parent_widget.add_child(new_panel)
            new_panel
        end
    end 

    class HeaderContentLayout < SectionLayout
        def initialize(x, y, width, height, parent_widget, args = {})
            super
            #   +-------------------------------------------------+
            #   +                  LAYOUT_NORTH                   +
            #   +-------------------------------------------------+
            #   +                                                 +
            #   +                  LAYOUT_CENTER                  +
            #   +                                                 +
            #   +-------------------------------------------------+

            # Divide the height into 100, 100, and the middle gets everything else
            # Right now we are using 100 pixels rather than a percentage for the borders
            middle_section_y_start = y + 100
            height_middle_section = height - 100
            @container_map[LAYOUT_NORTH] = GuiContainer.new(x, y, width, 100)
            @container_map[LAYOUT_CENTER] = GuiContainer.new(x, middle_section_y_start, width, height_middle_section, FILL_VERTICAL_STACK)
        end
    end 

    class ContentFooterLayout < SectionLayout
        def initialize(x, y, width, height, parent_widget, args = {})
            super
            #   +-------------------------------------------------+
            #   +                                                 +
            #   +                  LAYOUT_CENTER                  +
            #   +                                                 +
            #   +-------------------------------------------------+
            #   +                  LAYOUT_SOUTH                   +
            #   +-------------------------------------------------+
            #
            # Divide the height into 100, 100, and the middle gets everything else
            # Right now we are using 100 pixels rather than a percentage for the borders
            bottom_section_height = 100
            if args[ARG_DESIRED_HEIGHT]
                bottom_section_height = args[ARG_DESIRED_HEIGHT]
            end
            bottom_section_y_start = y + height - bottom_section_height
            middle_section_height = height - bottom_section_height
            @container_map[LAYOUT_CENTER] = GuiContainer.new(x, y, width, middle_section_height, FILL_VERTICAL_STACK)
            @container_map[LAYOUT_SOUTH] = GuiContainer.new(x, bottom_section_y_start,
                                                            width, bottom_section_height)
        end
    end 

    class EastWestLayout < SectionLayout
        def initialize(x, y, width, height, parent_widget, args = {})
            super
            #   +-------------------------------------------------+
            #   +                        |                        +
            #   +     LAYOUT_WEST        |     LAYOUT_EAST        +
            #   +                        |                        +
            #   +-------------------------------------------------+
            #
            west_section_width = width / 2
            if args[ARG_DESIRED_WIDTH]
                west_section_width = args[ARG_DESIRED_WIDTH]
            end
            east_section_width = width - west_section_width
            @container_map[LAYOUT_WEST] = GuiContainer.new(x, y,
                                                           west_section_width, height,
                                                           FILL_FULL_SIZE)
            @container_map[LAYOUT_EAST] = GuiContainer.new(x + west_section_width, y,
                                                           east_section_width, height,
                                                           FILL_FULL_SIZE)
        end
    end 




    class TopMiddleBottomLayout < SectionLayout
        def initialize(x, y, width, height, parent_widget, args = {})
            super
            #   +-------------------------------------------------+
            #   +                  LAYOUT_NORTH                   +
            #   +-------------------------------------------------+
            #   +                                                 +
            #   +                  LAYOUT_CENTER                  +
            #   +                                                 +
            #   +-------------------------------------------------+
            #   +                  LAYOUT_SOUTH                   +
            #   +-------------------------------------------------+

            # Divide the height into 100, 100, and the middle gets everything else
            # Right now we are using 100 pixels rather than a percentage for the borders
            middle_section_y_start = y + 100
            bottom_section_y_start = y + height - 100
            height_middle_section = height - 200
            @container_map[LAYOUT_NORTH] = GuiContainer.new(x, y, width, 100)
            @container_map[LAYOUT_CENTER] = GuiContainer.new(x, middle_section_y_start,
                                                             width, height_middle_section, FILL_VERTICAL_STACK)
            @container_map[LAYOUT_SOUTH] = GuiContainer.new(x, bottom_section_y_start, width, 100)
        end
    end 

    class BorderLayout < SectionLayout
        def initialize(x, y, width, height, parent_widget, args = {})
            super
            #   +-------------------------------------------------+
            #   +                  LAYOUT_NORTH                   +
            #   +-------------------------------------------------+
            #   +             |                     |             +
            #   + LAYOUT_WEST |    LAYOUT_CENTER    | LAYOUT_EAST +
            #   +             |                     |             +
            #   +-------------------------------------------------+
            #   +                  LAYOUT_SOUTH                   +
            #   +-------------------------------------------------+
            #
            # Divide the height into 100, 100, and the middle gets everything else
            # Right now we are using 100 pixels rather than a percentage for the borders
            middle_section_y_start = y + 100
            bottom_section_y_start = y + height - 100

            height_middle_section = bottom_section_y_start - middle_section_y_start

            middle_section_x_start = x + 100
            right_section_x_start = x + width - 100
            width_middle_section = right_section_x_start - middle_section_x_start

            @container_map[LAYOUT_NORTH] = GuiContainer.new(x, y, width, 100)
            @container_map[LAYOUT_WEST] = GuiContainer.new(
                x, middle_section_y_start, 100, height_middle_section, FILL_VERTICAL_STACK)
            @container_map[LAYOUT_CENTER] = GuiContainer.new(
                                   middle_section_x_start,
                                   middle_section_y_start,
                                   width_middle_section,
                                   height_middle_section,
                                   FILL_VERTICAL_STACK)
            @container_map[LAYOUT_EAST] = GuiContainer.new(
                                   right_section_x_start,
                                   middle_section_y_start,
                                   100,
                                   height_middle_section,
                                   FILL_VERTICAL_STACK)
            @container_map[LAYOUT_SOUTH] = GuiContainer.new(x, bottom_section_y_start, width, 100)
        end
    end 

    class Widget 
        attr_accessor :x
        attr_accessor :y 
        attr_accessor :base_z 
        attr_accessor :gui_theme 
        attr_accessor :layout 
        attr_accessor :width
        attr_accessor :height 
        attr_accessor :visible 
        attr_accessor :children
        attr_accessor :overlay_widget
        attr_accessor :override_color
        attr_accessor :is_selected

        def initialize(x, y, width = 10, height = 10, layout = nil) 
            set_absolute_position(x, y)  
            set_dimensions(width, height)
            @base_z = 0
            if uses_layout
                if layout.nil? 
                    @layout = WadsConfig.instance.create_layout(x, y, width, height, self)
                else
                    @layout = layout
                end
            end
            @gui_theme = WadsConfig.instance.current_theme
            @visible = true 
            @children = []
            @show_background = true
            @show_border = true 
            @is_selected = false
        end

        def debug(message)
            WadsConfig.instance.get_logger.debug message 
        end
        def info(message)
            WadsConfig.instance.get_logger.info message 
        end
        def warn(message)
            WadsConfig.instance.get_logger.warn message 
        end
        def error(message)
            WadsConfig.instance.get_logger.error message 
        end

        def set_absolute_position(x, y) 
            @x = x 
            @y = y 
        end 

        def set_dimensions(width, height)
            @width = width
            @height = height 
        end

        def uses_layout
            true 
        end

        def get_layout 
            if not uses_layout 
                raise "The widget #{self.class.name} does not support layouts"
            end
            if @layout.nil? 
                raise "No layout was defined for #{self.class.name}"
            end 
            @layout 
        end 

        def set_layout(layout_type, args = {})
            @layout = WadsConfig.instance.create_layout_for_widget(self, layout_type, args)
        end

        def get_theme 
            @gui_theme
        end

        def set_selected 
            @is_selected = true
        end 

        def unset_selected 
            @is_selected = false
        end 

        def graphics_color 
            if @override_color 
                return @override_color 
            end 
            @gui_theme.graphic_elements_color 
        end 

        def text_color 
            if @override_color 
                return @override_color 
            end 
            @gui_theme.text_color 
        end 

        def z_order 
            @base_z + widget_z
        end

        def relative_z_order(relative_order)
            @base_z + relative_order 
        end

        def add(child) 
            add_child(child)
        end 

        def add_child(child) 
            @children << child 
        end

        def remove_child(child)
            @children.delete(child)
        end

        def remove_children(list)
            list.each do |child|
                @children.delete(child)
            end
        end 

        def remove_children_by_type(class_name_token)
            children_to_remove = []
            @children.each do |child|
                if child.class.name.include? class_name_token 
                    children_to_remove << child 
                end 
            end 
            children_to_remove.each do |child|
                @children.delete(child)
            end
        end

        def clear_children 
            @children = [] 
        end

        def disable_background
            @show_background = false
        end

        def disable_border
            @show_border = false 
        end

        def right_edge
            @x + @width - 1
        end
        
        def bottom_edge
            @y + @height - 1
        end

        def center_x
            @x + ((right_edge - @x) / 2)
        end 

        def center_y
            @y + ((bottom_edge - @y) / 2)
        end 

        def move_recursive_absolute(new_x, new_y)
            delta_x = new_x - @x 
            delta_y = new_y - @y
            move_recursive_delta(delta_x, delta_y)
        end

        def move_recursive_delta(delta_x, delta_y)
            @x = @x + delta_x
            @y = @y + delta_y
            @children.each do |child| 
                child.move_recursive_delta(delta_x, delta_y) 
            end 
        end

        def draw 
            if @visible 
                render
                if @is_selected
                    draw_background(Z_ORDER_SELECTION_BACKGROUND, @gui_theme.selection_color)
                elsif @show_background
                    draw_background
                end
                if @show_border
                    draw_border
                end
                @children.each do |child| 
                    child.draw 
                end 
            end 
        end

        def draw_background(z_override = nil, color_override = nil)
            if color_override.nil? 
                bgcolor = @gui_theme.background_color
            else 
                bgcolor = color_override
            end
            if z_override 
                z = relative_z_order(z_override)
            else 
                z = relative_z_order(Z_ORDER_BACKGROUND) 
            end
            Gosu::draw_rect(@x + 1, @y + 1, @width - 3, @height - 3, bgcolor, z) 
        end

        #def draw_shadow(color)
        #    Gosu::draw_line @x - 1, @y - 1, color, right_edge - 1, @y - 1, color, relative_z_order(Z_ORDER_BORDER)
        #    Gosu::draw_line @x - 1, @y - 1, color, @x - 1, bottom_edge - 1, color, relative_z_order(Z_ORDER_BORDER)
        #end

        def draw_border
            Gosu::draw_line @x, @y, @gui_theme.border_color, right_edge, @y, @gui_theme.border_color, relative_z_order(Z_ORDER_BORDER)
            Gosu::draw_line @x, @y, @gui_theme.border_color, @x, bottom_edge, @gui_theme.border_color, relative_z_order(Z_ORDER_BORDER)
            Gosu::draw_line @x,bottom_edge, @gui_theme.border_color, right_edge, bottom_edge, @gui_theme.border_color, relative_z_order(Z_ORDER_BORDER)
            Gosu::draw_line right_edge, @y, @gui_theme.border_color, right_edge, bottom_edge, @gui_theme.border_color, relative_z_order(Z_ORDER_BORDER)
        end

        def contains_click(mouse_x, mouse_y)
            mouse_x >= @x and mouse_x <= right_edge and mouse_y >= @y and mouse_y <= bottom_edge
        end

        def overlaps_with(other_widget)
            if other_widget.contains_click(@x, @y)
                return true 
            end 
            if other_widget.contains_click(right_edge, @y)
                return true 
            end 
            if other_widget.contains_click(right_edge, bottom_edge - 1)
                return true 
            end 
            if other_widget.contains_click(@x, bottom_edge - 1)
                return true 
            end 
            if other_widget.contains_click(center_x, center_y)
                return true 
            end 
            return false
        end


        def update(update_count, mouse_x, mouse_y)
            if @overlay_widget 
                @overlay_widget.update(update_count, mouse_x, mouse_y)
            end
            handle_update(update_count, mouse_x, mouse_y) 
            @children.each do |child| 
                child.update(update_count, mouse_x, mouse_y) 
            end 
        end

        def button_down(id, mouse_x, mouse_y)
            if @overlay_widget 
                result = @overlay_widget.button_down(id, mouse_x, mouse_y)
                if not result.nil? and result.is_a? WidgetResult
                    intercept_widget_event(result)
                    if result.close_widget
                        # remove the overlay widget frmo children, set to null
                        # hopefully this closes and gets us back to normal
                        remove_child(@overlay_widget)
                        @overlay_widget = nil
                    end
                end
                return
            end

            if id == Gosu::MsLeft
                result = handle_mouse_down mouse_x, mouse_y
            elsif id == Gosu::MsRight
                result = handle_right_mouse mouse_x, mouse_y
            else 
                result = handle_key_press id, mouse_x, mouse_y
            end

            if not result.nil? and result.is_a? WidgetResult
                return result 
            end

            @children.each do |child| 
                if id == Gosu::MsLeft
                    if child.contains_click(mouse_x, mouse_y) 
                        result = child.button_down id, mouse_x, mouse_y
                        if not result.nil? and result.is_a? WidgetResult
                            intercept_widget_event(result)
                            return result 
                        end
                    end 
                else 
                    result = child.button_down id, mouse_x, mouse_y
                    if not result.nil? and result.is_a? WidgetResult
                        intercept_widget_event(result)
                        return result 
                    end
                end
            end 
        end

        def button_up(id, mouse_x, mouse_y)
            if @overlay_widget 
                return @overlay_widget.button_up(id, mouse_x, mouse_y)
            end
            
            if id == Gosu::MsLeft
                result = handle_mouse_up mouse_x, mouse_y
                if not result.nil? and result.is_a? WidgetResult
                    return result 
                end
            end

            @children.each do |child| 
                if id == Gosu::MsLeft
                    if child.contains_click(mouse_x, mouse_y) 
                        result = child.handle_mouse_up mouse_x, mouse_y
                        if not result.nil? and result.is_a? WidgetResult
                            return result 
                        end
                    end 
                end
            end
        end

        def relative_x(x)
            x_pixel_to_screen(x)
        end 

        def x_pixel_to_screen(x)
            @x + x
        end

        def relative_y(y)
            y_pixel_to_screen(y)
        end 

        def y_pixel_to_screen(y)
            @y + y
        end

        #
        # Relative positioning methods
        #
        def add_text(message, rel_x, rel_y, color = nil, use_large_font = false)
            new_text = Text.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), message, color, use_large_font)
            new_text.base_z = @base_z
            add_child(new_text)
            new_text
        end 

        def add_document(content, rel_x, rel_y, width, height)
            new_doc = Document.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y),
                                   width, height,
                                   content)
            new_doc.base_z = @base_z
            add_child(new_doc)
            new_doc
        end

        def add_button(label, rel_x, rel_y, width = nil, &block)
            new_button = Button.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), label)
            if width.nil?
                width = 60
            end
            new_button.width = width
            new_button.set_action(&block)
            new_button.base_z = @base_z
            add_child(new_button)
            new_button
        end

        def add_delete_button(rel_x, rel_y, &block)
            new_delete_button = DeleteButton.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y))
            new_delete_button.set_action(&block)
            new_delete_button.base_z = @base_z
            add_child(new_delete_button)
            new_delete_button 
        end

        def add_table(rel_x, rel_y, width, height, column_headers, max_visible_rows = 10)
            new_table = Table.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y),
                              width, height, column_headers, max_visible_rows)
            new_table.base_z = @base_z
            add_child(new_table)
            new_table
        end 

        def add_single_select_table(rel_x, rel_y, width, height, column_headers, max_visible_rows = 10)
            new_table = SingleSelectTable.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y),
                              width, height, column_headers, max_visible_rows)
            new_table.base_z = @base_z
            add_child(new_table)
            new_table
        end 

        def add_multi_select_table(rel_x, rel_y, width, height, column_headers, max_visible_rows = 10)
            new_table = MultiSelectTable.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y),
                              width, height, column_headers, max_visible_rows)
            new_table.base_z = @base_z
            add_child(new_table)
            new_table
        end 

        def add_graph_display(rel_x, rel_y, width, height, graph)
            new_graph = GraphWidget.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), width, height, graph) 
            new_graph.base_z = @base_z
            add_child(new_graph)
            new_graph
        end

        def add_plot(rel_x, rel_y, width, height)
            new_plot = Plot.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), width, height) 
            new_plot.base_z = @base_z
            add_child(new_plot)
            new_plot
        end

        def add_axis_lines(rel_x, rel_y, width, height)
            new_axis_lines = AxisLines.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), width, height) 
            new_axis_lines.base_z = @base_z
            add_child(new_axis_lines)
            new_axis_lines
        end

        def add_image(filename, rel_x, rel_y)
            new_image = ImageWidget.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), img)
            new_image.base_z = @base_z
            add_child(new_image)
            new_image
        end

        def add_overlay(overlay)
            overlay.base_z = @base_z + 10
            add_child(overlay)
            @overlay_widget = overlay
        end

        def center_children
            # For all child widgets, adjust the x coordinate
            # so that they are centered
            if @children.empty?
                return 
            end
            number_of_children = @children.size 
            total_width_of_children = 0
            @children.each do |child|
                total_width_of_children = total_width_of_children + child.width + 5
            end
            total_width_of_children = total_width_of_children - 5

            start_x = (@width - total_width_of_children) / 2
            @children.each do |child|
                child.x = start_x 
                start_x = start_x + child.width + 5
            end
        end

        #
        # Callbacks for subclasses to override
        #
        def handle_mouse_down mouse_x, mouse_y
            # empty base implementation
        end

        def handle_mouse_up mouse_x, mouse_y
            # empty base implementation
        end

        def handle_right_mouse mouse_x, mouse_y
            # empty base implementation
        end

        def handle_key_press id, mouse_x, mouse_y
            # empty base implementation
        end

        def handle_update update_count, mouse_x, mouse_y
            # empty base implementation
        end

        def render 
            # Base implementation is empty
            # Note that the draw method invoked by clients stills renders any added children
            # render is for specific drawing done by the widget
        end 

        def widget_z 
            # The relative z order compared to other widgets
            # The absolute z order is the base plus this value.
            # Its calculated relative so that overlay widgets can be 
            # on top of base displays.
            0
        end

        def intercept_widget_event(result)
            # Base implementation just relays the event
            result
        end
    end 

    class Panel < Widget
        def initialize(x, y, w, h, layout = nil) 
            super(x, y, w, h, layout)
        end
    end 

    class ImageWidget < Widget
        attr_accessor :img 
        attr_accessor :scale

        def initialize(x, y, image) 
            super(x, y)
            if image.is_a? String
                @img = Gosu::Image.new(image)
            elsif image.is_a? Gosu::Image 
                @img = image 
            else 
                raise "ImageWidget requires either a filename or a Gosu::Image object"
            end
            @scale = 1
            disable_border
            disable_background
            set_dimensions(@img.width, @img.height)
        end

        def render 
            @img.draw @x, @y, z_order, @scale, @scale
        end

        def widget_z 
            Z_ORDER_FOCAL_ELEMENTS
        end
    end 

    class Text < Widget
        attr_accessor :label

        def initialize(x, y, label, color = nil, use_large_font = false) 
            super(x, y) 
            @label = label
            @use_large_font = use_large_font
            @override_color = color
            disable_border
            if @use_large_font 
                set_dimensions(@gui_theme.font_large.text_width(@label) + 10, 20)
            else 
                set_dimensions(@gui_theme.font.text_width(@label) + 10, 20)
            end
        end

        def set_text(new_text)
            @label = new_text
        end

        def change_text(new_text)
            set_text(new_text)
        end

        def render 
            if @use_large_font 
                get_theme.font_large.draw_text(@label, @x, @y, z_order, 1, 1, text_color)
            else
                get_theme.font.draw_text(@label, @x, @y, z_order, 1, 1, text_color)
            end 
        end

        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    class ErrorMessage < Text
        def initialize(x, y, message) 
            super(x, y, "ERROR: #{message}", COLOR_ERROR_CODE_RED)
        end
    end 

    class PlotPoint < Widget
        attr_accessor :data_x
        attr_accessor :data_y
        attr_accessor :data_point_size 

        def initialize(x, y, data_x, data_y, color = COLOR_MAROON, size = 4) 
            super(x, y)
            @override_color = color
            @data_x = data_x
            @data_y = data_y
            @data_point_size = size
        end

        def render(override_size = nil)
            size_to_draw = @data_point_size
            if override_size 
                size_to_draw = override_size 
            end
            half_size = size_to_draw / 2
            Gosu::draw_rect(@x - half_size, @y - half_size,
                            size_to_draw, size_to_draw,
                            graphics_color, z_order) 
        end 

        def widget_z 
            Z_ORDER_PLOT_POINTS
        end

        def to_display 
            "#{@x}, #{@y}"
        end

        def increase_size 
            @data_point_size = @data_point_size + 2
        end 

        def decrease_size 
            if @data_point_size > 2
                @data_point_size = @data_point_size - 2
            end
        end
    end 

    class Button < Widget
        attr_accessor :label
        attr_accessor :is_pressed
        attr_accessor :action_code

        def initialize(x, y, label, width = nil) 
            super(x, y) 
            @label = label
            @text_pixel_width = @gui_theme.font.text_width(@label)
            if width.nil?
                @width = @text_pixel_width + 10
            else 
                @width = width 
            end
            @height = 26
            @is_pressed = false
            @is_pressed_update_count = -100
        end

        def render 
            text_x = center_x - (@text_pixel_width / 2)
            @gui_theme.font.draw_text(@label, text_x, @y, z_order, 1, 1, text_color)
        end 

        def widget_z 
            Z_ORDER_TEXT
        end

        def set_action(&block) 
            @action_code = block
        end

        def handle_mouse_down mouse_x, mouse_y
            @is_pressed = true
            if @action_code
                @action_code.call
            end
        end

        def handle_update update_count, mouse_x, mouse_y
            if @is_pressed
                @is_pressed_update_count = update_count
                @is_pressed = false
            end

            if update_count < @is_pressed_update_count + 15
                unset_selected
            elsif contains_click(mouse_x, mouse_y)
                set_selected
            else 
                unset_selected
            end
        end
    end 

    class DeleteButton < Button
        def initialize(x, y) 
            super(x, y, "ignore", 50)
            set_dimensions(14, 14)
            add_child(Line.new(@x, @y, right_edge, bottom_edge, COLOR_ERROR_CODE_RED))
            add_child(Line.new(@x, bottom_edge, right_edge, @y, COLOR_ERROR_CODE_RED))
        end

        def render 
            # do nothing, just override the parent so we don't draw a label
        end 
    end 

    class Document < Widget
        attr_accessor :lines

        def initialize(x, y, width, height, content) 
            super(x, y)
            set_dimensions(width, height)
            @lines = content.split("\n")
            disable_border
        end

        def render 
            y = @y + 4
            @lines.each do |line|
                @gui_theme.font.draw_text(line, @x + 5, y, z_order, 1, 1, COLOR_WHITE)
                y = y + 26
            end
        end 

        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    class InfoBox < Widget 
        def initialize(x, y, width, height, title, content) 
            super(x, y) 
            set_dimensions(width, height)
            @base_z = 10
            add_text(title, 5, 5)
            add_document(content, 5, 52, width, height - 52)
            ok_button = add_button("OK", (@width / 2) - 50, height - 26) do
                WidgetResult.new(true)
            end
            ok_button.width = 100
        end

        def handle_key_press id, mouse_x, mouse_y
            if id == Gosu::KbEscape
                return WidgetResult.new(true) 
            end
        end 
    end

    class Dialog < Widget
        attr_accessor :textinput

        def initialize(x, y, width, height, window, title, text_input_default) 
            super(x, y, width, height) 
            @window = window
            @base_z = 10
            @error_message = nil

            add_text(title, 5, 5)
            # Forms automatically have some explanatory content
            add_document(content, 0, 56, width, height)

            # Forms automatically get a text input widget
            @textinput = TextField.new(@window, @gui_theme.font, x + 10, bottom_edge - 80, text_input_default, 600)
            @textinput.base_z = 10
            add_child(@textinput)

            # Forms automatically get OK and Cancel buttons
            ok_button = add_button("OK", (@width / 2) - 100, height - 32) do
                handle_ok
            end
            ok_button.width = 100

            cancel_button = add_button("Cancel", (@width / 2) + 50, height - 32) do
                WidgetResult.new(true)
            end
            cancel_button.width = 100
        end

        def content 
            <<~HEREDOC
            Override the content method to
            put your info here.
            HEREDOC
        end

        def add_error_message(msg) 
            @error_message = ErrorMessage.new(x + 10, bottom_edge - 120, msg)
            @error_message.base_z = @base_z
        end 

        def render 
            if @error_message
                @error_message.draw 
            end 
        end

        def handle_ok
            # Default behavior is to do nothing except tell the caller to 
            # close the dialog
            return WidgetResult.new(true, EVENT_OK) 
        end

        def handle_mouse_click(mouse_x, mouse_y)
            # empty implementation of mouse click outside
            # of standard form elements in this dialog
        end

        def handle_mouse_down mouse_x, mouse_y
            # Mouse click: Select text field based on mouse position.
            @window.text_input = [@textinput].find { |tf| tf.under_point?(mouse_x, mouse_y) }
            # Advanced: Move caret to clicked position
            @window.text_input.move_caret(mouse_x) unless @window.text_input.nil?

            handle_mouse_click(mouse_x, mouse_y)
        end 

        def handle_key_press id, mouse_x, mouse_y
            if id == Gosu::KbEscape
                return WidgetResult.new(true) 
            end
        end
    end 

    class WidgetResult 
        attr_accessor :close_widget
        attr_accessor :action
        attr_accessor :form_data

        def initialize(close_widget = false, action = "none", form_data = nil)
            @close_widget = close_widget 
            @action = action 
            @form_data = form_data
        end
    end

    class Line < Widget
        attr_accessor :x2
        attr_accessor :y2

        def initialize(x, y, x2, y2, color = nil) 
            super(x, y)
            @override_color = color
            @x2 = x2 
            @y2 = y2
            disable_border
            disable_background
        end

        def render
            Gosu::draw_line x, y, graphics_color, x2, y2, graphics_color, z_order
        end

        def widget_z 
            Z_ORDER_GRAPHIC_ELEMENTS
        end

        def uses_layout
            false 
        end
    end 

    class AxisLines < Widget
        def initialize(x, y, width, height, color = nil) 
            super(x, y)
            set_dimensions(width, height)
            disable_border
            disable_background
        end

        def render
            add_child(Line.new(@x, @y, @x, bottom_edge, graphics_color))
            add_child(Line.new(@x, bottom_edge, right_edge, bottom_edge, graphics_color))
        end

        def uses_layout
            false 
        end
    end

    class VerticalAxisLabel < Widget
        attr_accessor :label

        def initialize(x, y, label, color = nil) 
            super(x, y)
            @label = label 
            @override_color = color
            text_pixel_width = @gui_theme.font.text_width(@label)
            add_text(@label, -text_pixel_width - 28, -12)
            disable_border
            disable_background
        end

        def render
            Gosu::draw_line @x - 20, @y, graphics_color,
                            @x, @y, graphics_color, z_order
        end

        def widget_z 
            Z_ORDER_GRAPHIC_ELEMENTS
        end

        def uses_layout
            false 
        end
    end 

    class HorizontalAxisLabel < Widget
        attr_accessor :label

        def initialize(x, y, label, color = nil) 
            super(x, y)
            @label = label 
            @override_color = color
            text_pixel_width = @gui_theme.font.text_width(@label)
            add_text(@label, -(text_pixel_width / 2), 26)
            disable_border
            disable_background
        end

        def render
            Gosu::draw_line @x, @y, graphics_color, @x, @y + 20, graphics_color, z_order
        end

        def widget_z 
            Z_ORDER_TEXT
        end

        def uses_layout
            false 
        end
    end 

    class Table < Widget
        attr_accessor :data_rows 
        attr_accessor :row_colors
        attr_accessor :headers
        attr_accessor :max_visible_rows
        attr_accessor :current_row
        attr_accessor :can_delete_rows

        def initialize(x, y, width, height, headers, max_visible_rows = 10) 
            super(x, y)
            set_dimensions(width, height)
            @headers = headers
            @current_row = 0
            @max_visible_rows = max_visible_rows
            clear_rows
            @can_delete_rows = false
            @delete_buttons = []
            @next_delete_button_y = 38
        end

        def scroll_up 
            if @current_row > 0
                @current_row = @current_row - @max_visible_rows 
            end 
        end 

        def scroll_down
            if @current_row + @max_visible_rows < @data_rows.size
                @current_row = @current_row + @max_visible_rows 
            end 
        end 

        def clear_rows 
            @data_rows = []
            @row_colors = []
        end 

        def add_row(data_row, color = text_color )
            @data_rows << data_row
            @row_colors << color
        end

        def add_table_delete_button 
            if @delete_buttons.size < @max_visible_rows
                new_button = add_delete_button(@width - 18, @next_delete_button_y) do
                    # nothing to do here, handled in parent widget by event
                end
                @delete_buttons << new_button
                @next_delete_button_y = @next_delete_button_y + 30
            end
        end

        def remove_table_delete_button 
            if not @delete_buttons.empty?
                @delete_buttons.pop
                @children.pop
                @next_delete_button_y = @next_delete_button_y - 30
            end
        end

        def handle_update update_count, mouse_x, mouse_y
            # How many visible data rows are there
            if @can_delete_rows
                number_of_visible_rows = @data_rows.size - @current_row
                if number_of_visible_rows > @max_visible_rows
                    number_of_visible_rows = @max_visible_rows
                end
                if number_of_visible_rows > @delete_buttons.size
                    number_to_add = number_of_visible_rows - @delete_buttons.size 
                    number_to_add.times do 
                        add_table_delete_button 
                    end 
                elsif number_of_visible_rows < @delete_buttons.size
                    number_to_remove = @delete_buttons.size - number_of_visible_rows  
                    number_to_remove.times do 
                        remove_table_delete_button 
                    end 
                end
            end
        end

        def number_of_rows 
            @data_rows.size 
        end

        def render
            draw_border
            return unless number_of_rows > 0

            column_widths = []
            number_of_columns = @data_rows[0].size 
            (0..number_of_columns-1).each do |c| 
                max_length = @gui_theme.font.text_width(headers[c])
                (0..number_of_rows-1).each do |r|
                    text_pixel_width = @gui_theme.font.text_width(@data_rows[r][c])
                    if text_pixel_width > max_length 
                        max_length = text_pixel_width
                    end 
                end 
                column_widths[c] = max_length
            end

            x = @x + 10
            if number_of_columns > 1
                (0..number_of_columns-2).each do |c| 
                    x = x + column_widths[c] + 20
                    Gosu::draw_line x, @y, graphics_color, x, @y + @height, graphics_color, z_order
                end 
            end

            y = @y             
            x = @x + 20
            (0..number_of_columns-1).each do |c| 
                @gui_theme.font.draw_text(@headers[c], x, y, z_order, 1, 1, text_color)
                x = x + column_widths[c] + 20
            end
            y = y + 30

            count = 0
            @data_rows.each do |row|
                if count < @current_row
                    # skip
                elsif count < @current_row + @max_visible_rows
                    x = @x + 20
                    (0..number_of_columns-1).each do |c| 
                        @gui_theme.font.draw_text(row[c], x, y + 2, z_order, 1, 1, @row_colors[count])
                        x = x + column_widths[c] + 20
                    end
                    y = y + 30
                end
                count = count + 1
            end
        end

        def determine_row_number(mouse_y)
            relative_y = mouse_y - @y
            row_number = (relative_y / 30).floor - 1
            if row_number < 0 or row_number > data_rows.size - 1
                return nil 
            end 
            row_number
        end

        def widget_z 
            Z_ORDER_TEXT
        end

        def uses_layout
            false 
        end
    end

    class SingleSelectTable < Table
        attr_accessor :selected_row

        def initialize(x, y, width, height, headers, max_visible_rows = 10) 
            super(x, y, width, height, headers, max_visible_rows) 
        end 

        def set_selected_row(mouse_y, column_number)
            row_number = determine_row_number(mouse_y)
            if not row_number.nil?
                new_selected_row = @current_row + row_number
                if @selected_row 
                    if @selected_row == new_selected_row
                        return nil  # You can't select the same row already selected
                    end 
                end
                @selected_row = new_selected_row
                @data_rows[@selected_row][column_number]
            end
        end

        def render 
            super 
            if @selected_row 
                if @selected_row >= @current_row and @selected_row < @current_row + @max_visible_rows
                    y = @y + 30 + ((@selected_row - @current_row) * 30)
                    Gosu::draw_rect(@x + 20, y, @width - 30, 28, @gui_theme.selection_color, relative_z_order(Z_ORDER_SELECTION_BACKGROUND)) 
                end 
            end
        end

        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    class MultiSelectTable < Table
        attr_accessor :selected_rows

        def initialize(x, y, width, height, headers, max_visible_rows = 10) 
            super(x, y, width, height, headers, max_visible_rows) 
            @selected_rows = []
        end 

        def is_row_selected(mouse_y)
            row_number = determine_row_number(mouse_y)
            if row_number.nil?
                return false
            end
            @selected_rows.include?(@current_row + row_number)
        end 

        def set_selected_row(mouse_y, column_number)
            row_number = determine_row_number(mouse_y)
            if not row_number.nil?
                this_selected_row = @current_row + row_number
                @selected_rows << this_selected_row
                return @data_rows[this_selected_row][column_number]
            end
            nil
        end

        def unset_selected_row(mouse_y, column_number) 
            row_number = determine_row_number(mouse_y) 
            if not row_number.nil?
                this_selected_row = @current_row + row_number
                @selected_rows.delete(this_selected_row)
                return @data_rows[this_selected_row][column_number]
            end 
            nil
        end

        def render 
            super 
            y = @y + 30
            row_count = @current_row
            while row_count < @data_rows.size
                if @selected_rows.include? row_count 
                    width_of_selection_background = @width - 30
                    if @can_delete_rows 
                        width_of_selection_background = width_of_selection_background - 20
                    end
                    Gosu::draw_rect(@x + 20, y, width_of_selection_background, 28,
                                    @gui_theme.selection_color,
                                    relative_z_order(Z_ORDER_SELECTION_BACKGROUND)) 
                end 
                y = y + 30
                row_count = row_count + 1
            end
        end

        def widget_z 
            Z_ORDER_TEXT
        end

        def handle_mouse_down mouse_x, mouse_y
            if contains_click(mouse_x, mouse_y)
                row_number = determine_row_number(mouse_y)
                if row_number.nil? 
                    return WidgetResult.new(false)
                end
                # First check if its the delete button that got this
                delete_this_row = false
                @delete_buttons.each do |db|
                    if db.contains_click(mouse_x, mouse_y)
                        delete_this_row = true 
                    end 
                end 
                if delete_this_row
                    if not row_number.nil?
                       data_set_row_to_delete = @current_row + row_number
                       data_set_name_to_delete = @data_rows[data_set_row_to_delete][1]
                       @data_rows.delete_at(data_set_row_to_delete)
                       return WidgetResult.new(false, EVENT_TABLE_ROW_DELETE, [data_set_name_to_delete])                       
                    end
                else
                    if is_row_selected(mouse_y)
                        unset_selected_row(mouse_y, 0)
                        return WidgetResult.new(false, EVENT_TABLE_UNSELECT, @data_rows[row_number])
                    else
                        set_selected_row(mouse_y, 0)
                        return WidgetResult.new(false, EVENT_TABLE_SELECT, @data_rows[row_number])
                    end
                end
            end
        end
    end 

    class Plot < Widget
        attr_accessor :points
        attr_accessor :visible_range
        attr_accessor :display_grid
        attr_accessor :display_lines
        attr_accessor :zoom_level
        attr_accessor :visibility_map

        def initialize(x, y, width, height) 
            super(x, y)
            set_dimensions(width, height)
            @display_grid = false
            @display_lines = true
            @grid_line_color = COLOR_LIGHT_GRAY
            @cursor_line_color = COLOR_DARK_GRAY 
            @zero_line_color = COLOR_HEADER_BRIGHT_BLUE 
            @zoom_level = 1
            @data_point_size = 4
            # Hash of rendered points keyed by data set name, so we can toggle visibility
            @points_by_data_set_name = {}
            @visibility_map = {}
            disable_border
        end

        def toggle_visibility(data_set_name)
            is_visible = @visibility_map[data_set_name]
            if is_visible.nil?
                return
            end
            @visibility_map[data_set_name] = !is_visible
        end
 
        def increase_data_point_size
            @data_point_size = @data_point_size + 2
        end 

        def decrease_data_point_size 
            if @data_point_size > 2
                @data_point_size = @data_point_size - 2
            end
        end

        def zoom_out 
            @zoom_level = @zoom_level + 0.15
            visible_range.scale(@zoom_level)
        end 

        def zoom_in
            if @zoom_level > 0.11
                @zoom_level = @zoom_level - 0.15
            end
            visible_range.scale(@zoom_level)
        end 

        def scroll_up 
            visible_range.scroll_up
        end

        def scroll_down
            visible_range.scroll_down
        end

        def scroll_right
            visible_range.scroll_right
        end

        def scroll_left
            visible_range.scroll_left
        end

        def define_range(range)
            @visible_range = range
            @zoom_level = 1
        end 

        def range_set?
            not @visible_range.nil?
        end 

        def is_on_screen(point) 
            point.data_x >= @visible_range.left_x and point.data_x <= @visible_range.right_x and point.data_y >= @visible_range.bottom_y and point.data_y <= @visible_range.top_y
        end 

        def add_data_set(data_set_name, rendered_points)
            if range_set?
                @points_by_data_set_name[data_set_name] = rendered_points
                if @visibility_map[data_set_name].nil?
                    @visibility_map[data_set_name] = true
                end
            else
                error("ERROR: range not set, cannot add data")
            end
        end 

        def remove_data_set(data_set_name)
            @points_by_data_set_name.delete(data_set_name)
            @visibility_map.delete(data_set_name)
        end

        def x_val_to_pixel(val)
            x_pct = (@visible_range.right_x - val).to_f / @visible_range.x_range 
            @width - (@width.to_f * x_pct).round
        end 

        def y_val_to_pixel(val)
            y_pct = (@visible_range.top_y - val).to_f / @visible_range.y_range 
            (@height.to_f * y_pct).round
        end

        def draw_x(x)
            x_pixel_to_screen(x_val_to_pixel(x)) 
        end 

        def draw_y(y)
            y_pixel_to_screen(y_val_to_pixel(y)) 
        end 

        def render
            @points_by_data_set_name.keys.each do |key|
                if @visibility_map[key]
                    data_set_points = @points_by_data_set_name[key]
                    data_set_points.each do |point| 
                        if is_on_screen(point)
                            point.render(@data_point_size)
                        end
                    end 
                    if @display_lines 
                        display_lines_for_point_set(data_set_points) 
                    end
                end
                if @display_grid and range_set?
                    display_grid_lines
                end
            end
        end

        def display_lines_for_point_set(points) 
            if points.length > 1
                points.inject(points[0]) do |last, the_next|
                    if last.x < the_next.x
                        Gosu::draw_line last.x, last.y, last.graphics_color,
                                        the_next.x, the_next.y, last.graphics_color, relative_z_order(Z_ORDER_GRAPHIC_ELEMENTS)
                    end
                    the_next
                end
            end
        end

        def display_grid_lines
            grid_widgets = []

            x_lines = @visible_range.grid_line_x_values
            y_lines = @visible_range.grid_line_y_values
            first_x = draw_x(@visible_range.left_x)
            last_x = draw_x(@visible_range.right_x)
            first_y = draw_y(@visible_range.bottom_y)
            last_y = draw_y(@visible_range.top_y)

            x_lines.each do |grid_x|
                dx = draw_x(grid_x)
                color = @grid_line_color
                if grid_x == 0 and grid_x != @visible_range.left_x.to_i
                    color = @zero_line_color 
                end    
                grid_widgets << Line.new(dx, first_y, dx, last_y, color) 
            end

            y_lines.each do |grid_y| 
                dy = draw_y(grid_y)
                color = @grid_line_color
                if grid_y == 0 and grid_y != @visible_range.bottom_y.to_i
                    color = @zero_line_color
                end
                grid_widgets << Line.new(first_x, dy, last_x, dy, color) 
            end 

            grid_widgets.each do |gw| 
                gw.draw 
            end
        end

        def get_x_data_val(mouse_x)
            graph_x = mouse_x - @x
            x_pct = (@width - graph_x).to_f / @width.to_f
            x_val = @visible_range.right_x - (x_pct * @visible_range.x_range)
            x_val
        end 

        def get_y_data_val(mouse_y)
            graph_y = mouse_y - @y
            y_pct = graph_y.to_f / @height.to_f
            y_val = @visible_range.top_y - (y_pct * @visible_range.y_range)
            y_val
        end

        def draw_cursor_lines(mouse_x, mouse_y)
            Gosu::draw_line mouse_x, y_pixel_to_screen(0), @cursor_line_color, mouse_x, y_pixel_to_screen(@height), @cursor_line_color, Z_ORDER_GRAPHIC_ELEMENTS
            Gosu::draw_line x_pixel_to_screen(0), mouse_y, @cursor_line_color, x_pixel_to_screen(@width), mouse_y, @cursor_line_color, Z_ORDER_GRAPHIC_ELEMENTS
            
            # Return the data values at this point, so the plotter can display them
            [get_x_data_val(mouse_x), get_y_data_val(mouse_y)]
        end 
    end 

    class NodeWidget < Button
        attr_accessor :data_node

        def initialize(x, y, node, color = nil) 
            super(node.name, x, y)
            @data_node = node
            @override_color = color
        end

        def set_scale(value)
            # TODO adjust the width and height
        end

        def get_text_widget
            nil 
        end

        def render 
            super 
            draw_background(Z_ORDER_FOCAL_ELEMENTS)
            #draw_shadow(COLOR_GRAY)
        end
    
        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    class NodeIconWidget < Widget
        attr_accessor :data_node
        attr_accessor :image
        attr_accessor :scale
        attr_accessor :label

        def initialize(x, y, node, color = nil) 
            super(x, y) 
            @override_color = color
            @data_node = node
            @label = node.name
            circle_image = WadsConfig.instance.circle(color)
            if circle_image.nil?
                @image = WadsConfig.instance.circle(COLOR_BLUE)
            else 
                @image = circle_image 
            end
            set_scale(1)
            disable_border
        end

        def set_scale(value)
            @scale = value / 10.to_f
            debug("In node widget Setting scale of #{@label} to #{value} = #{@scale}")
            @width = IMAGE_CIRCLE_SIZE * scale.to_f
            @height = IMAGE_CIRCLE_SIZE * scale.to_f
            text_pixel_width = @gui_theme.font.text_width(@label)
            clear_children  # the text widget is the only child, so we can remove all
            add_text(@label, (@width / 2) - (text_pixel_width / 2), -20)
        end

        def get_text_widget
            if @children.size > 0
                return @children[0]
            end 
            raise "No text widget for NodeIconWidget" 
        end

        def render 
            @image.draw @x, @y, relative_z_order(Z_ORDER_FOCAL_ELEMENTS), @scale, @scale
        end 

        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    class GraphWidget < Widget
        attr_accessor :graph
        attr_accessor :center_node 
        attr_accessor :selected_node
        attr_accessor :selected_node_x_offset
        attr_accessor :selected_node_y_offset
        attr_accessor :size_by_connections

        def initialize(x, y, width, height, graph) 
            super(x, y)
            set_dimensions(width, height)
            if graph.is_a? Node 
                @graph = Graph.new(graph)
            else
                @graph = graph 
            end
            @use_icons = true
            @size_by_connections = true
            set_all_nodes_for_display
        end 

        def handle_update update_count, mouse_x, mouse_y
            if contains_click(mouse_x, mouse_y) and @selected_node 
                @selected_node.move_recursive_absolute(mouse_x - @selected_node_x_offset,
                                                       mouse_y - @selected_node_y_offset)
            end
        end

        def handle_mouse_down mouse_x, mouse_y
            # check to see if any node was selected
            if @rendered_nodes
                @rendered_nodes.values.each do |rn|
                    if rn.contains_click(mouse_x, mouse_y)
                        @selected_node = rn 
                        @selected_node_x_offset = mouse_x - rn.x 
                        @selected_node_y_offset = mouse_y - rn.y
                    end
                end
            end
            WidgetResult.new(false)
        end

        def handle_mouse_up mouse_x, mouse_y
            if @selected_node 
                @selected_node = nil 
            end 
        end

        def set_tree_display(max_depth = -1)
            @graph.reset_visited
            @visible_data_nodes = @graph.node_map
            @rendered_nodes = {}

            root_nodes = @graph.root_nodes
            number_of_root_nodes = root_nodes.size 
            width_for_each_root_tree = @width / number_of_root_nodes

            start_x = 0
            y_level = 20
            root_nodes.each do |root|
                set_tree_recursive(root, start_x, start_x + width_for_each_root_tree - 1, y_level)
                start_x = start_x + width_for_each_root_tree
                y_level = y_level + 40
            end

            @rendered_nodes.values.each do |rn|
                rn.base_z = @base_z
            end

            if @size_by_connections
                scale_node_size
            end

            prevent_text_overlap 
        end 

        def scale_node_size 
            range = @graph.get_number_of_connections_range
            # There are six colors. Any number of scale sizes
            # Lets try 4 first as a max size.
            bins = range.bin_max_values(4)  

            # Set the scale for each node
            @visible_data_nodes.values.each do |node|
                num_links = node.number_of_links
                index = 0
                while index < bins.size 
                    if num_links <= bins[index]
                        @rendered_nodes[node.name].set_scale(index + 1)
                        index = bins.size
                    end 
                    index = index + 1
                end
            end
        end 

        def prevent_text_overlap 
            @rendered_nodes.values.each do |rn|
                text = rn.get_text_widget
                if text
                    if overlaps_with_a_node(text)
                        debug("#{text.label} overlaps with #{rn.label}")
                        move_text_for_node(rn)
                    end
                end
            end
        end

        def move_text_for_node(rendered_node)
            text = rendered_node.get_text_widget
            radians_between_attempts = DEG_360 / 24
            current_radians = 0.05
            done = false 
            while not done
                # Use radians to spread the other nodes around the center node
                # TODO base the distance off of scale
                text_x = rendered_node.center_x + ((rendered_node.width / 2) * Math.cos(current_radians))
                text_y = rendered_node.center_y - ((rendered_node.height / 2) * Math.sin(current_radians))
                if text_x < @x 
                    text_x = @x + 1
                elsif text_x > right_edge - 20
                    text_x = right_edge - 20
                end 
                if text_y < @y 
                    text_y = @y + 1
                elsif text_y > bottom_edge - 26 
                    text_y = bottom_edge - 26
                end
                text.x = text_x 
                text.y = text_y
                current_radians = current_radians + radians_between_attempts
                if overlaps_with_a_node(text)
                    # check for done
                    if current_radians > DEG_360
                        done = true 
                        error("ERROR: could not find a spot to put the text")
                    end
                else 
                    done = true
                end 
            end
        end 

        def overlaps_with_a_node(text)
            @rendered_nodes.values.each do |rn| 
                if text.label == rn.label 
                    # don't compare to yourself 
                else 
                    if rn.overlaps_with(text) 
                        return true
                    end
                end
            end
            # We also check to see if the text is outside the edges of this widget
            if text.x < @x or text.right_edge > right_edge 
                return true 
            end
            if text.y < @y or text.bottom_edge > bottom_edge 
                return true 
            end
            false
        end

        def set_tree_recursive(current_node, start_x, end_x, y_level)
            # Draw the current node, and then recursively divide up
            # and call again for each of the children
            if current_node.visited 
                return 
            end 
            current_node.visited = true

            if @use_icons
                @rendered_nodes[current_node.name] = NodeIconWidget.new(
                    x_pixel_to_screen(start_x + ((end_x - start_x) / 2)),
                    y_pixel_to_screen(y_level),
                    current_node,
                    get_node_color(current_node))
            else
                @rendered_nodes[current_node.name] = NodeWidget.new(
                    x_pixel_to_screen(start_x + ((end_x - start_x) / 2)),
                    y_pixel_to_screen(y_level),
                    current_node,
                    get_node_color(current_node))
            end

            number_of_child_nodes = current_node.outputs.size 
            if number_of_child_nodes == 0
                return 
            end
            width_for_each_child_tree = (end_x - start_x) / number_of_child_nodes
            start_child_x = start_x + 5

            current_node.outputs.each do |child| 
                if child.is_a? Edge 
                    child = child.destination 
                end
                set_tree_recursive(child, start_child_x, start_child_x + width_for_each_child_tree - 1, y_level + 40)
                start_child_x = start_child_x + width_for_each_child_tree
            end
        end

        def set_all_nodes_for_display 
            @visible_data_nodes = @graph.node_map
            @rendered_nodes = {}
            populate_rendered_nodes
            if @size_by_connections
                scale_node_size
            end
            prevent_text_overlap 
        end 

        def get_node_color(node)
            color_tag = node.get_tag(COLOR_TAG)
            if color_tag.nil? 
                return @color 
            end 
            color_tag
        end 

        def set_center_node(center_node, max_depth = -1)
            # Determine the list of nodes to draw
            @graph.reset_visited 
            @visible_data_nodes = @graph.traverse_and_collect_nodes(center_node, max_depth)

            # Convert the data nodes to rendered nodes
            # Start by putting the center node in the center, then draw others around it
            @rendered_nodes = {}
            if @use_icons
                @rendered_nodes[center_node.name] = NodeIconWidget.new(
                    center_x, center_y, center_node, get_node_color(center_node)) 
            else
                @rendered_nodes[center_node.name] = NodeWidget.new(center_x, center_y,
                    center_node, get_node_color(center_node), get_node_color(center_node))
            end

            populate_rendered_nodes(center_node)

            if @size_by_connections
                scale_node_size
            end
            prevent_text_overlap 
        end 

        def populate_rendered_nodes(center_node = nil)
            # Spread out the other nodes around the center node
            # going in a circle
            number_of_visible_nodes = @visible_data_nodes.size 
            radians_between_nodes = DEG_360 / number_of_visible_nodes.to_f
            current_radians = 0.05

            @visible_data_nodes.each do |node_name, data_node|
                process_this_node = true
                if center_node 
                    if node_name == center_node.name 
                        process_this_node = false 
                    end 
                end
                if process_this_node 
                    # Use radians to spread the other nodes around the center node
                    # For now, we will randomly place them
                    node_x = center_x + ((80 + rand(200)) * Math.cos(current_radians))
                    node_y = center_y - ((40 + rand(100)) * Math.sin(current_radians))
                    if node_x < @x 
                        node_x = @x + 1
                    elsif node_x > right_edge - 20
                        node_x = right_edge - 20
                    end 
                    if node_y < @y 
                        node_y = @y + 1
                    elsif node_y > bottom_edge - 26 
                        node_y = bottom_edge - 26
                    end
                    current_radians = current_radians + radians_between_nodes

                    # Note we can link between data nodes and rendered nodes using the node name
                    # We have a map of each
                    if @use_icons
                        @rendered_nodes[data_node.name] = NodeIconWidget.new(
                                                        node_x,
                                                        node_y,
                                                        data_node,
                                                        get_node_color(data_node)) 
                    else
                        @rendered_nodes[data_node.name] = NodeWidget.new(
                                                        node_x,
                                                        node_y,
                                                        data_node,
                                                        get_node_color(data_node),
                                                        get_node_color(data_node))
                    end
                end
            end
            @rendered_nodes.values.each do |rn|
                rn.base_z = @base_z
            end
        end

        def render 
            if @rendered_nodes
                @rendered_nodes.values.each do |vn|
                    vn.draw 
                end 

                # Draw the connections between nodes 
                @visible_data_nodes.values.each do |data_node|
                    data_node.outputs.each do |connected_data_node|
                        if connected_data_node.is_a? Edge 
                            connected_data_node = connected_data_node.destination 
                        end
                        rendered_node = @rendered_nodes[data_node.name]
                        connected_rendered_node = @rendered_nodes[connected_data_node.name]
                        if connected_rendered_node.nil?
                            # Don't draw if it is not currently visible
                        else
                            Gosu::draw_line rendered_node.center_x, rendered_node.center_y, rendered_node.graphics_color,
                                    connected_rendered_node.center_x, connected_rendered_node.center_y, connected_rendered_node.graphics_color,
                                    relative_z_order(Z_ORDER_GRAPHIC_ELEMENTS)
                        end
                    end
                end 
            end
        end 
    end
end
