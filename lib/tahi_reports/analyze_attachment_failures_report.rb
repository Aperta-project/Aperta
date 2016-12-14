module TahiReports
  class AnalyzeAttachmentFailuresReport
    TIMEFRAMES = {
      'today': 0.days,
      'since yesterday': 1.day,
      'in the past week': 1.week,
      'in the past two weeks': 2.weeks,
      'in the past month': 1.month,
      'in the past year': 1.year
    }

    attr_reader :output, :attachment_klass

    def self.run(output:, attachment_klass: Attachment)
      new(output: output, attachment_klass: attachment_klass).run
    end

    def initialize(output:, attachment_klass:)
      @output = output
      @attachment_klass = Attachment
    end

    def run
      print_summary
      output.puts
      output.puts

      print_attachments_stuck(attachments_processing, 'processing')
      output.puts
      output.puts

      print_attachments_stuck(attachments_errored, 'error')
      output.puts
      output.puts

      print_number_of_attachments_per_error_breakdown
      output.puts
      output.puts
      output
    end

    # Excludes attachments that have been updated within the past 5 minutes
    def attachments_processing
      @attachments_processing ||= attachment_klass.processing.where("updated_at < ?", 5.minutes.ago)
    end

    def attachments_done
      @attachments_done ||= attachment_klass.done
    end

    def attachments_errored
      @attachments_errored ||= attachment_klass.error
    end

    def attachments_unknown
      @attachments_unknown ||= attachment_klass.unknown
    end

    private

    def print_summary
      total_count = attachment_klass.count
      done_count = attachments_done.count
      processing_count = attachments_processing.count
      errored_count = attachments_errored.count
      unknown_count = attachments_unknown.count

      # E.g. AdhocAttachment -> "Adhoc Attachment"
      attachment_types = [Attachment].concat(Attachment.subclasses).map do |kl|
        kl.name.underscore.humanize.titleize.pluralize
      end

      output.puts <<-MESSAGE.strip_heredoc
        Hello,

        Below is the results of running the Attachment analysis report run on #{Date.today}.

        The information below contains information for all attachment types including: #{attachment_types.join(', ')}.

        The goal of this email is to raise visibility of attachment processing issues before
        they become widespread so we can improve the experience of Aperta for its users.
        As issues arise it may be helpful to look for correlated errors in Bugsnag as well as
        in the `error_message` column on the `attachments` table in the production database.

        If an issue is found please create or update any related JIRA issues and communicate to
        PO/PMs as your earliest convenience.
      MESSAGE
      output.puts
      output.puts

      output.puts "Total count of #{attachment_klass.name}(s): #{total_count}"
      output.puts "-------------------------------------------"
      output.puts "# of done: #{done_count}"
      output.puts "# of processing: #{processing_count}"
      output.puts "# of errored: #{errored_count}"
      output.puts "# of unknown: #{unknown_count}"
      output.puts "NOTE: the above processing count does not include files updated within the past 5 minutes."
    end

    def print_attachments_stuck(attachments, state)
      attachments_stuck = {}
      TIMEFRAMES.each_pair.with_index do |(human_readable_timeframe, timeframe), i|
        attachments_stuck[human_readable_timeframe] = attachments.where(
          updated_at: (timeframe.ago.beginning_of_day.utc..Time.now.end_of_day.utc)
        ).count
      end

      output.puts "#{attachment_klass.name}(s) stuck in #{state}"
      output.puts "-------------------------------------------"
      attachments_stuck.each_pair do |human_readable_timeframe, count|
        output.puts "Count in #{state} state #{human_readable_timeframe}: #{count}"
      end
    end

    def print_number_of_attachments_per_error_breakdown
      output.puts "Number of #{attachment_klass.name}(s) per error"
      output.puts "-------------------------------------------"
      attachments_stuck_in_errored = {}
      TIMEFRAMES.each_pair.with_index do |(human_readable_timeframe, timeframe), i|
        output.puts unless i == 0
        output.puts "Errors #{human_readable_timeframe}"
        if i == 0
          attachments_by_error = attachments_errored.where(
            updated_at: (timeframe.ago.beginning_of_day.utc..Time.now.end_of_day.utc)
          ).each do |a|
            a.error_message = a.error_message.gsub("\n", "  ").gsub(/(identify)[^']+'/, '\1 <file-path-extracted>')
          end

          if attachments_by_error.empty?
            output.puts "  [none]"
          else
            attachments_by_error.group_by(&:error_message).each_with_index do |(error_message, attachments), j|
              output.puts unless j == 0
              output.puts "  #{attachments.length} failed with error: #{error_message}"
              output.puts "  ids=#{attachments.map(&:id).inspect}"
            end
          end
        else
          attachments_by_error = attachments_errored.where(
            updated_at: (timeframe.ago.beginning_of_day.utc..TIMEFRAMES.values[i-1].ago.end_of_day.utc)
          ).each do |a|
            a.error_message = a.error_message.gsub("\n", "  ").gsub(/(identify)[^']+'/, '\1 <file-path-extracted>')
          end

          if attachments_by_error.empty?
            output.puts "  [none]"
          else
            attachments_by_error.group_by(&:error_message).each_with_index do |(error_message, attachments), j|
              output.puts unless j == 0
              output.puts "  #{attachments.length} failed with error: #{error_message}"
              output.puts "  ids=#{attachments.map(&:id).inspect}"
            end
          end
        end
      end
    end
  end
end
