#!/usr/bin/env ruby

show_help = ARGV.include?("-h") || ARGV.include?("--help") || ARGV.include?("help")
show_help ||= !Object.const_defined?(:Attachment)

if show_help
  puts <<-USAGE.gsub(/^\s*\|/, '')
    |Usage: rails runner $0 <Attachment>
    |
    |== ARGUMENTS
    |  Attachment: the attachment class to run the report against. Optional. Defaults to Attachment.
    |
    |== EXAMPLES
    |   rails runner #{0}
    |   rails runner #{0} Figure
    |   rails runner #{0} SupportingInformationFile
    |
    |== NOTES
    |This script writes to STDOUT by default. For saving to a file please redirect output of this script.
    |
    |Be sure to run with "rails runner".
  USAGE
  exit 0
end

attachment_klass = begin
  str = ARGV.shift
  str ? str.constantize : Attachment
end

output = STDOUT

attachments_processing = attachment_klass.where(status: 'processing')
attachments_done = attachment_klass.where(status: 'done')
attachments_errored = attachment_klass.where(status: 'error')
attachments_unknown = attachment_klass.where.not(status: %w(processing error done))

total_count = attachment_klass.count
done_count = attachments_done.count
processing_count = attachments_processing.count
errored_count = attachments_errored.count
unknown_count = attachments_unknown.count

TIMEFRAMES = [0.days, 1.day, 1.week, 2.weeks, 1.month, 1.year]

output.puts "Total count of #{attachment_klass.name}(s): #{total_count}"
output.puts "-------------------------------------------"
output.puts "# of done: #{done_count}"
output.puts "# of processing: #{processing_count}"
output.puts "# of errored: #{errored_count}"
output.puts "# of unknown: #{unknown_count}"
output.puts
output.puts

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
output.puts
output.puts


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
output.puts



output.puts "Number of #{attachment_klass.name}(s) per error"
output.puts "-------------------------------------------"
attachments_stuck_in_errored = {}
TIMEFRAMES.each_with_index do |timeframe, i|
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
      end
    end
  end
  output.puts
end
output.puts
output.puts
