require 'hstatic/version'
require 'hstatic/app'

require 'yaml/store'

module Hstatic
  class App
    def self.launch(argv)
      if argv.any?
        require 'optparse'
        OptionParser.new do |op|
          op.on('-o host',
                'specify host (default is localhost)') { |val| set :bind, val }

          op.on('-p port',   '--port port',
                'set the port (default is 4567)') do |val|
            @port_set = true
            set :port, Integer(val)
          end

          op.on('-s server',
                'specify server (default is thin)') { |val| set :server, val }

          op.on('-x',
                'turn on the mutex lock (default is off)') { set :lock, true }

          op.on('-v', '--version', 'show version') do
            puts "hstatic tool: v#{VERSION}"
            exit
          end
        end.parse!(ARGV.dup)
      end

      launches_file = File.join ENV['HOME'], '.cache/hstatic_launches'
      @launches = Psych::Store.new launches_file, true
      @launches.transaction do
        set :port, @launches[Dir.pwd] || 4567 unless @port_set
        @launches[Dir.pwd] = settings.port
      end

      # Processing path and port
      pid_file = File.join(Dir.tmpdir, 'hstatic.pid')
      File.open(pid_file, File::CREAT | File::APPEND | File::RDWR) do |f|
        f.readlines.each do |line|
          instances = line.strip.split(':')
          if instances[1] == settings.port.to_s
            puts 'hstatic instance running already on the same port. Exiting'
            exit
          end
        end
        f.write "#{Dir.pwd}:#{settings.port}\n"
      end

      run!

      # Removing path:port from pid_file
      if File.exists? pid_file
        instances = File.open(pid_file, File::RDONLY) do |f|
          f.readlines.map do |line|
            pair = line.strip.split(':')
            pair unless pair[0] == Dir.pwd && pair[1] == settings.port.to_s
          end.compact
        end

        File.open(pid_file, File::WRONLY | File::TRUNC) do |f|
          instances.each do |pair|
            f.write "#{pair[0]}:#{pair[1]}\n"
          end
        end

        File.unlink pid_file unless instances.length > 0
      end
    end
  end
end
