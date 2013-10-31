require 'open3'

class DocumentParser

  def self.parse(filename)
    tika_path = Rails.root.join('vendor/java/tika-app-1.4.jar')
    stdout, errors, _ = Open3.capture3 "java -jar #{tika_path} -t #{filename}"

    title = stdout.lines.detect { |l| l.present? }
    title_idx = stdout.lines.index title
    body = stdout.lines[(title_idx+1)..-1]
    { title: title.strip, body: body.join }
  end
end
