require_relative 'data_structures'

module Wads
    COLOR_PEACH = Gosu::Color.argb(0xffe6b0aa)
    COLOR_LIGHT_PURPLE = Gosu::Color.argb(0xffd7bde2)
    COLOR_LIGHT_BLUE = Gosu::Color.argb(0xffa9cce3)
    COLOR_LIGHT_GREEN = Gosu::Color.argb(0xffa3e4d7)
    COLOR_LIGHT_YELLOW = Gosu::Color.argb(0xfff9e79f)
    COLOR_LIGHT_ORANGE = Gosu::Color.argb(0xffedbb99)
    COLOR_WHITE = Gosu::Color::WHITE
    COLOR_OFF_WHITE = Gosu::Color.argb(0xfff8f9f9)
    COLOR_PINK = Gosu::Color.argb(0xffe6b0aa)
    COLOR_LIME = Gosu::Color.argb(0xffDAF7A6)
    COLOR_YELLOW = Gosu::Color.argb(0xffFFC300)
    COLOR_MAROON = Gosu::Color.argb(0xffC70039)
    COLOR_LIGHT_GRAY = Gosu::Color.argb(0xff2c3e50)
    COLOR_GRAY = Gosu::Color::GRAY
    COLOR_OFF_GRAY = Gosu::Color.argb(0xff566573)
    COLOR_LIGHT_BLACK = Gosu::Color.argb(0xff111111)
    COLOR_LIGHT_RED = Gosu::Color.argb(0xffe6b0aa)
    COLOR_CYAN = Gosu::Color::CYAN
    COLOR_HEADER_BLUE = Gosu::Color.argb(0xff089FCE)
    COLOR_HEADER_BRIGHT_BLUE = Gosu::Color.argb(0xff0FAADD)
    COLOR_BLUE = Gosu::Color::BLUE
    COLOR_DARK_GRAY = Gosu::Color.argb(0xccf0f3f4)
    COLOR_RED = Gosu::Color::RED
    COLOR_BLACK = Gosu::Color::BLACK
    COLOR_FORM_BUTTON = Gosu::Color.argb(0xcc2e4053)
    COLOR_ERROR_CODE_RED = Gosu::Color.argb(0xffe6b0aa)

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

    class Widget 
        attr_accessor :x
        attr_accessor :y 
        attr_accessor :base_z 
        attr_accessor :color 
        attr_accessor :background_color
        attr_accessor :border_color
        attr_accessor :width
        attr_accessor :height 
        attr_accessor :visible 
        attr_accessor :font
        attr_accessor :children
        attr_accessor :overlay_widget

        def initialize(x, y, color = COLOR_CYAN) 
            @x = x 
            @y = y 
            @color = color
            @width = 1 
            @height = 1
            @visible = true 
            @children = []
            @base_z = 0
        end

        def z_order 
            @base_z + widget_z
        end

        def relative_z_order(relative_order)
            @base_z + relative_order 
        end

        def add_child(child) 
            @children << child 
        end

        def remove_child(child)
            @children.delete(child)
        end

        def clear_children 
            @children = [] 
        end

        def set_background(bgcolor)
            @background_color = bgcolor 
        end

        def set_border(bcolor)
            @border_color = bcolor 
        end

        def set_font(font)
            @font = font 
        end

        def set_color(color)
            @color = color 
        end

        def set_dimensions(width, height)
            @width = width
            @height = height 
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

        def draw 
            if @visible 
                render
                if @background_color
                    draw_background
                end
                if @border_color 
                    draw_border(@border_color)
                end
                @children.each do |child| 
                    child.draw 
                end 
            end 
        end

        def draw_background(z_override = nil)
            if z_override 
                z = relative_z_order(z_override)
            else 
                z = relative_z_order(Z_ORDER_BACKGROUND) 
            end
            Gosu::draw_rect(@x + 1, @y + 1, @width - 3, @height - 3, @background_color, z) 
        end

        def draw_shadow(color)
            Gosu::draw_line @x - 1, @y - 1, color, right_edge - 1, @y - 1, color, relative_z_order(Z_ORDER_BORDER)
            Gosu::draw_line @x - 1, @y - 1, color, @x - 1, bottom_edge - 1, color, relative_z_order(Z_ORDER_BORDER)
        end

        def draw_border(color = nil)
            if color.nil? 
                if @border_color
                    color = @border_color 
                else
                    color = @color 
                end
            end
            Gosu::draw_line @x, @y, color, right_edge, @y, color, relative_z_order(Z_ORDER_BORDER)
            Gosu::draw_line @x, @y, color, @x, bottom_edge, color, relative_z_order(Z_ORDER_BORDER)
            Gosu::draw_line @x,bottom_edge, color, right_edge, bottom_edge, color, relative_z_order(Z_ORDER_BORDER)
            Gosu::draw_line right_edge, @y, color, right_edge, bottom_edge, color, relative_z_order(Z_ORDER_BORDER)
        end

        def contains_click(mouse_x, mouse_y)
            mouse_x >= @x and mouse_x <= right_edge and mouse_y >= @y and mouse_y <= bottom_edge
        end

        def update(update_count, mouse_x, mouse_y)
            if @overlay_widget 
                @overlay_widget.update(update_count, mouse_x, mouse_y)
            end
            handle_update(update_count, mouse_x, mouse_y) 
            @children.each do |child| 
                child.handle_update(update_count, mouse_x, mouse_y) 
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

        def x_pixel_to_screen(x)
            @x + x
        end

        def y_pixel_to_screen(y)
            @y + y
        end

        def add_text(message, rel_x, rel_y)
            new_text = Text.new(message, x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), @font)
            new_text.base_z = @base_z
            add_child(new_text)
            new_text
        end 

        def add_document(content, rel_x, rel_y, width, height)
            new_doc = Document.new(content, x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), width, height, @font)
            new_doc.base_z = @base_z
            add_child(new_doc)
            new_doc
        end

        def add_button(label, rel_x, rel_y, width = nil, &block)
            new_button = Button.new(label, x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), @font)
            if width.nil?
                width = 60
            end
            new_button.width = width
            new_button.set_action(&block)
            new_button.base_z = @base_z
            add_child(new_button)
            new_button
        end

        def add_table(rel_x, rel_y, width, height, column_headers, color = COLOR_WHITE, max_visible_rows = 10)
            new_table = Table.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y),
                              width, height, column_headers, @font, color, max_visible_rows)
            new_table.base_z = @base_z
            add_child(new_table)
            new_table
        end 

        def add_single_select_table(rel_x, rel_y, width, height, column_headers, color = COLOR_WHITE, max_visible_rows = 10)
            new_table = SingleSelectTable.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y),
                              width, height, column_headers, @font, color, max_visible_rows)
            new_table.base_z = @base_z
            add_child(new_table)
            new_table
        end 

        def add_multi_select_table(rel_x, rel_y, width, height, column_headers, color = COLOR_WHITE, max_visible_rows = 10)
            new_table = MultiSelectTable.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y),
                              width, height, column_headers, @font, color, max_visible_rows)
            new_table.base_z = @base_z
            add_child(new_table)
            new_table
        end 

        def add_graph_display(rel_x, rel_y, width, height, graph)
            new_graph = GraphWidget.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), width, height, @font, @color, graph) 
            new_graph.base_z = @base_z
            add_child(new_graph)
            new_graph
        end

        def add_plot(rel_x, rel_y, width, height)
            new_plot = Plot.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), width, height, @font) 
            new_plot.base_z = @base_z
            add_child(new_plot)
            new_plot
        end

        def add_axis_lines(rel_x, rel_y, width, height, color)
            new_axis_lines = AxisLines.new(x_pixel_to_screen(rel_x), y_pixel_to_screen(rel_y), width, height, color) 
            new_axis_lines.base_z = @base_z
            add_child(new_axis_lines)
            new_axis_lines
        end

        def add_overlay(overlay)
            overlay.base_z = @base_z + 10
            add_child(overlay)
            @overlay_widget = overlay
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

    class Text < Widget
        attr_accessor :str
        def initialize(str, x, y, font, color = COLOR_WHITE) 
            super(x, y, color) 
            set_font(font)
            @str = str
        end
        def render 
            @font.draw_text(@str, @x, @y, z_order, 1, 1, @color)
        end
        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    class ErrorMessage < Text
        attr_accessor :str
        def initialize(str, x, y, font) 
            super("ERROR: #{str}", x, y, font, COLOR_ERROR_CODE_RED) 
            set_dimensions(@font.text_width(@str) + 4, 36)
        end
    end 

    class PlotPoint < Widget
        attr_accessor :data_x
        attr_accessor :data_y
        attr_accessor :data_point_size 

        def initialize(x, y, data_x, data_y, color = COLOR_MAROON, size = 4) 
            super(x, y, color)
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
                            @color, z_order) 
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
        attr_accessor :text_color
        attr_accessor :is_pressed
        attr_accessor :action_code

        def initialize(label, x, y, font, width = nil, color = COLOR_DARK_GRAY, text_color = COLOR_HEADER_BRIGHT_BLUE) 
            super(x, y, color) 
            set_font(font)
            @label = label
            @text_pixel_width = @font.text_width(@label)
            if width.nil?
                @width = @text_pixel_width + 10
            else 
                @width = width 
            end
            @height = 26
            @text_color = text_color
            @is_pressed = false
            @is_pressed_update_count = -100
        end

        def render 
            draw_border(@color)
            text_x = center_x - (@text_pixel_width / 2)
            @font.draw_text(@label, text_x, @y, z_order, 1, 1, @text_color)
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
                set_background(nil)
            elsif contains_click(mouse_x, mouse_y)
                set_background(COLOR_LIGHT_GRAY)
            else 
                set_background(nil)
            end
        end
    end 

    class Document < Widget
        attr_accessor :lines

        def initialize(content, x, y, width, height, font) 
            super(x, y, COLOR_GRAY) 
            set_font(font)
            set_dimensions(width, height)
            @lines = content.split("\n")
        end

        def render 
            y = @y + 4
            @lines.each do |line|
                @font.draw_text(line, @x + 5, y, z_order, 1, 1, COLOR_WHITE)
                y = y + 26
            end
        end 

        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    class InfoBox < Widget 
        def initialize(title, content, x, y, font, width, height) 
            super(x, y) 
            set_font(font)
            set_dimensions(width, height)
            set_border(COLOR_WHITE)
            set_background(COLOR_OFF_GRAY)
            @base_z = 10
            add_text(title, 5, 5)
            add_document(content, 5, 52, width, height - 52)
            ok_button = add_button("OK", (@width / 2) - 50, height - 26) do
                WidgetResult.new(true)
            end
            ok_button.text_color = COLOR_WHITE
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

        def initialize(window, font, x, y, width, height, title, text_input_default) 
            super(x, y) 
            @window = window
            set_font(font)
            set_dimensions(width, height)
            set_background(COLOR_OFF_GRAY)
            set_border(COLOR_WHITE)
            @base_z = 10
            @error_message = nil

            add_text(title, 5, 5)
            # Forms automatically have some explanatory content
            add_document(content, 0, 56, width, height)

            # Forms automatically get a text input widget
            @textinput = TextField.new(@window, @font, x + 10, bottom_edge - 80, text_input_default, 600)
            @textinput.base_z = 10
            add_child(@textinput)

            # Forms automatically get OK and Cancel buttons
            ok_button = add_button("OK", (@width / 2) - 100, height - 32) do
                handle_ok
            end
            ok_button.color = COLOR_FORM_BUTTON
            ok_button.text_color = COLOR_WHITE
            ok_button.width = 100

            cancel_button = add_button("Cancel", (@width / 2) + 50, height - 32) do
                WidgetResult.new(true)
            end
            cancel_button.color = COLOR_FORM_BUTTON
            cancel_button.text_color = COLOR_WHITE
            cancel_button.width = 100
        end

        def content 
            <<~HEREDOC
            Override the content method to
            put your info here.
            HEREDOC
        end

        def add_error_message(msg) 
            @error_message = ErrorMessage.new(msg, x + 10, bottom_edge - 120, @font)
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

        def initialize(x, y, x2, y2, color = COLOR_CYAN) 
            super x, y, color 
            @x2 = x2 
            @y2 = y2
        end

        def render
            Gosu::draw_line x, y, @color, x2, y2, @color, z_order
        end

        def widget_z 
            Z_ORDER_GRAPHIC_ELEMENTS
        end
    end 

    class AxisLines < Widget
        def initialize(x, y, width, height, color = COLOR_CYAN) 
            super x, y, color 
            @width = width 
            @height = height
        end

        def render
            add_child(Line.new(@x, @y, @x, bottom_edge, @color))
            add_child(Line.new(@x, bottom_edge, right_edge, bottom_edge, @color))
        end
    end

    class VerticalAxisLabel < Widget
        attr_accessor :label

        def initialize(x, y, label, font, color = COLOR_CYAN) 
            super x, y, color 
            set_font(font)
            @label = label 
        end

        def render
            text_pixel_width = @font.text_width(@label)
            Gosu::draw_line @x - 20, @y, @color,
                            @x, @y, @color, z_order
            
            @font.draw_text(@label, @x - text_pixel_width - 28, @y - 12, 1, 1, 1, @color)
        end

        def widget_z 
            Z_ORDER_GRAPHIC_ELEMENTS
        end
    end 

    class HorizontalAxisLabel < Widget
        attr_accessor :label

        def initialize(x, y, label, font, color = COLOR_CYAN) 
            super x, y, color 
            set_font(font)
            @label = label 
        end

        def render
            text_pixel_width = @font.text_width(@label)
            Gosu::draw_line @x, @y, @color, @x, @y + 20, @color
            @font.draw_text(@label, @x - (text_pixel_width / 2), @y + 26, z_order, 1, 1, @color)
        end

        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    class Table < Widget
        attr_accessor :data_rows 
        attr_accessor :row_colors
        attr_accessor :headers
        attr_accessor :max_visible_rows
        attr_accessor :current_row

        def initialize(x, y, width, height, headers, font, color = COLOR_GRAY, max_visible_rows = 10) 
            super(x, y, color) 
            set_font(font) 
            set_dimensions(width, height)
            @headers = headers
            @current_row = 0
            @max_visible_rows = max_visible_rows
            clear_rows            
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

        def add_row(data_row, color = @color)
            @data_rows << data_row
            @row_colors << color
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
                max_length = @font.text_width(headers[c])
                (0..number_of_rows-1).each do |r|
                    text_pixel_width = @font.text_width(@data_rows[r][c])
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
                    Gosu::draw_line x, @y, @color, x, @y + @height, @color, z_order
                end 
            end

            y = @y             
            x = @x + 20
            (0..number_of_columns-1).each do |c| 
                @font.draw_text(@headers[c], x, y, z_order, 1, 1, @color)
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
                        @font.draw_text(row[c], x, y + 2, z_order, 1, 1, @row_colors[count])
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
    end

    class SingleSelectTable < Table
        attr_accessor :selected_row
        attr_accessor :selected_color

        def initialize(x, y, width, height, headers, font, color = COLOR_GRAY, max_visible_rows = 10) 
            super(x, y, width, height, headers, font, color, max_visible_rows) 
            @selected_color = COLOR_BLACK
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
                    Gosu::draw_rect(@x + 20, y, @width - 30, 28, @selected_color, relative_z_order(Z_ORDER_SELECTION_BACKGROUND)) 
                end 
            end
        end

        def widget_z 
            Z_ORDER_TEXT
        end
    end 

    class MultiSelectTable < Table
        attr_accessor :selected_rows
        attr_accessor :selection_color

        def initialize(x, y, width, height, headers, font, color = COLOR_GRAY, max_visible_rows = 10) 
            super(x, y, width, height, headers, font, color, max_visible_rows) 
            @selected_rows = []
            @selection_color = COLOR_LIGHT_GRAY
        end 

        def is_row_selected(mouse_y)
            row_number = determine_row_number(mouse_y)
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
                    Gosu::draw_rect(@x + 20, y, @width - 30, 28, @selection_color, relative_z_order(Z_ORDER_SELECTION_BACKGROUND)) 
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

    class Plot < Widget
        attr_accessor :points
        attr_accessor :visible_range
        attr_accessor :display_grid
        attr_accessor :display_lines
        attr_accessor :zoom_level
        attr_accessor :visibility_map

        def initialize(x, y, width, height, font) 
            super x, y, color 
            set_font(font)
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
            @zoom_level = @zoom_level + 0.1
            visible_range.scale(@zoom_level)
        end 

        def zoom_in
            if @zoom_level > 0.11
                @zoom_level = @zoom_level - 0.1
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
                @visibility_map[data_set_name] = true
            else
                puts "ERROR: range not set, cannot add data"
            end
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
                    Gosu::draw_line last.x, last.y, last.color,
                                    the_next.x, the_next.y, last.color, relative_z_order(Z_ORDER_GRAPHIC_ELEMENTS)
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

        def initialize(node, x, y, font, border_color = COLOR_DARK_GRAY, text_color = COLOR_HEADER_BRIGHT_BLUE) 
            super(node.name, x, y, font, nil, border_color, text_color) 
            set_background(COLOR_BLACK)
            @data_node = node
        end

        def render 
            super 
            draw_background(Z_ORDER_FOCAL_ELEMENTS)
            draw_shadow(COLOR_GRAY)
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

        def initialize(x, y, width, height, font, color, graph) 
            super x, y, color 
            set_font(font)
            set_dimensions(width, height)
            set_border(color)
            @graph = graph 
            set_all_nodes_for_display
        end 

        def handle_update update_count, mouse_x, mouse_y
            if contains_click(mouse_x, mouse_y) and @selected_node 
                @selected_node.x = mouse_x - @selected_node_x_offset
                @selected_node.y = mouse_y - @selected_node_y_offset
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
            y_level = 10
            root_nodes.each do |root|
                set_tree_recursive(root, start_x, start_x + width_for_each_root_tree - 1, y_level)
                start_x = start_x + width_for_each_root_tree
                y_level = y_level + 40
            end

            @rendered_nodes.values.each do |rn|
                rn.base_z = @base_z
            end
        end 

        def set_tree_recursive(current_node, start_x, end_x, y_level)
            # Draw the current node, and then recursively divide up
            # and call again for each of the children
            if current_node.visited 
                return 
            end 
            current_node.visited = true

            @rendered_nodes[current_node.name] = NodeWidget.new(
                    current_node,
                    x_pixel_to_screen(start_x + ((end_x - start_x) / 2)),
                    y_pixel_to_screen(y_level),
                    @font,
                    get_node_color(current_node),
                    get_node_color(current_node))

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
        end 

        def get_node_color(node)
            color_tag = node.get_tag("color")
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
            @rendered_nodes[center_node.name] = NodeWidget.new(center_node, center_x, center_y, @font,
                get_node_color(center_node), get_node_color(center_node))

            populate_rendered_nodes(center_node)
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
                    @rendered_nodes[data_node.name] = NodeWidget.new(
                                                        data_node,
                                                        node_x,
                                                        node_y,
                                                        @font,
                                                        get_node_color(data_node),
                                                        get_node_color(data_node))
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
                            Gosu::draw_line rendered_node.center_x, rendered_node.center_y, rendered_node.color,
                                    connected_rendered_node.center_x, connected_rendered_node.center_y, connected_rendered_node.color,
                                    relative_z_order(Z_ORDER_GRAPHIC_ELEMENTS)
                        end
                    end
                end 
            end
        end 
    end
end
