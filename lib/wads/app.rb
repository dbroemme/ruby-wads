require 'gosu'
require_relative 'widgets'

module Wads
    #
    # The WadsApp class provides a simple starting point to quickly build a native
    # Ruby application using Gosu as an underlying library. It provides all the necessary
    # hooks to get started. All you need to do is supply the parent Wads widget using
    # the set_display(widget) method. See one of the Wads samples for example usage.
    #
    class WadsApp < Gosu::Window
        def initialize(width, height, caption, widget)
            super(width, height)
            self.caption = caption
            @update_count = 0
            set_display(widget) 
        end 

        #
        # This method must be invoked with any Wads::Widget instance. It then handles
        # delegating all events and drawing all child widgets.
        #
        def set_display(widget) 
            @main_widget = widget 
        end

        def get_display
            @main_widget
        end

        def update
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
