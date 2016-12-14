module TahiReports
  class AnalyzeAttachmentFailuresReport
    TIMEFRAMES = [0.days, 1.day, 1.week, 2.weeks, 1.month, 1.year]

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

      print_attachments_stuck_in_processing
      output.puts
      output.puts

      print_attachments_stuck_in_errored
      output.puts
      output.puts

      print_number_of_attachments_per_error_breakdown
      output.puts
      output.puts
      output
    end

    def attachments_processing
      @attachments_processing ||= attachment_klass.processing
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
    end

    def print_attachments_stuck_in_processing
      attachments_stuck_in_processing = {}
      TIMEFRAMES.each_with_index do |timeframe, i|
        if i == 0
          attachments_stuck_in_processing[timeframe] = attachments_processing.where(
            created_at: (timeframe.ago.beginning_of_day.utc..Time.now.end_of_day.utc)
          ).count
        else
          attachments_stuck_in_processing[timeframe] = attachments_processing.where(
            created_at: (timeframe.ago.beginning_of_day.utc..TIMEFRAMES[i-1].ago.end_of_day.utc)
          ).count
        end
      end

      output.puts "#{attachment_klass.name}(s) stuck in processing"
      output.puts "-------------------------------------------"
      attachments_stuck_in_processing.each_pair do |timeframe, count|
        output.puts "Count in processing in the past #{timeframe.inspect}: #{count}"
      end
    end

    def print_attachments_stuck_in_errored
      attachments_stuck_in_errored = {}
      TIMEFRAMES.each_with_index do |timeframe, i|
        if i == 0
          attachments_stuck_in_errored[timeframe] = attachments_errored.where(
            created_at: (timeframe.ago.beginning_of_day.utc..Time.now.end_of_day.utc)
          ).count
        else
          attachments_stuck_in_errored[timeframe] = attachments_errored.where(
            created_at: (timeframe.ago.beginning_of_day.utc..TIMEFRAMES[i-1].ago.end_of_day.utc)
          ).count
        end
      end
      output.puts "#{attachment_klass.name}(s) that errored out"
      output.puts "-------------------------------------------"
      if attachments_stuck_in_errored.empty?
        output.puts "  [none]"
      else
        attachments_stuck_in_errored.each_pair do |timeframe, count|
          output.puts "Count in error state in the past #{timeframe.inspect}: #{count}"
        end
      end
    end

    def print_number_of_attachments_per_error_breakdown
      output.puts "Number of #{attachment_klass.name}(s) per error"
      output.puts "-------------------------------------------"
      attachments_stuck_in_errored = {}
      TIMEFRAMES.each_with_index do |timeframe, i|
        output.puts unless i == 0
        output.puts "Errors in the past #{timeframe.inspect}"
        if i == 0
          attachments_by_error = attachments_errored.where(
            created_at: (timeframe.ago.beginning_of_day.utc..Time.now.end_of_day.utc)
          ).each do |a|
            a.error_message = a.error_message.gsub("\n", "  ").gsub(/(identify)[^']+'/, '\1 <file-path-extracted>')
          end

          if attachments_by_error.empty?
            output.puts "  [none]"
          else
            attachments_by_error.group_by(&:error_message).each do |error_message, attachments|
              output.puts "  #{attachments.length} failed with error: #{error_message}"
              output.puts "  ids=#{attachments.map(&:id).inspect}"
              output.puts
            end
          end
        else
          attachments_by_error = attachments_errored.where(
            created_at: (timeframe.ago.beginning_of_day.utc..TIMEFRAMES[i-1].ago.end_of_day.utc)
          ).each do |a|
            a.error_message = a.error_message.gsub("\n", "  ").gsub(/(identify)[^']+'/, '\1 <file-path-extracted>')
          end

          if attachments_by_error.empty?
            output.puts "  [none]"
          else
            attachments_by_error.group_by(&:error_message).each do |error_message, attachments|
              output.puts "  #{attachments.length} failed with error: #{error_message}"
              output.puts "  ids=#{attachments.map(&:id).inspect}"
              output.puts
            end
          end
        end
      end
    end
  end
end
