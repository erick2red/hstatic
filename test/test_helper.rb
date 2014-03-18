require_relative '../lib/hstatic'

require 'minitest/autorun'
require 'rack/test'

# Migrated activesuport String#strip_heredoc patching
class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.size || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end
