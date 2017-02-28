module PaperConverters
  # Used to create things which act like figures
  # This is a layer of indirection which allows us to use
  # a figure snapshot record like a real Figure
  class FigureProxy
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
