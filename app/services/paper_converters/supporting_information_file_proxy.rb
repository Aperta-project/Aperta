module PaperConverters
  # Used to create things which act like SI files
  # This is a layer of indirection which allows us to use
  # a SI snapshot record like a real SIFile
  class SupportingInformationFileProxy
    include UrlBuilder

    def self.from_versioned_text(versioned_text)
      if versioned_text.latest_version?
        paper = versioned_text.paper
        return paper.supporting_information_files.map do |si_file|
          klass = SupportingInformationFileProxy
          klass.from_supporting_information_file(si_file)
        end
      else
        major_version = versioned_text.major_version
        minor_version = versioned_text.minor_version
        snapshots = versioned_text.paper.snapshots.supporting_information_files
                                  .where(major_version: major_version,
                                         minor_version: minor_version)
        return snapshots.map do |snapshot|
          SupportingInformationFileProxy.from_snapshot(snapshot)
        end
      end
    end

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
      return false unless resource_token.version_urls['preview'].present?

      # I am very sorry about this.
      #
      # The problem is, somewhere along the line we denormalized urls into the
      # ResourceToken model, which disconnected them from the carrierwave model.
      #
      # Why did this happen? I can't say.
      #
      # Creating more problems, we actually have urls in the ResourceToken
      # model that no longer exist (did they ever?)
      #
      # And if we pass these non-existant URLs to wkhtmltopdf, it blows up. But
      # we can't use Carrierwave to quickly check if these files exist, so we
      # need to create a new Fog file to check if the files exist.
      #
      # TODO: Fix this
      #
      # This mess was copied from Attachment. I don't know why it's there
      # either.
      garbage = Attachment.new.file
      CarrierWave::Storage::Fog::File.new(
        garbage,
        garbage.send(:storage),
        resource_token.version_urls['preview']
      ).exists?
    end

    def id
      return @supporting_information_file.id if @supporting_information_file
      @id
    end

    def href(**params)
      if @supporting_information_file
        @supporting_information_file.proxyable_url(params)
      elsif params[:is_proxied]
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
