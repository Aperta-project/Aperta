# The SimpleReport class is used to store historical information of where
# papers are sitting in the system. The report that uses this information is
# used as a quick sanity check to make sure papers aren't backed up somewhere
# in the pipeline.
class SimpleReport < ActiveRecord::Base
  class << self
    def build_new_report
      simple_report = new
      attributes = simple_report.instance_eval { status_counts }
      simple_report.assign_attributes(attributes)
      simple_report
    end
  end

  def new_exiting_count
    new_accepted + new_rejected + new_withdrawn
  end

  def previous_report_date
    return DateTime.new(1970, 1, 1, 1).utc unless last_report
    last_report.created_at
  end

  def last_report
    self.class.last
  end

  def previous_in_process_balance
    return 0 unless last_report
    last_report.in_process_balance
  end

  private

  def status_counts
    @status_counts ||= begin
      counts = Hash[status_queries.map { |k, v| [k, v.count] }]
      counts[:in_process_balance] = calc_in_process_balance(counts)
      counts
    end
  end

  # A collection of the queries used to build a new SimpleReport. The
  # QueryParser was used intentially to have a shared reporting language with
  # users familiar with the paper tracker.
  def status_queries
    @status_queries ||= begin
      queries = Hash[{
        initially_submitted: "STATUS IS initially submitted",
        fully_submitted: "STATUS IS submitted",
        checking: "STATUS IS checking",
        in_revision: "STATUS IS in revision",
        accepted: "STATUS IS accepted",
        withdrawn: "STATUS IS withdrawn",
        rejected: "STATUS IS rejected"
      }.map { |k, v| [k, QueryParser.new.build(v)] }]

      queries[:new_initial_submissions] =
        queries[:initially_submitted]
        .where("first_submitted_at >= ?", previous_report_date)

      %w(accepted rejected withdrawn).each do |state|
        queries["new_#{state}".to_sym] =
          queries[state.to_sym]
          .where("state_updated_at >= ?", previous_report_date)
      end

      queries
    end
  end

  # calc_* methods are used to build the report for new records only.
  def calc_new_exiting_count(counts)
    counts[:new_accepted] + counts[:new_rejected] + counts[:new_withdrawn]
  end

  def calc_in_process_balance(counts)
    previous_in_process_balance +
      counts[:new_initial_submissions] -
      calc_new_exiting_count(counts)
  end
end
