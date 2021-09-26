require 'gosu'
require_relative '../lib/wads'

include Wads 

class ThemeTestApp < WadsApp
    def initialize
        super(800, 600, "Wads Theme Test App")
        set_display(ThemeTestDisplay.new)
    end 
end

class ThemeTestDisplay < Widget
    def initialize
        super(0, 0, 800, 600)
        set_layout(LAYOUT_TOP_MIDDLE_BOTTOM)
        disable_border

        # Example of using the layout for absolute positioning
        # and then relative positioning of a child widget
        # within that
        image = get_layout.add_image("./media/Banner.png", { ARG_SECTION => LAYOUT_TOP})
        image.add_text("Banner", 10, 10)

        get_layout.add_text("Hello", { ARG_SECTION => LAYOUT_CENTER})
        get_layout.add_text("There", { ARG_SECTION => LAYOUT_CENTER})
        get_layout.add_button("Test Button", { ARG_SECTION => LAYOUT_CENTER}) do 
            puts "User hit the test button"
        end

        table = get_layout.add_table(["A", "B", "C"], 4, { ARG_SECTION => LAYOUT_CENTER})
        table.add_row(["These", "are", "values in row 1"])
        table.add_row(["These", "are", "values in row 2"])
        table.add_row(["These", "are", "values in row 3"])
        table.add_row(["These", "are", "values in row 4"])

        panel = get_layout.add_horizontal_panel({ ARG_SECTION => LAYOUT_BOTTOM})
        panel.add_button("Exit", 0, panel.height - 30) do
            WidgetResult.new(true)
        end
        panel.center_children
    end 
end

ThemeTestApp.new.show