require 'gosu'

module Wads

class TextField < Gosu::TextInput
  # Some constants that define our appearance.
  INACTIVE_COLOR  = 0xcc666666
  ACTIVE_COLOR    = 0xcc85929e 
  SELECTION_COLOR = 0xcc0000ff
  CARET_COLOR     = 0xffffffff
  PADDING = 5
  
  attr_reader :x, :y
  attr_accessor :base_z
  attr_accessor :old_value
  
  def initialize(x, y, original_text, default_width)
    super()
    
    @x = x
    @y = y
    @window = WadsConfig.instance.get_window
    @font = WadsConfig.instance.current_theme.font
    @default_width = default_width
    @base_z = 0
    self.text = original_text
    @old_value = self.text
  end
  
  def draw
    # Depending on whether this is the currently selected input or not, change the
    # background's color.
    if @window.text_input == self then
      background_color = ACTIVE_COLOR
    else
      background_color = INACTIVE_COLOR
    end
    @window.draw_quad(x - PADDING,         y - PADDING,          background_color,
                      x + width + PADDING, y - PADDING,          background_color,
                      x - PADDING,         y + height + PADDING, background_color,
                      x + width + PADDING, y + height + PADDING, background_color, @base_z + 9)
    
    # Calculate the position of the caret and the selection start.
    pos_x = x + @font.text_width(self.text[0...self.caret_pos])
    sel_x = x + @font.text_width(self.text[0...self.selection_start])
    
    # Draw the selection background, if any; if not, sel_x and pos_x will be
    # the same value, making this quad empty.
    @window.draw_quad(sel_x, y,          SELECTION_COLOR,
                      pos_x, y,          SELECTION_COLOR,
                      sel_x, y + height, SELECTION_COLOR,
                      pos_x, y + height, SELECTION_COLOR, @base_z + 10)

    # Draw the caret; again, only if this is the currently selected field.
    if @window.text_input == self then
      @window.draw_line(pos_x, y,          CARET_COLOR,
                        pos_x, y + height, CARET_COLOR, @base_z + 10)
    end

    # Finally, draw the text itself!
    @font.draw_text(self.text, x, y, @base_z + 10)
  end

  # This text field grows with the text that's being entered.
  # (Usually one would use clip_to and scroll around on the text field.)
  def width
    text_width = @font.text_width(self.text)
    if text_width > @default_width
      return text_width 
    end 
    @default_width
  end
  
  def height
    @font.height
  end

  # Hit-test for selecting a text field with the mouse.
  def under_point?(mouse_x, mouse_y)
    mouse_x > x - PADDING and mouse_x < x + width + PADDING and
      mouse_y > y - PADDING and mouse_y < y + height + PADDING
  end

  def contains_click(mouse_x, mouse_y)
    under_point?(mouse_x, mouse_y)
  end
  
  # Tries to move the caret to the position specifies by mouse_x
  def move_caret(mouse_x)
    # Test character by character
    1.upto(self.text.length) do |i|
      if mouse_x < x + @font.text_width(text[0...i]) then
        self.caret_pos = self.selection_start = i - 1;
        return
      end
    end
    # Default case: user must have clicked the right edge
    self.caret_pos = self.selection_start = self.text.length
  end

  def button_down(id, mouse_x, mouse_y)
    if id == Gosu::MsLeft
      move_caret(mouse_x)
    else 
      if @old_value == self.text
        # nothing to do
      else 
        @old_value = self.text
        return WidgetResult.new(false, EVENT_TEXT_INPUT, [self.text])
      end
    end
  end 

  def button_up(id, mouse_x, mouse_y)
    # empty base implementation
  end 

  def update(update_count, mouse_x, mouse_y)
    # empty base implementation
  end

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
end

end # end wads module
