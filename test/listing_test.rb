require_relative 'test_helper'

# Class for testing directory listing
class ListTest < Minitest::Test
  include Rack::Test::Methods

  TEST_LISTING = <<-BODY.strip_heredoc
  <!DOCTYPE html><html><head><meta content="width=device-width, initial-scale=1.0" name="viewport" /><!--Bootstrap--><link href="/.res/bootstrap.min.css" rel="stylesheet" /><link href="/.res/style.css" rel="stylesheet" /><script src="/.res/jquery-1.10.2.min.js" type="text/javascript"></script></head><body><div class="container-fluid"><div class="row"><div class="col-md-4 col-md-offset-4"><input autofocus="" class="form-control" placeholder="Search" type="text" /></div></div><div class="row"><div class="col-lg-3 col-md-3 col-sm-3"><div class="panel panel-default"><div class="panel-heading">Folders<a class="pull-right" href="/"><span class="glyphicon glyphicon-arrow-up"></span>Up</a></div><div class="list-group"><a class="list-group-item folder" href="/dummy_folder" title="dummy_folder">dummy_folder</a></div></div></div><div class="col-lg-9 col-md-9 col-sm-9"><div class="panel panel-default"><div class="panel-heading">Files</div><table class="table table-hover"><thead><tr><th>#</th><th>Name</th><th>Size</th></tr></thead><tbody><tr><td>1</td><td><a href="/test_helper.rb">test_helper.rb</a></td><td> 0.00 kB</td></tr><tr><td>2</td><td><a href="/template_test.rb">template_test.rb</a></td><td> 0.00 kB</td></tr><tr><td>3</td><td><a href="/index_test.rb">index_test.rb</a></td><td> 0.00 kB</td></tr><tr><td>4</td><td><a href="/listing_test.rb">listing_test.rb</a></td><td> 2.00 kB</td></tr></tbody></table></div></div></div></div><script type="text/javascript">$(document).ready(function () {
    var re = new RegExp;
    /!* filtering */
    $('input').on('input', function () {
      value = $(this).val();
      $('a.list-group-item, tr:has(a)').show();
      if (value == "") {
        return false;
      }
      re.compile(value, "i");
      $.each($('a.list-group-item'), function(i, e){
        if (! re.test(e.innerHTML)) {
          $(e).hide();
        }
      });
      $.each($('tr:has(a)'), function(i, e){
        if (! re.test($('a', e).html())) {
          $(e).hide();
        }
      });
    });
    $('input').on('keyup', function (event) {
      if (event.which == 27) {
        $('input').val("");
        $('input').trigger('input');
      }
    });
  });</script></body></html>
  BODY

  def app
    Dir.chdir Pathname.new(__FILE__).dirname
    Hstatic::App.new
  end

  def test_root
    get '/'

    assert last_response.ok?
  end

  def test_resources
    %w(/.res/style.css /.res/bootstrap.min.css /.res/jquery-1.10.2.min.js).each do |uri|
      get uri

      assert_equal last_response.status, 200, 'Request status failed'
      assert last_response.body != 'File not found', 'Body content mismatched'
    end
  end

  def test_content
    get '/'

    assert_equal 200, last_response.status, 'Request status failed'
    assert_equal last_response.body, TEST_LISTING.rstrip, 'Body content mismatched'
  end
end
