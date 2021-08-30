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
    Z_ORDER_WIDGET_BORDER = 3
    Z_ORDER_SELECTION_BACKGROUND = 4
    Z_ORDER_GRAPHIC_ELEMENTS = 5
    Z_ORDER_PLOT_POINTS = 6
    Z_ORDER_OVERLAY_BACKGROUND = 7
    Z_ORDER_OVERLAY_ELEMENTS = 8
    Z_ORDER_TEXT = 10

    class Widget 
        attr_accessor :x
        attr_accessor :y 
        attr_accessor :color 
        attr_accessor :background_color
        attr_accessor :border_color
        attr_accessor :width
        attr_accessor :height 
        attr_accessor :visible 
        attr_accessor :children
        attr_accessor :font

        def initialize(x, y, color = COLOR_CYAN) 
            @x = x 
            @y = y 
            @color = color
            @width = 1 
            @height = 1
            @visible = true 
            @children = []
        end

        def add_child(child) 
            @children << child 
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

        def draw_background(z_order = Z_ORDER_BACKGROUND)
            Gosu::draw_rect(@x + 1, @y + 1, @width - 3, @height - 3, @background_color, z_order) 
        end

        def draw_shadow(color, z_order = Z_ORDER_WIDGET_BORDER)
            Gosu::draw_line @x - 1, @y - 1, color, right_edge - 1, @y - 1, color, z_order
            Gosu::draw_line @x - 1, @y - 1, color, @x - 1, bottom_edge - 1, color, z_order
        end

        def draw_border(color = nil, zorder = Z_ORDER_WIDGET_BORDER)
            if color.nil? 
                if @border_color
                    color = @border_color 
                else
                    color = @color 
                end
            end
            Gosu::draw_line @x, @y, color, right_edge, @y, color, zorder
            Gosu::draw_line @x, @y, color, @x, bottom_edge, color, zorder
            Gosu::draw_line @x,bottom_edge, color, right_edge, bottom_edge, color, zorder
            Gosu::draw_line right_edge, @y, color, right_edge, bottom_edge, color, zorder
        end

        def contains_click(mouse_x, mouse_y)
            mouse_x >= @x and mouse_x <= right_edge and mouse_y >= @y and mouse_y <= bottom_edge
        end

        def update(update_count, mouse_x, mouse_y)
            handle_update(update_count, mouse_x, mouse_y) 
            @children.each do |child| 
                child.handle_update(update_count, mouse_x, mouse_y) 
            end 
        end

        def button_down(id, mouse_x, mouse_y)
            #puts "Base widget #{self.class.name} button down #{id}."
            if id == Gosu::MsLeft
                result = handle_mouse_down mouse_x, mouse_y
                return result unless result.nil?
            else 
                result = handle_key_press id, mouse_x, mouse_y
                return result unless result.nil?
            end
            @children.each do |child| 
                if id == Gosu::MsLeft
                    if child.contains_click(mouse_x, mouse_y) 
                        result = child.handle_mouse_down mouse_x, mouse_y
                        return result unless result.nil?
                    end 
                else 
                    result = child.handle_key_press id, mouse_x, mouse_y
                    return result unless result.nil?
                end
            end 
            WidgetResult.new(false)
        end

        def button_up(id, mouse_x, mouse_y)
            #puts "Base widget #{self.class.name} button up #{id}."
            if id == Gosu::MsLeft
                result = handle_mouse_up mouse_x, mouse_y
                return result unless result.nil?
            end

            @children.each do |child| 
                if id == Gosu::MsLeft
                    if child.contains_click(mouse_x, mouse_y) 
                        result = child.handle_mouse_up mouse_x, mouse_y
                        return result unless result.nil?
                    end 
                end
            end
            WidgetResult.new(false)
        end

        def pixel_x(rel_x) 
            @x + rel_x 
        end 

        def pixel_y(rel_y) 
            @y + rel_y
        end 

        def add_document(content, rel_x, rel_y, width, height)
            new_doc = Document.new(content, pixel_x(rel_x), pixel_y(rel_y), width, height, @font)
            add_child(new_doc)
            new_doc
        end

        def add_button(label, rel_x, rel_y, &block)
            new_button = Button.new(label, pixel_x(rel_x), pixel_y(rel_y), @font)
            new_button.set_action(&block)
            add_child(new_button)
            new_button
        end

        def add_single_select_table(rel_x, rel_y, width, height, column_headers, color = COLOR_WHITE, max_visible_rows = 10)
            new_table = SingleSelectTable.new(pixel_x(rel_x), pixel_y(rel_y),
                              width, height, column_headers, @font, COLOR_WHITE, max_visible_rows)
            add_child(new_table)
            new_table
        end 

        def add_graph_display(rel_x, rel_y, width, height, graph)
            new_graph = GraphWidget.new(pixel_x(rel_x), pixel_y(rel_y), width, height, @font, @color, graph) 
            add_child(new_graph)
            new_graph
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
    end 

    class Text < Widget
        attr_accessor :str
        def initialize(str, x, y, font, color = COLOR_WHITE) 
            super(x, y, color) 
            set_font(font)
            @str = str
        end
        def render 
            @font.draw_text(@str, @x, @y, Z_ORDER_TEXT, 1, 1, @color)
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
        attr_accessor :data_point_size 

        def initialize(x, y, color = COLOR_MAROON, size = 4) 
            super(x, y, color) 
            @data_point_size = size
        end

        def render 
            @half_size = @data_point_size / 2
            Gosu::draw_rect(@x - @half_size, @y - @half_size,
                            @data_point_size, @data_point_size,
                            @color, Z_ORDER_PLOT_POINTS) 
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
            @is_pressed = false
            @text_color = text_color
        end

        def render 
            draw_border(@color)
            text_x = center_x - (@text_pixel_width / 2)
            @font.draw_text(@label, text_x, @y, Z_ORDER_TEXT, 1, 1, @text_color)
        end 

        def set_action(&block) 
            @action_code = block
        end

        def handle_mouse_down mouse_x, mouse_y
            if @action_code
                @action_code.call
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
                @font.draw_text(line, @x + 5, y, Z_ORDER_TEXT, 1, 1, COLOR_WHITE)
                y = y + 26
            end
        end 
    end 

    class InfoBox < Widget 
        def initialize(title, content, x, y, font, width, height) 
            super(x, y) 
            set_font(font)
            set_dimensions(width, height)
            set_border(COLOR_WHITE)
            @title = title
            add_child(Text.new(title, x + 5, y + 5, Gosu::Font.new(32)))
            add_child(Document.new(content, x + 5, y + 52, width, height - 52, font))
            @ok_button = Button.new("OK", center_x - 50, bottom_edge - 26, @font, 100, COLOR_FORM_BUTTON)
            add_child(@ok_button) 
            set_background(COLOR_GRAY)
        end

        def button_down id, mouse_x, mouse_y
            if id == Gosu::KbEscape
                return WidgetResult.new(true) 
            elsif id == Gosu::MsLeft
                if @ok_button.contains_click(mouse_x, mouse_y)
                    return WidgetResult.new(true) 
                end
            end
            WidgetResult.new(false)
        end
    end

    class Dialog < Widget
        attr_accessor :textinput

        def initialize(window, font, x, y, width, height, title, text_input_default) 
            super(x, y) 
            @window = window
            set_font(font)
            set_dimensions(width, height)
            set_background(0xff566573 )
            set_border(COLOR_WHITE)
            @error_message = nil

            add_child(Text.new(title, x + 5, y + 5, @font))
            # Forms automatically have some explanatory content
            add_child(Document.new(content, x, y + 56, width, height, font))

            # Forms automatically get a text input widget
            @textinput = TextField.new(@window, @font, x + 10, bottom_edge - 80, text_input_default, 600)
            add_child(@textinput)

            # Forms automatically get OK and Cancel buttons
            @ok_button = Button.new("OK", center_x - 100, bottom_edge - 26, @font, 100, COLOR_FORM_BUTTON, COLOR_WHITE)
            @cancel_button = Button.new("Cancel", center_x + 50, bottom_edge - 26, @font, 100, COLOR_FORM_BUTTON, COLOR_WHITE)
            add_child(@ok_button) 
            add_child(@cancel_button)
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
            return WidgetResult.new(true) 
        end

        def handle_cancel
            # Default behavior is to do nothing except tell the caller to 
            # close the dialog
            return WidgetResult.new(true) 
        end

        def handle_up(mouse_x, mouse_y)
            # empty implementation of up arrow
        end

        def handle_down(mouse_x, mouse_y)
            # empty implementation of down arrow
        end

        def handle_mouse_click(mouse_x, mouse_y)
            # empty implementation of mouse click outside
            # of standard form elements in this dialog
        end

        def text_input_updated(text)
            # empty implementation of text being updated
            # in text widget
        end 

        def button_down id, mouse_x, mouse_y
            if id == Gosu::KbEscape
                return WidgetResult.new(true) 
            elsif id == Gosu::KbUp
                handle_up(mouse_x, mouse_y)
            elsif id == Gosu::KbDown
                handle_down(mouse_x, mouse_y)
            elsif id == Gosu::MsLeft
                if @ok_button.contains_click(mouse_x, mouse_y)
                    return handle_ok
                elsif @cancel_button.contains_click(mouse_x, mouse_y)
                    return handle_cancel 
                else 
                    # Mouse click: Select text field based on mouse position.
                    @window.text_input = [@textinput].find { |tf| tf.under_point?(mouse_x, mouse_y) }
                    # Advanced: Move caret to clicked position
                    @window.text_input.move_caret(mouse_x) unless @window.text_input.nil?

                    handle_mouse_click(mouse_x, mouse_y)
                end
            else 
                if @window.text_input
                    text_input_updated(@textinput.text)
                end
            end
            WidgetResult.new(false)
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
            Gosu::draw_line x, y, @color, x2, y2, @color, Z_ORDER_GRAPHIC_ELEMENTS
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
                            @x, @y, @color, Z_ORDER_GRAPHIC_ELEMENTS
            
            @font.draw_text(@label, @x - text_pixel_width - 28, @y - 12, 1, 1, 1, @color)
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
            @font.draw_text(@label, @x - (text_pixel_width / 2), @y + 26, Z_ORDER_TEXT, 1, 1, @color)
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
                    Gosu::draw_line x, @y, @color, x, @y + @height, @color, Z_ORDER_GRAPHIC_ELEMENTS
                end 
            end

            y = @y             
            x = @x + 20
            (0..number_of_columns-1).each do |c| 
                @font.draw_text(@headers[c], x, y, Z_ORDER_TEXT, 1, 1, @color)
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
                        @font.draw_text(row[c], x, y + 2, Z_ORDER_TEXT, 1, 1, @row_colors[count])
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
                    Gosu::draw_rect(@x + 20, y, @width - 30, 28, @selected_color, Z_ORDER_SELECTION_BACKGROUND) 
                end 
            end
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
                    Gosu::draw_rect(@x + 20, y, @width - 30, 28, @selection_color, Z_ORDER_SELECTION_BACKGROUND) 
                end 
                y = y + 30
                row_count = row_count + 1
            end
        end
    end 

    class Plot < Widget
        attr_accessor :points
        attr_accessor :visible_range
        attr_accessor :display_grid
        attr_accessor :display_lines
        attr_accessor :zoom_level

        def initialize(x, y, width, height, font) 
            super x, y, color 
            set_font(font)
            set_dimensions(width, height)
            @display_grid = false
            @display_lines = true
            @data_set_hash = {}
            @grid_line_color = COLOR_CYAN
            @cursor_line_color = COLOR_DARK_GRAY 
            @zero_line_color = COLOR_BLUE 
            @zoom_level = 1
        end

        def increase_data_point_size 
            @data_set_hash.keys.each do |key|
                data_set = @data_set_hash[key]
                data_set.rendered_points.each do |point| 
                    point.increase_size 
                end
            end
        end 

        def decrease_data_point_size 
            @data_set_hash.keys.each do |key|
                data_set = @data_set_hash[key]
                data_set.rendered_points.each do |point| 
                    point.decrease_size 
                end
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
            @data_set_hash.keys.each do |key|
                data_set = @data_set_hash[key]
                puts "Calling derive values on #{key}"
                data_set.derive_values(range, @data_set_hash)
            end
        end 

        def range_set?
            not @visible_range.nil?
        end 

        def is_on_screen(point) 
            point.x >= @visible_range.left_x and point.x <= @visible_range.right_x and point.y >= @visible_range.bottom_y and point.y <= @visible_range.top_y
        end 

        def add_data_set(data_set)
            if range_set?
                @data_set_hash[data_set.name] = data_set
                data_set.clear_rendered_points
                data_set.derive_values(@visible_range, @data_set_hash)
                data_set.data_points.each do |point|
                    if is_on_screen(point) 
                        data_set.add_rendered_point PlotPoint.new(draw_x(point.x), draw_y(point.y), data_set.color, data_set.data_point_size)
                    end
                end
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

        def x_pixel_to_screen(x)
            @x + x
        end

        def y_pixel_to_screen(y)
            @y + y
        end

        def draw_x(x)
            x_pixel_to_screen(x_val_to_pixel(x)) 
        end 

        def draw_y(y)
            y_pixel_to_screen(y_val_to_pixel(y)) 
        end 

        def render
            @data_set_hash.keys.each do |key|
                data_set = @data_set_hash[key]
                if data_set.visible
                    data_set.rendered_points.each do |point| 
                        point.draw 
                    end 
                    if @display_lines 
                        display_lines_for_point_set(data_set.rendered_points) 
                    end
                end
            end
            if @display_grid and range_set?
                display_grid_lines
            end
        end

        def display_lines_for_point_set(points) 
            if points.length > 1
                points.inject(points[0]) do |last, the_next|
                    Gosu::draw_line last.x, last.y, last.color,
                                    the_next.x, the_next.y, last.color, Z_ORDER_GRAPHIC_ELEMENTS
                    the_next
                end
            end
        end

        def display_grid_lines
            # TODO this is bnot working well for large ranges with the given increment of 1
            # We don't want to draw hundreds of grid lines
            grid_widgets = []

            grid_x = @visible_range.left_x
            grid_y = @visible_range.bottom_y + 1
            while grid_y < @visible_range.top_y
                dx = draw_x(grid_x)
                dy = draw_y(grid_y)
                last_x = draw_x(@visible_range.right_x)
                color = @grid_line_color
                if grid_y == 0 and grid_y != @visible_range.bottom_y.to_i
                    color = @zero_line_color
                end
                grid_widgets << Line.new(dx, dy, last_x, dy, color) 
                grid_y = grid_y + 1
            end
            grid_x = @visible_range.left_x + 1
            grid_y = @visible_range.bottom_y
            while grid_x < @visible_range.right_x
                dx = draw_x(grid_x)
                dy = draw_y(grid_y)
                last_y = draw_y(@visible_range.top_y)
                color = @grid_line_color
                if grid_x == 0 and grid_x != @visible_range.left_x.to_i
                    color = @zero_line_color 
                end
                grid_widgets << Line.new(dx, dy, dx, last_y, color) 
                grid_x = grid_x + 1
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
            draw_background(Z_ORDER_OVERLAY_BACKGROUND)
            draw_shadow(COLOR_GRAY)
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
                                    Z_ORDER_GRAPHIC_ELEMENTS
                        end
                    end
                end 
            end
        end 
    end
end
