class AuditLogsController < ApplicationController
  before_filter :verify_is_admin

  def index
    render "/audit_log"
  end

  def export
    # Round our start and end dates to the beginning and end of the days, respectively.
    # This ensures that we get every audit entry that happened on those days.
    start_date = Time.at(params['start'].to_i / 1000).beginning_of_day
    end_date = Time.at(params['end'].to_i / 1000).end_of_day

    send_data AuditLog.get_csv(start_date, end_date)
  end
end
