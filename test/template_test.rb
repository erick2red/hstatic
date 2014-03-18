require_relative 'test_helper'

class TemplateTest < Minitest::Test
  include Rack::Test::Methods

  HAML_CONTENT = <<-BODY.strip_heredoc
    <p>This is a haml sample</p>
    <p>This is another paragraph sample</p>
    <ul>
      <li>First item</li>
      <li>Second item</li>
    </ul>
    BODY

  SLIM_CONTENT = "<p>This is a haml sample</p><p>This is another paragraph sample</p><ul><li>First item</li><li>Second item</li></ul>"

  def app
    Dir.chdir Pathname.new(__FILE__).dirname
    Hstatic::App.new
  end

  def test_haml_rendering
    get '/dummy_folder/sample.haml'

    assert_equal 200, last_response.status, "Request status failed"
    assert_equal last_response.body, HAML_CONTENT, "Body content mismatched"
  end

  def test_slim_rendering
    get '/dummy_folder/sample.slim'

    assert_equal 200, last_response.status, "Request status failed"
    assert_equal last_response.body, SLIM_CONTENT, "Body content mismatched"
  end
end
