# frozen_string_literal: true

require 'json'
require 'date'
require 'irb'

input_path = 'data/input.json'
output_path = 'data/output.json'

input_data = JSON.parse(File.read(input_path))
cars = input_data['cars'].map { |car| [car['id'], car] }.to_h
rentals_output = input_data['rentals'].map do |rental|
  car = cars[rental['car_id']]
  start_date = Date.parse(rental['start_date'])
  end_date = Date.parse(rental['end_date'])
  rental_duration = (end_date - start_date).to_i + 1

  duration_price = rental_duration * car['price_per_day']
  distance_price = rental['distance'] * car['price_per_km']

  {
    id: rental['id'],
    price: distance_price + duration_price
  }
end

output_data = { rentals: rentals_output }
File.write(output_path, JSON.pretty_generate(output_data))
