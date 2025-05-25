# frozen_string_literal: true

require 'json'
require 'date'
require_relative '../lib/pricing_helpers'

def calculate_commission(price, duration)
  commission_total = (price * 0.3).to_i
  insurance_fee    = (commission_total / 2).to_i
  assistance_fee   = duration * 100
  drivy_fee = commission_total - insurance_fee - assistance_fee

  {
    insurance_fee: insurance_fee,
    assistance_fee: assistance_fee,
    drivy_fee: drivy_fee
  }
end

input_path = 'data/input.json'
output_path = 'data/output.json'

input_data = JSON.parse(File.read(input_path))
cars = input_data['cars'].map { |car| [car['id'], car] }.to_h

rentals_output = input_data['rentals'].map do |rental|
  car = cars[rental['car_id']]
  duration = PricingHelpers.rental_duration(rental['start_date'], rental['end_date'])

  duration_price = PricingHelpers.discounted_duration_price(duration, car['price_per_day'])
  distance_price = rental['distance'] * car['price_per_km']
  total_price = duration_price + distance_price

  commission = calculate_commission(total_price, duration)

  {
    id: rental['id'],
    price: total_price,
    commission: commission
  }
end

File.write(output_path, JSON.pretty_generate({ rentals: rentals_output }))
