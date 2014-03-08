require 'sinatra/base'
require 'haml'
require 'slim'

# Main gem namespace
module Hstatic
  BASEDIR = File.join(File.dirname(__FILE__), '..', '..')

  # Main Sinatra Application
  #
  # It handles the publishing index pages and instantiation of
  # templates files
  class App < Sinatra::Base
    configure do
      set :views, File.join(BASEDIR, 'views')
      set :environment, :development
      enable :logging
    end

    helpers do
      def dynamic_size(size)
        case
        when size > 2**40
          sprintf('%5.2f', size / 2**40) << ' GB'
        when (size / 2**20) > 0.1
          sprintf('%5.2f', size / 2**20) << ' MB'
        else
          sprintf('%5.2f', size / 2**10) << ' kB'
        end
      end
    end

    # Finally every Tilt supported template is rendered
    helpers do
      def render_file(path)
        if (template = Tilt[path])
          ext, _ =  Tilt.mappings.find { |k, v| v.include? template }

          if self.respond_to? ext.to_sym
            method = self.method(ext)
            basename = File.basename(path, File.extname(path)).to_sym

            return method.call basename, :views => File.dirname(path)
          end
        end

        send_file path
      end
    end

    # Going around bootstrap
    get '/.res/bootstrap.min.css' do
      send_file(File.join(BASEDIR, 'res/bootstrap.min.css'))
    end

    get '/.res/style.css' do
      send_file(File.join(BASEDIR, 'res/style.css'))
    end

    get '/.res/jquery-1.10.2.min.js' do
      send_file(File.join(BASEDIR, 'res/jquery-1.10.2.min.js'))
    end

    get '/fonts/glyphicons-halflings-regular.woff' do
      send_file(File.join(BASEDIR, 'res/glyphicons-halflings-regular.woff'))
    end

    get '/fonts/glyphicons-halflings-regular.ttf' do
      send_file(File.join(BASEDIR, 'res/glyphicons-halflings-regular.ttf'))
    end

    get '/fonts/glyphicons-halflings-regular.svg' do
      send_file(File.join(BASEDIR, 'res/glyphicons-halflings-regular.svg'))
    end

    # Catch all route
    get '*' do
      path = File.expand_path(File.join(Dir.pwd, unescape(request.path_info)))

      if File.file? path
        render_file path
      elsif File.exists?(File.expand_path(File.join(path, 'index.html')))
        redirect(File.join(request.path_info, 'index.html'))
      elsif File.directory? path
        # Building data
        @folders = Array.new
        @files = Array.new
        @parent = File.dirname(request.path_info)

        Dir.foreach(path) do |entry|
          next if entry == '.' || entry == '..'

          url_base = File.join('/', request.path_info)
          link = File.join(url_base, entry)
          filename = File.expand_path(File.join(path, entry))

          if File.directory? filename
            @folders << { :name => entry, :href => link }
          else
            @files << { :name => unescape(entry),
                        :size => dynamic_size(File.size(filename)),
                        :href => link }
          end
        end

        # Render view
        haml :index
      else
        [404, 'File not found']
      end
    end
  end
end
