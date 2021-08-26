require 'gosu'
require_relative 'data_structures'
require_relative 'widgets'
require_relative 'version'

include Wads

class WadsSampleApp < Gosu::Window
    
    STOCKS_DATA_FILE = "./data/NASDAQ.csv"
    LOTTERY_DATA_FILE = "./data/Pick4_12_21_2020.txt"

    def initialize
        super(800, 600)
        self.caption = "Wads Sample App"
        @font = Gosu::Font.new(32)
        @title_font = Gosu::Font.new(38)
        @version_font = Gosu::Font.new(22)
        @small_font = Gosu::Font.new(22)
        @banner_image = Gosu::Image.new("./media/Banner.png")
        @display_widget = nil
    end 

    def parse_opts_and_run 
        # Make help the default output if no args are specified
        if ARGV.length == 0
            ARGV[0] = "-h"
        end

        opts = SampleAppCommand.new.parse.run
        if opts[:stocks]
            stats = process_stock_data
            if opts[:gui]
                @display_widget = SampleStocksDisplay.new(@small_font, stats)
                show
            else 
                stats.report(Date::DAYNAMES[1..5])
            end
        
        elsif opts[:lottery] 
            process_lottery_data
        else
            puts " "
            puts "Select one of the following sample analysis options"
            puts "-s   Run sample stocks analysis"
            puts "-l   Run sample analysis of lottery numbers"
            puts " "
            exit
        end

    end

    def update 
        # TODO
    end 
    
    def draw
        draw_banner
        @display_widget.draw
    end 

    def draw_banner 
        @banner_image.draw(1,1,1,0.9,0.9)
        @title_font.draw_text("Wads Sample App", 10, 20, 2, 1, 1, Gosu::Color::WHITE)
        @version_font.draw_text("Version #{Wads::VERSION}", 13, 54, 2, 1, 1, Gosu::Color::WHITE)
    end

    def button_down id
        close if id == Gosu::KbEscape
        # Delegate button events to the primary display widget
        result = @display_widget.button_down id, mouse_x, mouse_y
        if result.close_widget
            close
        end
    end

    def process_stock_data 
        # The data file comes from https://finance.yahoo.com
        # The format of this file is as follows:
        #
        # Date,Open,High,Low,Close,Adj Close,Volume
        # 2000-01-03,4186.189941,4192.189941,3989.709961,4131.149902,4131.149902,1510070000
        # 2000-01-04,4020.000000,4073.250000,3898.229980,3901.689941,3901.689941,1511840000
        # ...
        # 2020-12-30,12906.509766,12924.929688,12857.759766,12870.000000,12870.000000,5292210000
        # 2020-12-31,12877.089844,12902.070313,12821.230469,12888.280273,12888.280273,4771390000
        
        stats = Stats.new("NASDAQ")
        previous_close = nil
        
        puts "Read the data file #{STOCKS_DATA_FILE}"
        File.readlines(STOCKS_DATA_FILE).each do |line|
            line = line.chomp  # remove the carriage return

            # Ignore header and any empty lines, process numeric data lines
            if line.length > 0 and line[0].match(/[0-9]/)
                values = line.split(",")
                date = Date.strptime(values[0], "%Y-%m-%d")
                weekday = Date::DAYNAMES[date.wday]

                open_value = values[1].to_f
                close_value = values[4].to_f

                if previous_close.nil?
                    # Just use the first day to set the baseline
                    previous_close = close_value
                else 
                    change_from_previous_close = close_value - previous_close
                    change_intraday = close_value - open_value
                    change_overnight = open_value - previous_close
                    
                    change_percent = change_from_previous_close / previous_close

                    stats.add(weekday, change_percent)
                    stats.add("#{weekday} prev close", change_from_previous_close)
                    stats.add("#{weekday} intraday", change_intraday)
                    stats.add("#{weekday} overnight", change_overnight)

                    previous_close = close_value
                end
            end
        end

        stats
    end
end

class SampleStocksDisplay < Widget
    attr_accessor :stats

    def initialize(font, stats)
        super(10, 100, COLOR_HEADER_BRIGHT_BLUE)
        set_dimensions(780, 500)
        set_font(font)
        add_child(Document.new(sample_content, x + 5, y + 5, @width, @height, @font))
        @exit_button = Button.new("Exit", 380, bottom_edge - 30, @font)
        add_child(@exit_button)

        @stats = stats
        @data_table = SingleSelectTable.new(@x + 5, @y + 100,    # top left corner
                                            770, 200,            # width, height
            ["Day", "Min", "Avg", "StdDev", "Max", "p10", "p90"], # column headers
                                            @font, COLOR_WHITE)   # font and text color
        @data_table.selected_color = COLOR_LIGHT_GRAY
        Date::DAYNAMES[1..5].each do |day|
            min = format_percent(@stats.min(day))
            avg = format_percent(@stats.average(day))
            std = format_percent(@stats.std_dev(day))
            max = format_percent(@stats.max(day))
            p10 = format_percent(@stats.percentile(day, 0.1))
            p90 = format_percent(@stats.percentile(day, 0.90))
            @data_table.add_row([day, min, avg, std, max, p10, p90], COLOR_HEADER_BRIGHT_BLUE)
        end
        add_child(@data_table)
        @selection_text = nil
    end 

    def format_percent(val)
        "#{(val * 100).round(3)}%"
    end

    def sample_content
        <<~HEREDOC
          This sample stock analysis uses NASDAQ data from https://finance.yahoo.com looking
          at closing data through the years 2000 to 2020. The percent gain or loss is broken
          down per day, as shown in the table below.
        HEREDOC
    end

    def render 
        if @selection_text
            @selection_text.draw 
        end
    end 

    def button_down id, mouse_x, mouse_y
        if id == Gosu::MsLeft
            if @exit_button.contains_click(mouse_x, mouse_y)
                return WidgetResult.new(true)
            elsif @data_table.contains_click(mouse_x, mouse_y)
                val = @data_table.set_selected_row(mouse_y, 0)
                if val.nil?
                    # nothing to do
                else
                    @selection_text = Text.new("You selected #{val}, a great day!",
                                               x + 5, y + 400, @font)
                end    
            end 
        end 
        WidgetResult.new(false)
    end 
end