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

TahiReports::AnalyzeAttachmentFailuresReport.run(output: STDOUT)
