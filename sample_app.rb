require_relative "lib/wads/app"
require 'tty-option'

class SampleAppCommand 
    include TTY::Option

    usage do 
        program "run-sample-app"

        command ""

        example <<~EOS
        Run the sample app to analyze stock market data
          $ ./run-sample-app
        EOS

    end

    flag :help do 
        short "-h"
        long "--help"
        desc "Print usage"
    end 

    flag :stocks do 
        short "-s"
        long "--stocks"
        desc "Run sample stocks analysis"
    end 

    flag :lottery do 
        short "-l"
        long "--lottery"
        desc "Run sample analysis of lottery numbers"
    end 

    flag :gui do 
        short "-g"
        long "--gui"
        desc "Display the results using GUI widgets instead of console text"
    end 

    def run 
        if params[:help]
            print help 
            exit 
        end 
        params.to_h 
    end
end 

WadsSampleApp.new.parse_opts_and_run
