require 'pathname'
require 'sinatra/base'
require 'haml'
require 'slim'

# Main gem namespace
module Hstatic
  BASEDIR = Pathname.new(__FILE__).dirname.join('..', '..')

  # Main Sinatra Application
  #
  # It handles the publishing index pages and instantiation of
  # templates files
  class App < Sinatra::Base
    configure do
      set :views, BASEDIR + 'views'
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
            basename = path.basename(path.extname).to_s.to_sym

            return method.call basename, :views => path.dirname
          end
        end

        send_file path
      end
    end

    # Going around bootstrap
    %w(
        /.res/bootstrap.min.css
        /.res/style.css
        /.res/jquery-1.10.2.min.js
      ).each do |uri|
      get uri do
        send_file BASEDIR + uri.gsub(/^\/\./, '')
      end
    end

    %w(
        /fonts/glyphicons-halflings-regular.woff
        /fonts/glyphicons-halflings-regular.tff
        /fonts/glyphicons-halflings-regular.svg
      ).each do |uri|
      get uri do
        send_file BASEDIR + uri.gsub(/^\/fonts/, 'res')
      end
    end

    # Catch all route
    get '*' do
      # resource absolute path
      path = Pathname.new(Dir.pwd).join(unescape(request.path_info).gsub(/^\//, ''))
      path_info = Pathname.new request.path_info

      if path.file?
        render_file path
      elsif path.directory?
        %w(index.htm index.html).each do |file|
          redirect(path_info + file) if (path + file).file?
        end
        # FIXME: ^^ using halt call inside redirect for control flow
        # Building data for directory listing
        @folders = Array.new
        @files = Array.new
        @parent = path_info.dirname

        path.each_child do |entry|
          link = path_info + entry.basename

          if entry.directory?
            @folders << { :name => entry.basename, :href => link }
          else
            @files << { :name => entry.basename,
                        :size => dynamic_size(entry.size),
                        :href => link }
          end
        end

        # Render view
        slim :index
      else
        [404, 'File not found']
      end
    end
  end
end
