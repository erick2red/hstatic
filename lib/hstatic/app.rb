require 'sinatra/base'
require 'haml'

module Hstatic
  BASEDIR = File.join(File.dirname(__FILE__), '..', '..')

  class App < Sinatra::Base
    configure do
      set :views, File.join(BASEDIR, 'views')
      set :environment, :production
    end

    helpers do
      def dynamic_size(size)
        if size > Math.ldexp(1, 40)
          sprintf("%5.2f", size / Math.ldexp(1, 40)) + ' GB'
        elsif (size / Math.ldexp(1, 20)) > 0.1
          sprintf("%5.2f", size / Math.ldexp(1, 20)).to_s + ' MB'
        else
          sprintf("%5.2f", size / Math.ldexp(1, 10)).to_s + ' kB'
        end
      end
    end

    # For now just render HAML
    helpers do
      def render_file(path)
        case File.extname(path)
        when ".haml"
          basename = File.basename(path, File.extname(path)).to_sym
          haml(basename, { :views => File.dirname(path) })
        else
          send_file path
        end
      end
    end

    # Going around bootstrap
    get '/.res/bootstrap.min.css' do
      send_file(File.join(BASEDIR, 'res/bootstrap.min.css'))
    end

    get '/.res/style.css' do
      send_file(File.join(BASEDIR, 'res/style.css'))
    end

    get '/.res/jquery.min.js' do
      send_file(File.join(BASEDIR, 'res/jquery.min.js'))
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

    get '*' do
      path = File.expand_path(File.join(Dir.pwd, unescape(request.path_info)))

      if File.file? path
        render_file path
      elsif File.exists?(File.expand_path(File.join(path, 'index.html')))
        redirect(File.join(request.path_info, 'index.html'))
      elsif File.directory? path
        # Bulding data
        @folders = Array.new
        @files = Array.new
        @parent = File.dirname(request.path_info)

        Dir.foreach(path) do |entry|
          next if entry == "." || entry == ".."

          url_base = File.join("/", request.path_info)
          link = File.join(url_base, entry)
          filename = File.expand_path(File.join(path, entry))

          if File.directory? filename
            @folders << { name: entry, href: link }
          else
            @files << { name: unescape(entry),
                        size: dynamic_size(File.size(filename)),
                        href: link }
          end
        end

        # Render view
        haml :index
      else
        'not found'
      end
    end
  end
end
