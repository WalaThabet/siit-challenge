# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/rental'

class RentalTest < Minitest::Test
  def car_data
    { 'id' => 1, 'price_per_day' => 1000, 'price_per_km' => 10 }
  end

  def rental_data
    {
      'id' => 1,
      'car_id' => 1,
      'start_date' => '2021-01-01',
      'end_date' => '2021-01-03',
      'distance' => 100
    }
  end

  def setup
    @car = car_data
    @rental_data = rental_data
    @rental = Rental.new(@rental_data, @car)
  end

  def test_duration
    assert_equal 3, @rental.duration
  end

  def test_driver_action
    action = @rental.to_h[:actions].find { |a| a[:who] == 'driver' }
    assert_equal 'debit', action[:type]
    assert_equal @rental.price, action[:amount]
  end

  def test_owner_action
    action = @rental.to_h[:actions].find { |a| a[:who] == 'owner' }
    expected = @rental.price - @rental.commission.values.sum
    assert_equal 'credit', action[:type]
    assert_equal expected, action[:amount]
  end

  def test_action_count
    assert_equal 5, @rental.to_h[:actions].size
  end
end
