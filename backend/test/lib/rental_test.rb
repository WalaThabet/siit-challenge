# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../../lib/rental'
require 'irb'

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

  def options_data
    [
      { 'id' => 1, 'rental_id' => 1, 'type' => 'gps' },
      { 'id' => 2, 'rental_id' => 1, 'type' => 'baby_seat' },
      { 'id' => 3, 'rental_id' => 1, 'type' => 'additional_insurance' }
    ]
  end

  def test_rental_without_options
    rental = Rental.new(rental_data, car_data)

    assert_equal 3, rental.duration
    assert_empty rental.option_types

    actions = rental.to_h[:actions]
    assert_equal 5, actions.size

    driver_action = actions.find { |a| a[:who] == 'driver' }
    assert_equal rental.base_price, driver_action[:amount]

    owner_action = actions.find { |a| a[:who] == 'owner' }
    expected_owner_amount = rental.base_price - rental.commission.values.sum
    assert_equal expected_owner_amount, owner_action[:amount]
  end

  def test_rental_with_options
    rental = Rental.new(rental_data, car_data, options_data)

    assert_equal 3, rental.duration
    assert_equal %w[additional_insurance baby_seat gps], rental.option_types.sort

    gps_price = Rental::OPTION_PRICES['gps']
    baby_seat_price = Rental::OPTION_PRICES['baby_seat']
    insurance_price = Rental::OPTION_PRICES['additional_insurance']

    options_total = rental.duration * (gps_price + baby_seat_price + insurance_price)
    owner_options = rental.duration * (gps_price + baby_seat_price)
    drivy_options = rental.duration * insurance_price

    actions = rental.to_h[:actions]

    driver_action = actions.find { |a| a[:who] == 'driver' }
    assert_equal rental.base_price + options_total, driver_action[:amount]

    owner_action = actions.find { |a| a[:who] == 'owner' }
    expected_owner_amount = rental.base_price - rental.commission.values.sum + owner_options
    assert_equal expected_owner_amount, owner_action[:amount]

    drivy_action = actions.find { |a| a[:who] == 'drivy' }
    expected_drivy_amount = rental.commission[:drivy_fee] + drivy_options
    assert_equal expected_drivy_amount, drivy_action[:amount]
  end
end
