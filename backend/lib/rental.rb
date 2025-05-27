require_relative 'pricing_helpers'

class Rental
  include PricingHelpers

  OPTION_PRICES = {
    'gps' => 500,
    'baby_seat' => 200,
    'additional_insurance' => 1000
  }.freeze

  OWNER_OPTION_TYPES = %w[gps baby_seat].freeze
  DRIVY_OPTION_TYPES = %w[additional_insurance].freeze

  attr_reader :id, :car, :start_date, :end_date, :distance, :option_types

  def initialize(data, car, options = [])
    @id         = data['id']
    @car        = car
    @start_date = data['start_date']
    @end_date   = data['end_date']
    @distance   = data['distance']
    @option_types = options.map { |o| o['type'] }.sort
  end

  def duration
    rental_duration(start_date, end_date)
  end

  def base_price
    discounted_duration_price(duration, car['price_per_day']) +
      distance * car['price_per_km']
  end

  def commission
    commission_total = (base_price * 0.3).to_i
    insurance_fee    = (commission_total / 2).to_i
    assistance_fee   = duration * 100
    drivy_fee        = commission_total - insurance_fee - assistance_fee

    {
      insurance_fee: insurance_fee,
      assistance_fee: assistance_fee,
      drivy_fee: drivy_fee
    }
  end

  def owner_options_amount
    total_option_amount(OWNER_OPTION_TYPES)
  end

  def drivy_options_amount
    total_option_amount(DRIVY_OPTION_TYPES)
  end

  def total_price
    base_price + owner_options_amount + drivy_options_amount
  end

  def actions
    total_owner_amount = owner_options_amount + base_price - commission.values.sum
    total_drivy_amount = commission[:drivy_fee] + drivy_options_amount

    [
      { who: 'driver',     type: 'debit',  amount: total_price },
      { who: 'owner',      type: 'credit', amount: total_owner_amount },
      { who: 'insurance',  type: 'credit', amount: commission[:insurance_fee] },
      { who: 'assistance', type: 'credit', amount: commission[:assistance_fee] },
      { who: 'drivy',      type: 'credit', amount: total_drivy_amount }
    ]
  end

  def to_h(include_options: false)
    base = {
      id: id,
      actions: actions
    }
    include_options ? base.merge(options: option_types) : base
  end

  def total_option_amount(option_group)
    (option_types & option_group).sum { |type| duration * OPTION_PRICES[type] }
  end
end
