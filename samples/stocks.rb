require 'gosu'
require_relative '../lib/wads'

include Wads 

class SampleStocksApp < WadsApp
    
    STOCKS_DATA_FILE = "./data/NASDAQ.csv"

    def initialize
        super(800, 600, "Wads Sample Stocks App", StocksDisplay.new(process_stock_data))
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

class StocksDisplay < Widget

    def initialize(stats)
        super(0, 0, 800, 600)
        set_layout(LAYOUT_TOP_MIDDLE_BOTTOM)

        image = get_layout.add_image("./media/Banner.png", { ARG_SECTION => SECTION_TOP})
        image.add_text("Wads Sample App", 10, 20, nil, true)
        image.add_text("Version #{Wads::VERSION}", 13, 54)

        get_layout.add_document(sample_content, { ARG_SECTION => SECTION_CENTER})

        panel = get_layout.add_horizontal_panel({ ARG_SECTION => SECTION_BOTTOM})
        panel.add_button("Exit", 0, panel.height - 30) do
            WidgetResult.new(true)
        end
        panel.center_children

        @data_table = get_layout.add_single_select_table(         
                ["Day", "Min", "Avg", "StdDev", "Max", "p10", "p90"], 5,
                { ARG_SECTION => SECTION_CENTER})
        Date::DAYNAMES[1..5].each do |day|
            min = format_percent(stats.min(day))
            avg = format_percent(stats.average(day))
            std = format_percent(stats.std_dev(day))
            max = format_percent(stats.max(day))
            p10 = format_percent(stats.percentile(day, 0.1))
            p90 = format_percent(stats.percentile(day, 0.90))
            @data_table.add_row([day, min, avg, std, max, p10, p90])
        end

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
        @selection_text.draw unless @selection_text.nil?
    end 

    def handle_mouse_down mouse_x, mouse_y
        if @data_table.contains_click(mouse_x, mouse_y)
            val = @data_table.set_selected_row(mouse_y, 0)
            if not val.nil?
                @selection_text = Text.new(relative_x(5), relative_y(500), "You selected #{val}, a great day!")
            end    
        end
    end 
end

WadsConfig.instance.set_current_theme(WadsAquaTheme.new)
SampleStocksApp.new.show
