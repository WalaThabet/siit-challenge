# frozen_string_literal: true

require 'json'
require 'date'
require 'irb'

input_path = 'data/input.json'
output_path = 'data/output.json'

input_data = JSON.parse(File.read(input_path))
cars = input_data['cars'].map { |car| [car['id'], car] }.to_h

def rental_duration(start_date, end_date)
  start_date = Date.parse(start_date)
  end_date = Date.parse(end_date)
  (end_date - start_date).to_i + 1
end

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

rentals_output = input_data['rentals'].map do |rental|
  car = cars[rental['car_id']]
  rental_duration = rental_duration(rental['start_date'], rental['end_date'])

  duration_price = discounted_duration_price(rental_duration, car['price_per_day'])
  distance_price = rental['distance'] * car['price_per_km']

  {
    id: rental['id'],
    price: distance_price + duration_price
  }
end

File.write(output_path, JSON.pretty_generate({ rentals: rentals_output }))
