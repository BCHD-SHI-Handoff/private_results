class DashboardsController < ApplicationController
  def index
    breakdowns = {
      last_30_days: 30.days.ago,
      last_3_months: 3.months.ago,
      last_12_months: 12.months.ago
    }

    @dashboard = {
      visits: {},
      pending_results: {},
      come_back_results: {},
      ready_results: {},
      results_delivered: {},
      online_visits: {},
      call_ins: {},
    }

    pending_status_id = Status.find_by_status("Pending").id
    come_back_status_id = Status.find_by_status("Come back to clinic").id

    breakdowns.each do |symbol, time|
      @dashboard[:visits][symbol] = Visit.where("visited_on > ?", time).count

      # The goal of this SQL beast is to address the fact that there can be several
      # result records for unique visit/test combos.
      # We essentially group by test_id, visit_id and take the latest status_id. We then group by status_id and
      # count how many latest results have each status_id.
      # For example we may create a result record for {visit: 5, test: 6} with "Pending" only later
      # to create a similar record with "Come back to clinic". In this case we should get the count of 0
      # pending results and 1 "Come back to clinic" results.
      pg_results = ActiveRecord::Base.connection.execute("
        SELECT status_id, COUNT(status_id)
        FROM (
          SELECT *, ROW_NUMBER() OVER (PARTITION BY test_id, visit_id ORDER BY results.id desc) as rn
          FROM results
          INNER JOIN visits ON visits.id = results.visit_id
          WHERE visits.visited_on > to_timestamp(#{time.to_i})
        ) t
        WHERE t.rn = 1
        GROUP BY status_id
      ")
      results = pg_results.map{|r| {status_id: r['status_id'].to_i, count: r['count'].to_i}}

      pending_results = results.find{|r| r[:status_id] == pending_status_id}
      @dashboard[:pending_results][symbol] = pending_results.nil? ? 0 : pending_results[:count]

      come_back_results = results.find{|r| r[:status_id] == come_back_status_id}
      @dashboard[:come_back_results][symbol] = come_back_results.nil? ? 0 : come_back_results[:count]

      # The ready results are the total number of results for unique visit/test combos MINUS the pending and come_back results.
      non_ready_results = (@dashboard[:pending_results][symbol] + @dashboard[:come_back_results][symbol])
      @dashboard[:ready_results][symbol] = results.map{|r| r[:count]}.sum - non_ready_results

      # We group by [visit_id, test_id] so that we do not double count a result that
      # was delivered twice (which is possible as there can be several result records
      # for the same visit/test result).
      @dashboard[:results_delivered][symbol] =
        Result.joins(:visit)
          .select(:visit_id, :test_id)
          .where(delivery_status: 2)
          .where("visits.visited_on > ?", time)
          .group(:visit_id, :test_id)
          .length

      # Count up the delivered messages and split based on the time of the delivery.
      @dashboard[:online_visits][symbol] = Delivery.where("delivered_at > ?", time).where(delivery_method: 'online').length
      @dashboard[:call_ins][symbol] = Delivery.where("delivered_at > ?", time).where(delivery_method: 'phone').length
    end

    render "/dashboard"
  end
end