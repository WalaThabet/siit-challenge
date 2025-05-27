require_relative 'pricing_helpers'

class Rental
  include PricingHelpers

  attr_reader :id, :car, :start_date, :end_date, :distance

  def initialize(data, car)
    @id         = data['id']
    @car        = car
    @start_date = data['start_date']
    @end_date   = data['end_date']
    @distance   = data['distance']
  end

  def duration
    rental_duration(start_date, end_date)
  end

  def price
    discounted_duration_price(duration, car['price_per_day']) +
      distance * car['price_per_km']
  end

  def commission
    commission_total = (price * 0.3).to_i
    insurance_fee    = (commission_total / 2).to_i
    assistance_fee   = duration * 100
    drivy_fee        = commission_total - insurance_fee - assistance_fee

    {
      insurance_fee: insurance_fee,
      assistance_fee: assistance_fee,
      drivy_fee: drivy_fee
    }
  end

  def actions
    [
      { who: 'driver',     type: 'debit',  amount: price },
      { who: 'owner',      type: 'credit', amount: price - commission.values.sum },
      { who: 'insurance',  type: 'credit', amount: commission[:insurance_fee] },
      { who: 'assistance', type: 'credit', amount: commission[:assistance_fee] },
      { who: 'drivy',      type: 'credit', amount: commission[:drivy_fee] }
    ]
  end

  def to_h
    {
      id: id,
      actions: actions
    }
  end
end
