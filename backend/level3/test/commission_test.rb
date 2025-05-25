# frozen_string_literal: true

require 'minitest/autorun'

def calculate_commission(price, duration)
  commission_total = (price * 0.3).to_i
  insurance_fee    = (commission_total / 2).to_i
  assistance_fee   = duration * 100
  agency_fee       = commission_total - insurance_fee - assistance_fee

  {
    insurance_fee: insurance_fee,
    assistance_fee: assistance_fee,
    agency_fee: agency_fee
  }
end

class CommissionTest < Minitest::Test
  def test_commission_is_30_percent_of_total
    price = 7000
    result = calculate_commission(price, 3)

    total_commission = result[:insurance_fee] + result[:assistance_fee] + result[:agency_fee]
    assert_equal (price * 0.3).to_i, total_commission
  end

  def test_insurance_is_half_of_commission
    price = 5000
    result = calculate_commission(price, 2)

    total_commission = (price * 0.3).to_i
    assert_equal (total_commission / 2).to_i, result[:insurance_fee]
  end

  def test_assistance_fee_is_100_cents_per_day
    result = calculate_commission(8000, 4)
    assert_equal 400, result[:assistance_fee]
  end

  def test_agency_fee_is_the_rest
    price = 10_000
    duration = 5
    result = calculate_commission(price, duration)

    total_commission = (price * 0.3).to_i
    expected_agency = total_commission - result[:insurance_fee] - result[:assistance_fee]

    assert_equal expected_agency, result[:agency_fee]
  end
end
