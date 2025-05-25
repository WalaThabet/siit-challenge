require 'date'

module PricingHelpers
  def rental_duration(start_date, end_date)
    (Date.parse(end_date) - Date.parse(start_date)).to_i + 1
  end

  def discounted_duration_price(duration, price_per_day)
    return price_per_day if duration == 1

    day_one          = price_per_day
    days_two_to_four = (duration >= 2 ? [duration, 4].min - 1 : 0) * (price_per_day * 0.9).to_i
    days_five_to_ten = (duration >= 5 ? [duration, 10].min - 4 : 0) * (price_per_day * 0.7).to_i
    days_eleven_plus = (duration > 10 ? duration - 10 : 0) * (price_per_day * 0.5).to_i

    day_one + days_two_to_four + days_five_to_ten + days_eleven_plus
  end
end
