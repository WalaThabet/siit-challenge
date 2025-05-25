# frozen_string_literal: true

require 'minitest/autorun'

# rubocop:disable Metrics/AbcSize
def discounted_duration_price(duration, price_per_day)
  return price_per_day if duration == 1

  day_one           = price_per_day
  days_two_to_four  = (duration >= 2 ? [duration, 4].min - 1 : 0) * (price_per_day * 0.9).to_i
  days_five_to_ten  = (duration >= 5 ? [duration, 10].min - 4 : 0) * (price_per_day * 0.7).to_i
  days_eleven_plus  = (duration > 10 ? duration - 10 : 0) * (price_per_day * 0.5).to_i

  day_one + days_two_to_four + days_five_to_ten + days_eleven_plus
end
# rubocop:enable Metrics/AbcSize

class RentalPricingTest < Minitest::Test
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
