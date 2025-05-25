# frozen_string_literal: true

require 'minitest/autorun'
require 'date'

class RentalPriceTest < Minitest::Test
  def test_rental_price_calculation
    car = { 'price_per_day' => 2000, 'price_per_km' => 10 }

    start_date = Date.parse('2017-12-8')
    end_date = Date.parse('2017-12-10')
    distance = 100

    rental_days = (end_date - start_date).to_i + 1
    time_price = rental_days * car['price_per_day']
    distance_price = distance * car['price_per_km']
    total_price = time_price + distance_price

    assert_equal 7000, total_price
  end
end
