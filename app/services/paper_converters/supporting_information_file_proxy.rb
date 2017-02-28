module PaperConverters
  # Used to create things which act like SI files
  # This is a layer of indirection which allows us to use
  # a SI snapshot record like a real SIFile
  class SupportingInformationFileProxy
    include UrlBuilder

    def self.from_supporting_information_file(supporting_information_file)
      new(supporting_information_file: supporting_information_file)
    end

    def self.from_snapshot(snapshot)
      token = snapshot.get_property("url").split('/').last
      new(
        filename: snapshot.get_property("file"),
        resource_token: ResourceToken.find_by!(token: token),
        id: snapshot.source_id
      )
    end

    def initialize(supporting_information_file: nil, filename: nil,
                   resource_token: nil, id: nil)
      @supporting_information_file = supporting_information_file
      @filename = filename
      @resource_token = resource_token
      @id = id
    end

    def filename
      if @supporting_information_file
        return @supporting_information_file.filename
      end
      @filename
    end

    def preview?
      resource_token = @resource_token ||
        @supporting_information_file.resource_token
      resource_token.version_urls["preview"].present?
    end

    def id
      return @supporting_information_file.id if @supporting_information_file
      @id
    end

    def href(**params)
      if @supporting_information_file
        @supporting_information_file.proxyable_url(params)
      else
        if params[:is_proxied]
          options = { token: @resource_token.token,
                      version: params[:version],
                      only_path: params[:only_path] }
          url_for(:resource_proxy, options)
        else
          @resource_token.url(params[:version] || :detail)
        end
      end
    end
  end
end
