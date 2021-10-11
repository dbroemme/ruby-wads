require 'gosu'
 
class GameWindow < Gosu::Window
  def initialize
    super(400, 300)
    self.caption = 'Hello World App'
    @font = Gosu::Font.new(24)
  end
 
  def draw
    @font.draw_text("Hello World", 144, 120, 1)
  end
end
 
window = GameWindow.new
window.show
