# The SimpleReport class is used to store historical information of where
# papers are sitting in the system. The report that uses this information is
# used as a quick sanity check to make sure papers aren't backed up somewhere
# in the pipeline.
class SimpleReport < ActiveRecord::Base
  class << self
    def build_new_report
      simple_report = new
      attributes = simple_report.instance_eval { build_status_counts }
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
    last_report.currently_sitting_sum
  end

  def currently_sitting_sum
    initially_submitted +
      invited_for_full_submission +
      fully_submitted +
      checking +
      in_revision
  end

  private

  # build_* methods are used to build the report for new records only.
  def build_status_counts
    @build_status_counts ||= begin
      counts = Hash[build_status_queries.map { |k, v| [k, v.count] }]
      counts[:in_process_balance] = calc_in_process_balance(counts)
      counts
    end
  end

  # A collection of the queries used to build a new SimpleReport. The
  # QueryParser was used intentionally to have a shared reporting language with
  # users familiar with the paper tracker.
  def build_status_queries
    @build_status_queries ||= begin
      queries = Hash[{
        unsubmitted: "STATUS IS unsubmitted",
        initially_submitted: "STATUS IS initially submitted",
        invited_for_full_submission: "STATUS IS invited for full submission",
        fully_submitted: "STATUS IS submitted",
        checking: "STATUS IS checking",
        in_revision: "STATUS IS in revision",
        accepted: "STATUS IS accepted",
        withdrawn: "STATUS IS withdrawn",
        rejected: "STATUS IS rejected"
      }.map { |k, v| [k, QueryParser.new.build(v)] }]

      build_new_exiting_queries(queries)
      queries
    end
  end

  def build_new_exiting_queries(queries)
    queries[:new_initial_submissions] =
      Paper.where("first_submitted_at >= ?", previous_report_date)

    exiting_states.each do |state|
      queries["new_#{state}".to_sym] =
        queries[state.to_sym]
          .where("state_updated_at >= ?", previous_report_date)
          .where.not(submitted_at: nil)
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

  def exiting_states
    %w(accepted rejected withdrawn)
  end
end