class DownloadManuscript
  def self.call paper, url
    manuscript = paper.manuscript || paper.build_manuscript

    # TODO: we're downloading this once, then using `open` to download it again
    # is there a way to reuse the same file for both?
    manuscript.source.download!(url)
    manuscript.save
    paper.update OxgarageParser.new(open(manuscript.source.file.url)).to_hash
  end
end
