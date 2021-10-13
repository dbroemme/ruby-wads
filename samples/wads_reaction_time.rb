require 'gosu'
require_relative '../lib/wads'

include Wads 

AVERAGE_RESPONSE_TIME = 284.to_f     # Per humanbenchmark.com, in milliseconds
GAME_STATE_PROMPT_TO_START = 0
GAME_STATE_RED = 1
GAME_STATE_YELLOW = 2
GAME_STATE_GREEN = 3
GAME_STATE_OVER = 4


class ReactionTimeApp < WadsApp
    def initialize
        super(600, 400, "Reaction Time Game", ReactionTimeDisplay.new)
    end 
end

class ReactionTimeDisplay < Widget
    def initialize
        super(0, 0, 600, 400)
        set_layout(LAYOUT_HEADER_CONTENT, {ARG_DESIRED_HEIGHT => 60})
        disable_border
        @next_light_count = 0
        @messages = []
        @font = Gosu::Font.new(22)
        @red_light = Gosu::Image.new("media/RedLight.png")
        @yellow_light = Gosu::Image.new("media/YellowLight.png")
        @green_light = Gosu::Image.new("media/GreenLight.png")
        #  game state            0           1           2              3             4
        #  state                 Prompt      Red         Yellow         Green         Game over
        @traffic_light_images = [@red_light, @red_light, @yellow_light, @green_light, @green_light]
        @traffic_light_color = GAME_STATE_PROMPT_TO_START

        add_panel(SECTION_NORTH).get_layout.add_text("Reaction Time Game",
                                                     { ARG_TEXT_ALIGN => TEXT_ALIGN_CENTER,
                                                       ARG_USE_LARGE_FONT => true})
        
        content_panel = get_layout.add_max_panel({ARG_LAYOUT => LAYOUT_EAST_WEST,
                                                  ARG_SECTION => SECTION_CENTER,
                                                  ARG_THEME => WadsDarkRedBrownTheme.new,
                                                  ARG_PANEL_WIDTH => 140})
        @traffic_light_image = content_panel.get_layout.add_image(@red_light,
                                                 {ARG_SECTION => SECTION_WEST})

        left_side_panel = content_panel.add_panel(SECTION_EAST)
        left_side_panel.disable_border
        @start_button = left_side_panel.get_layout.add_button("Click to play") do 
            handle_button_click
        end
        @messages = left_side_panel.get_layout.add_document("")
    end 

    def handle_update update_count, mouse_x, mouse_y
        @traffic_light_image.img = @traffic_light_images[@traffic_light_color]

        if @traffic_light_color == GAME_STATE_PROMPT_TO_START or @traffic_light_color == GAME_STATE_OVER
            @start_button.visible = true

        elsif @traffic_light_color == GAME_STATE_RED or
              @traffic_light_color == GAME_STATE_YELLOW or 
              @traffic_light_color == GAME_STATE_GREEN
            @messages.lines = ["Hit the space bar when the light turns green"]
            @start_button.visible = false
            if @mark_time.nil?
                @mark_time = Time.now
                @next_light_count = update_count + 60 + rand(100)
            end
            next_traffic_light unless update_count < @next_light_count
        end  
    end

    def handle_button_click
        if @traffic_light_color == GAME_STATE_PROMPT_TO_START or @traffic_light_color == GAME_STATE_OVER
            @messages.lines = []
            next_traffic_light
        end
    end

    def handle_key_press id, mouse_x, mouse_y
        return WidgetResult.new(true) if id == Gosu::KbEscape

        if id == Gosu::KbSpace
            if @traffic_light_color < GAME_STATE_YELLOW 
                next_traffic_light
            elsif @traffic_light_color == GAME_STATE_YELLOW 
                @traffic_light_color = GAME_STATE_OVER
                @messages.lines = ["Sorry, you were too early"]
            elsif @traffic_light_color == GAME_STATE_GREEN
                time_since_green = ((Time.now - @mark_time) * 1000.to_f).round(3)
                @messages.lines = ["Response time: #{time_since_green} ms"]
                diff_from_average = (((time_since_green - AVERAGE_RESPONSE_TIME) / AVERAGE_RESPONSE_TIME) * 100).round
                if diff_from_average > 0
                    @messages.lines << "#{diff_from_average}% slower than the average human"
                elsif diff_from_average < 0
                    @messages.lines << "#{-diff_from_average}% faster than the average human"
                else 
                    @messages.lines << "Wow, that is exactly the human average."
                end 
                @traffic_light_color = GAME_STATE_OVER
            end 
        end
    end

    def next_traffic_light
        if @traffic_light_color == GAME_STATE_OVER
            @traffic_light_color = GAME_STATE_RED
        elsif @traffic_light_color < GAME_STATE_OVER
            @traffic_light_color = @traffic_light_color + 1
        else 
          puts "next light from #{@traffic_light_color}"
        end
        @mark_time = nil
    end
end

ReactionTimeApp.new.show
