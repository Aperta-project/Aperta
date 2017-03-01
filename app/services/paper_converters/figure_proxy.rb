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
      resource_token = ResourceToken.find_by!(token: token)
      new(
        title: snapshot.get_property("title"),
        href: resource_token.url(:detail)
      )
    end

    def initialize(figure: nil, title: nil, href: nil)
      @figure = figure
      @title = title
      @href = href
    end

    def title
      return @title if @title
      return @figure.title if @figure
    end

    def href
      return @href if @href
      return @figure.proxyable_url(version: :detail) if @figure
    end
  end
end
