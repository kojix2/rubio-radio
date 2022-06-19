# frozen_string_literal: true

require_relative 'test_helper'

class RubioTest < Minitest::Test
  def test_version
    assert_kind_of String, Rubio::VERSION
  end
end
