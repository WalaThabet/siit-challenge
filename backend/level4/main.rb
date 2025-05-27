# frozen_string_literal: true

require 'json'
require_relative '../lib/rental'

input_path = 'data/input.json'
output_path = 'data/output.json'

input_data = JSON.parse(File.read(input_path))
cars = input_data['cars'].map { |car| [car['id'], car] }.to_h

rentals_output = input_data['rentals'].map do |rental_data|
  Rental.new(rental_data, cars[rental_data['car_id']]).to_h
end

File.write(output_path, JSON.pretty_generate({ rentals: rentals_output }))
