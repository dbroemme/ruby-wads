require 'gosu'
require_relative 'widgets'

module Wads
    class WadsApp < Gosu::Window
        def initialize(width, height, caption = 'My App')
            super(width, height)
            self.caption = caption
            @update_count = 0
        end 

        def set_display(widget) 
            @main_widget = widget 
        end

        def get_display
            @main_widget
        end

        def update 
            if @main_widget.nil? 
                raise "Your app must call the set_display(widget) method in your constructor"
            end
            @main_widget.update(@update_count, mouse_x, mouse_y)
            @update_count = @update_count + 1
        end 
    
        def draw
            @main_widget.draw
        end

        def button_down id
            close if id == Gosu::KbEscape
            # Delegate button events to the primary display widget
            result = @main_widget.button_down id, mouse_x, mouse_y
            if not result.nil? and result.is_a? WidgetResult
                if result.close_widget
                    close
                end
            end
        end
    
        def button_up id
            @main_widget.button_up id, mouse_x, mouse_y
        end
    end 
end
