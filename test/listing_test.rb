require_relative 'test_helper'

class ListTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Hstatic::App.new
  end

  def test_root
    get '/'

    assert last_response.ok?
  end

  def test_resources
    %w(/.res/style.css /.res/bootstrap.min.css /.res/jquery-1.10.2.min.js).each do |uri|
      get uri
      assert_equal last_response.status, 200, "Request status failed"
      assert last_response.body != "File not found", "Body content mismatched"
    end
  end

end
