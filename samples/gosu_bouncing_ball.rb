require 'gosu'
 
class AppWindow < Gosu::Window
  def initialize
    super(800, 600)
    self.caption = 'Bouncing Ball'
    @img = Gosu::Image.new("media/CircleYellow.png")
    @x = 400
    @y = 300
    @delta_x = 2
    @delta_y = 2
  end
 
  def update 
    @x = @x + @delta_x
    @y = @y + @delta_y
    if @x < 0
      @delta_x = 2
    elsif @x > 800 - @img.width
      @delta_x = -2
    end
    if @y < 0
      @delta_y = 2
    elsif @y > 600 - @img.height
      @delta_y = -2
    end
  end 

  def draw
    @img.draw @x, @y, 1
  end
end
 
AppWindow.new.show
