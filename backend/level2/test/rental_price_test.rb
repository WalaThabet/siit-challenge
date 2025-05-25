# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/pricing_helpers'

class RentalPricingTest < Minitest::Test
  include PricingHelpers

  def test_one_day_rental
    assert_equal 1000, discounted_duration_price(1, 1000)
  end

  def test_three_day_rental
    assert_equal 2800, discounted_duration_price(3, 1000)
  end

  def test_five_day_rental
    assert_equal 4400, discounted_duration_price(5, 1000)
  end

  def test_twelve_day_rental
    assert_equal 8900, discounted_duration_price(12, 1000)
  end
end
