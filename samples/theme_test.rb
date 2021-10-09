require 'gosu'
require_relative '../lib/wads'

include Wads 

class ThemeTestApp < WadsApp
    def initialize
        super(800, 600, "Wads Theme Test App", ThemeTestDisplay.new)
    end 
end

class ThemeTestDisplay < Widget
    def initialize
        super(0, 0, 800, 600)
        disable_border

        if ARGV.length == 0
            render_basic_widgets
        elsif ARGV[0] == "-h" or ARGV[0] == "h" or ARGV[0] == "help"
            puts "Wads Theme Tester"
            puts " "
            display_help 
        elsif ARGV[0] == "border"
            render_border_layout
        elsif ARGV[0] == "three"
            render_top_middle_bottom_layout
        elsif ARGV[0] == "header"
            render_header_layout
        elsif ARGV[0] == "footer"
            render_footer_layout
        elsif ARGV[0] == "vertical"
            render_vertical_layout
        elsif ARGV[0] == "horizontal"
            render_horizontal_layout
        elsif ARGV[0] == "eastwest"
            render_east_west_layout
        elsif ARGV[0] == "plot"
            render_plot
        elsif ARGV[0] == "form"
            render_form
        elsif ARGV[0] == "overlay"
            render_overlay
        else 
            puts "Argument #{ARGV[0]} is invalid."
            display_help 
        end
    end 

    def display_help 
        puts "Valid arguments are:"
        puts "  border     show BorderLayout"
        puts "  three      show TopMiddleBottomLayout"
        puts "  header     show HeaderContentLayout"
        puts "  footer     show ContentFooterLayout"
        puts "  vertical   show VerticalColumnLayout"
        puts "  eastwest   show EastWestLayout"
        puts "  plot       show a simple plot using HeaderContentLayout"
        puts "  form       test a form"
        puts "  overlay    show an overlay widget"
        exit
    end 

    def render_basic_widgets
        set_layout(LAYOUT_TOP_MIDDLE_BOTTOM)

        # Example of using the layout for absolute positioning
        # and then relative positioning of a child widget
        # within that
        image = get_layout.add_image("./media/Banner.png", { ARG_SECTION => SECTION_TOP})
        image.add_text("Banner", 10, 10)

        get_layout.add_text("Hello", { ARG_SECTION => SECTION_CENTER})
        get_layout.add_text("There", { ARG_SECTION => SECTION_CENTER})
        get_layout.add_button("Test Button", { ARG_SECTION => SECTION_CENTER}) do 
            puts "User hit the test button"
        end

        table = get_layout.add_multi_select_table(["A", "B", "C"], 4, { ARG_SECTION => SECTION_CENTER})
        table.add_row(["These", "are", "values in row 1"])
        table.add_row(["These", "are", "values in row 2"])
        table.add_row(["These", "are", "values in row 3"])
        table.add_row(["These", "are", "values in row 4"])

        panel = get_layout.add_horizontal_panel({ ARG_SECTION => SECTION_BOTTOM})
        panel.add_button("Exit", 380, panel.height - 30) do
            WidgetResult.new(true)
        end
    end

    def render_header_layout
        set_layout(LAYOUT_HEADER_CONTENT)

        header = get_layout.add_max_panel({ ARG_SECTION => SECTION_HEADER,
                                            ARG_THEME => WadsNatureTheme.new })
        header.get_layout.add_text("I am the header section",
                                   { ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER,
                                     ARG_USE_LARGE_FONT => true})

        main = get_layout.add_max_panel({ ARG_SECTION => SECTION_CONTENT,
                                          ARG_THEME => WadsNatureTheme.new })
        main.get_layout.add_document(sample_content)
        table = main.get_layout.add_multi_select_table(["A", "B", "C"], 4, { ARG_SECTION => SECTION_WEST})
        table.add_row(["Key1", "Value1", "ValueD"])
        table.add_row(["Key2", "Value2", "ValueE"])
        table.add_row(["Key3", "Value3", "ValueF"])
    end

    def render_border_layout
        set_layout(LAYOUT_BORDER)
        header = get_layout.add_max_panel({ ARG_SECTION => SECTION_NORTH})
        header.get_layout.add_text("I am the header section", { ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER})

        west = get_layout.add_vertical_panel({ ARG_SECTION => SECTION_WEST})
        west.get_layout.add_button("Do stuff") do 
            puts "Hit the do stuff button"
        end
        west.get_layout.add_button("More stuff") do 
            puts "Hit the more stuff button"
        end

        get_layout.add_document(sample_content, { ARG_SECTION => SECTION_CENTER})

        east = get_layout.add_vertical_panel({ ARG_SECTION => SECTION_EAST})
        east.get_layout.add_text("item1")
        east.get_layout.add_text("item2")

        footer = get_layout.add_max_panel({ ARG_SECTION => SECTION_SOUTH})
        footer.get_layout.add_text("I am the footer section", { ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER})
    end

    def render_top_middle_bottom_layout
        set_layout(LAYOUT_TOP_MIDDLE_BOTTOM)
        header = get_layout.add_max_panel({ ARG_SECTION => SECTION_TOP})
        header.get_layout.add_text("I am the header section", { ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER})

        get_layout.add_document(sample_content, { ARG_SECTION => SECTION_MIDDLE})

        footer = get_layout.add_max_panel({ ARG_SECTION => SECTION_BOTTOM})
        footer.get_layout.add_text("I am the footer section", { ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER})
    end

    def sample_content
        <<~HEREDOC
        This is the content section.
        A document can contain multi-line text.
        Typically you provide the content
        using a squiggly heredoc.
        HEREDOC
    end

    def render_footer_layout
        set_layout(LAYOUT_CONTENT_FOOTER)

        get_layout.add_document(sample_content, { ARG_SECTION => SECTION_CONTENT})

        footer = get_layout.add_max_panel({ ARG_SECTION => SECTION_FOOTER,
                                            ARG_THEME => WadsBrightTheme.new })
        footer.get_layout.add_text("I am the footer section", { ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER})
    end

    def render_vertical_layout 
        set_layout(LAYOUT_VERTICAL_COLUMN)
        get_layout.add_image("./media/Banner.png")
        get_layout.add_text("This is text below the image")
        get_layout.add_text("Each widget will get placed below the previous in a vertical column.")
    end

    def render_east_west_layout 
        set_layout(LAYOUT_EAST_WEST)
        table = get_layout.add_multi_select_table(["A", "B", ""], 4, { ARG_SECTION => SECTION_WEST})
        table.add_row(["Key1", "Value1"])
        table.add_row(["Key2", "Value2"])
        table.add_row(["Key3", "Value3"])

        get_layout.add_document(sample_content, { ARG_SECTION => SECTION_EAST})
    end

    def render_plot
        set_layout(LAYOUT_HEADER_CONTENT)

        header = get_layout.add_max_panel({ ARG_SECTION => SECTION_HEADER,
                                            ARG_THEME => WadsBrightTheme.new })
        # The zero x coord doesn't matter here because we center it below
        # Centering only adjusts the x coordinate
        header.add_text("This is a plot of sine (yellow) and cosine (pink) waves", 0, 35)
        header.center_children
        header.disable_border

        plot = get_layout.add_plot({ ARG_SECTION => SECTION_CONTENT})
        plot.define_range(VisibleRange.new(-5, 5, -5, 5))
        plot.enable_border
        x = -5
        while x < 5
            plot.add_data_point("Sine", x, Math.sin(x), COLOR_LIME)
            plot.add_data_point("Cosine", x, Math.cos(x), COLOR_PINK)
            x = x + 0.05
        end

        # Draw the 0 horizontal and vertical axes
        plot.add_child(Line.new(plot.draw_x(0), plot.draw_y(-5), plot.draw_x(0), plot.draw_y(5), COLOR_GRAY))
        plot.add_child(Line.new(plot.draw_x(-5), plot.draw_y(0), plot.draw_x(5), plot.draw_y(0), COLOR_GRAY))
    end

    def render_form
        set_layout(LAYOUT_CONTENT_FOOTER)

        content_panel = get_layout.add_max_panel({ ARG_SECTION => SECTION_CONTENT,
                                                   ARG_LAYOUT  => LAYOUT_EAST_WEST,
                                                   ARG_PANEL_WIDTH => 200 })

        label_panel = content_panel.add_panel(SECTION_WEST)
        label_panel.get_layout.add_text("First Name", { ARG_TEXT_ALIGN => TEXT_ALIGN_RIGHT})
        label_panel.get_layout.add_text("Middle Name", { ARG_TEXT_ALIGN => TEXT_ALIGN_RIGHT})
        label_panel.get_layout.add_text("Last Name", { ARG_TEXT_ALIGN => TEXT_ALIGN_RIGHT})

        field_panel = content_panel.add_panel(SECTION_EAST)
        @first_name = field_panel.get_layout.add_text_input(200)
        @middle_name = field_panel.get_layout.add_text_input(200)
        @last_name = field_panel.get_layout.add_text_input(200)

        footer_panel = get_layout.add_max_panel({ ARG_SECTION => SECTION_FOOTER})
        footer_panel.get_layout.add_button("Display Full Name", {ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER}) do
            footer_panel.get_layout.add_text("The full name is #{@first_name.text} #{@middle_name.text} #{@last_name.text}.")
        end
    end

    def render_overlay
        set_layout(LAYOUT_HEADER_CONTENT)

        header = get_layout.add_max_panel({ ARG_SECTION => SECTION_HEADER})
        header.get_layout.add_text("I am the header section", { ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER})

        main = get_layout.add_max_panel({ ARG_SECTION => SECTION_CONTENT})
        main.get_layout.add_document(sample_content)

        main.get_layout.add_button("Display InfoBox", {ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER}) do
            add_overlay(create_overlay_widget)
        end
    end

    def create_overlay_widget 
        InfoBox.new(100, 60, 600, 400, "Sample Overlay", overlay_content, { ARG_THEME => WadsBrightTheme.new})
    end

    def overlay_content
        <<~HEREDOC
        This is a sample overlay widget which typically
        you would use to display important information
        upon request. The InfoBox widget is used for
        this purpose.
        HEREDOC

    end
end

ThemeTestApp.new.show