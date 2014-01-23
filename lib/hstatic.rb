require "hstatic/version"
require "hstatic/app"

module Hstatic
  class App
    def self.launch(argv)
      if argv.any?
        require 'optparse'
        OptionParser.new { |op|
          op.on("-p port",   "--port port", "set the port (default is 4567)")                { |val| set :port, Integer(val) }
          op.on("-s server",                "specify rack server/handler (default is thin)") { |val| set :server, val }
          op.on("-x",                       "turn on the mutex lock (default is off)")       {       set :lock, true }

          op.on("-v",        "--version",   "show version") do
            puts "hstatic tool: v#{VERSION}"
            exit
          end
        }.parse!(ARGV.dup)
      end

      run!
    end
  end
end
