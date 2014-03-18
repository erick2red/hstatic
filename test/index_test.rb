require_relative 'test_helper'

# Class for testing index.html redirection
class IndexTest < Minitest::Test
  include Rack::Test::Methods

  CONTENT = <<-BODY.strip_heredoc
    <!DOCTYPE html>
    <html>
        <head>
            <title>Dummy Demo Index</title>
        </head>
        <body>
            <p>This is a demo page</p>
        </body>
    </html>
    BODY

  def app
    Dir.chdir Pathname.new(__FILE__).dirname
    Hstatic::App.new
  end

  def test_index_redirect
    get '/dummy_folder'

    assert_equal last_response.status, 302, 'Redirect failed'

    follow_redirect!
    assert_equal 200, last_response.status, 'Request status failed'
    assert_equal last_response.body, CONTENT, 'Body content mismatched'
  end
end
