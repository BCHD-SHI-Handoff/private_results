class DashboardsController < ApplicationController
  def index
    breakdowns = {
      last_30_days: 30.days.ago,
      last_3_months: 3.months.ago,
      last_12_months: 12.months.ago
    }

    @dashboard = {results_delivered: {}, percentage_delivered: {}, visits: {}}
    breakdowns.each do |symbol, time|
      delivered = Result.where("recorded_on > ?", time).includes(:deliveries).where.not(:deliveries_results => {:result_id => nil}).count
      total = Result.where("recorded_on > ?", time).count
      @dashboard[:results_delivered][symbol] = delivered
      @dashboard[:percentage_delivered][symbol] = total == 0 ? 0 : (100 * delivered.to_f / total).round(0)
      @dashboard[:visits][symbol] = Visit.where("visited_on > ?", time).count
    end

    render "/dashboard"
  end
end