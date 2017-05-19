# Html Sanitization Converter meant to be consumed by SnapshotMigrator
class HtmlSanitizationSnapshotConverter
  def call!(value)
    HtmlScrubber.standalone_scrub!(value, "html-expanded")
  end
end
