# frozen_string_literal: true

require 'json'
require_relative '../lib/rental'
require 'irb'

input_path = 'data/input.json'
output_path = 'data/output.json'

input_data = JSON.parse(File.read(input_path))

cars = input_data['cars'].map { |car| [car['id'], car] }.to_h
options_by_rental_id = input_data['options'].group_by { |o| o['rental_id'] }

rentals_output = input_data['rentals'].map do |rental_data|
  car = cars[rental_data['car_id']]
  options = options_by_rental_id[rental_data['id']] || []
  Rental.new(rental_data, cars[rental_data['car_id']], options).to_h(include_options: true)
end

File.write(output_path, JSON.pretty_generate({ rentals: rentals_output }))
