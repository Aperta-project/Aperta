# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

module PaperConverters
  # Used to create things which act like figures
  # This is a layer of indirection which allows us to use
  # a figure snapshot record like a real Figure
  class FigureProxy
    def self.from_versioned_text(versioned_text)
      if versioned_text.latest_version?
        return versioned_text.paper.figures.map do |figure|
          from_figure(figure)
        end
      else
        major_version = versioned_text.major_version
        minor_version = versioned_text.minor_version
        snapshots = versioned_text.paper.snapshots.figures
                                  .where(major_version: major_version,
                                         minor_version: minor_version)
        return snapshots.map do |snapshot|
          from_snapshot(snapshot)
        end
      end
    end

    def self.from_figure(figure)
      new(figure: figure)
    end

    def self.from_snapshot(snapshot)
      token = snapshot.get_property("url").split('/').last
      resource_token = ResourceToken.find_by(token: token)
      new(
        title: snapshot.get_property("title"),
        href: resource_token.try(:url, :detail),
        filename: snapshot.get_property("file")
      )
    end

    def filename
      return @figure.filename if @figure
      @filename
    end

    def initialize(figure: nil, title: nil, href: nil, filename: nil)
      @figure = figure
      @title = title
      @href = href
      @filename = filename
    end

    def title
      return @title if @title
      return @figure.title if @figure
    end

    def href
      return @href if @href
      return @figure.proxyable_url(version: :detail) if @figure
    end

    def rank
      return 0 unless title
      number_match = title.match(/\d+/)
      if number_match
        number_match[0].to_i
      else
        0
      end
    end
  end
end
