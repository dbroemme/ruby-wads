require 'gosu'

AVERAGE_RESPONSE_TIME = 284.to_f     # Per humanbenchmark.com, in milliseconds
GAME_STATE_PROMPT_TO_START = 0
GAME_STATE_RED = 1
GAME_STATE_YELLOW = 2
GAME_STATE_GREEN = 3
GAME_STATE_OVER = 4

class AppWindow < Gosu::Window
  def initialize
    super(600, 300)
    self.caption = 'Reaction Time Game'
    @update_count = 0
    @next_light_count = 0
    @messages = []
    @font = Gosu::Font.new(32)
    @red_light = Gosu::Image.new("media/CircleRed.png")
    @yellow_light = Gosu::Image.new("media/CircleYellow.png")
    @green_light = Gosu::Image.new("media/CircleGreen.png")
    #  game state            0           1           2              3             4
    #  state                 Prompt      Red         Yellow         Green         Game over
    @traffic_light_images = [@red_light, @red_light, @yellow_light, @green_light, @green_light]
    @traffic_light_color = GAME_STATE_PROMPT_TO_START
  end
 
  def update
    @update_count = @update_count + 1
    @traffic_light_image = @traffic_light_images[@traffic_light_color]

    # Once the game is started, the lights progress automatically until green
    if @traffic_light_color > GAME_STATE_PROMPT_TO_START
      next_traffic_light unless @update_count < @next_light_count
      @button_text = "Click when the light turns green" unless @traffic_light_color > GAME_STATE_GREEN
    end
  end

  def draw
    @font.draw_text("Reaction Time Game", 180, 10, 1)
    @traffic_light_image.draw(248, 60, 1)
    
    if @traffic_light_color == GAME_STATE_PROMPT_TO_START
      @font.draw_text("Press 'p' to play", 200, 200, 1)
    elsif @traffic_light_color == GAME_STATE_OVER
      @font.draw_text("Press 'p' to play again", 50, 200, 1)
    else 
      draw_button(@button_text) unless @button_text.nil?
    end

    y = 232
    @messages.each do |msg|
      @font.draw_text(msg, 50, y, 1)
      y = y + 32
    end
  end

  def button_down id
    close if id == Gosu::KbEscape 

    if @traffic_light_color == GAME_STATE_PROMPT_TO_START or @traffic_light_color == GAME_STATE_OVER
      if id == Gosu::KbP
        next_traffic_light
      end
      return
    end
    
    if id == Gosu::MsLeft and button_contains_click
      if @traffic_light_color < GAME_STATE_YELLOW 
        next_traffic_light
      elsif @traffic_light_color == GAME_STATE_YELLOW 
        @traffic_light_color = GAME_STATE_OVER
        @messages = ["Sorry, you were too early"]
        @button_text = "Click to play again"
      elsif @traffic_light_color == GAME_STATE_GREEN
        @button_text = nil
        time_since_green = ((Time.now - @mark_time) * 1000.to_f).round(3)
        @messages = ["Response time: #{time_since_green} ms"]
        diff_from_average = (((time_since_green - AVERAGE_RESPONSE_TIME) / AVERAGE_RESPONSE_TIME) * 100).round
        if diff_from_average > 0
          @messages << "#{diff_from_average}% slower than the average human"
        elsif diff_from_average < 0
          @messages << "#{-diff_from_average}% faster than the average human"
        else 
          @messages << "Wow, that is exactly the human average."
        end 
        @button_text = "Click to play again"
        @traffic_light_color = GAME_STATE_OVER
      else 
        @traffic_light_color = GAME_STATE_PROMPT_TO_START
        @messages = []
      end 
    end
  end

  def next_traffic_light 
    return unless @traffic_light_color < GAME_STATE_GREEN
    @traffic_light_color = @traffic_light_color + 1
    @mark_time = Time.now
    @next_light_count = @update_count + 60 + rand(100)
  end

  def button_contains_click 
    mouse_x > 100 and mouse_x < 500 and mouse_y > 198 and mouse_y < 232
  end 

  def draw_button(text)
    text_width = @font.text_width(text)
    draw_box(100, 198, 500, 232)
    text_x = (600 - text_width) / 2
    @font.draw_text(@button_text, text_x, 200, 1)
  end 

  def draw_box(x1, y1, x2, y2, color = Gosu::Color::WHITE)
    Gosu::draw_line x1, y1, color, x2, y1, color, 1
    Gosu::draw_line x1, y1, color, x1, y2, color, 1
    Gosu::draw_line x1, y2, color, x2, y2, color, 1
    Gosu::draw_line x2, y1, color, x2, y2, color, 1
  end
end
 
AppWindow.new.show
