# Html Sanitization Converter meant to be consumed by SnapshotMigrator
class HtmlSanitizationSnapshotConverter
  def call!(value)
    @scrubber ||= HtmlScrubber.new
    fragment = Loofah.fragment(value)
    fragment.scrub!(@scrubber)
    fragment.to_html
  end
end
