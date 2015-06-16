class DashboardsController < ApplicationController
  def index
    breakdowns = {
      last_30_days: 30.days.ago,
      last_3_months: 3.months.ago,
      last_12_months: 12.months.ago
    }

    @dashboard = {
      visits: {},
      online_visits: {},
      call_ins: {},
    }

    breakdowns.each do |symbol, time|
      @dashboard[:visits][symbol] = Visit.where("visited_on > ?", time).count

      # Count up the delivered messages and split based on the time of the delivery.
      @dashboard[:online_visits][symbol] = Delivery.where("delivered_at > ?", time).where(delivery_method: 'online').length
      @dashboard[:call_ins][symbol] = Delivery.where("delivered_at > ?", time).where(delivery_method: 'phone').length
    end

    render "/dashboard"
  end
end