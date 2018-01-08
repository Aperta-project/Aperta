module CustomCard
  class FileLoader
    def self.load(journal)
      new(journal).load
    end

    def initialize(journal)
      @journal = journal
      raise StandardError, 'Cannot create custom cards for journal with pre-existing cards' if @journal.cards.any?

      home = Rails.root.join('lib/custom_card/configurations', 'xml_content')
      @files = Dir["#{home}/*.xml"]
      @permissions = DefaultCardPermissions.new
      validate_permissions
    end

    def load
      @files.each do |file_path|
        file_name = base_name(file_path)
        xml = File.read(file_path)
        card = create_card(file_name.titleize, xml)
        set_permissions(card, file_name)
      end
    end

  private

    def validate_permissions
      files = @files.map { |file_name| base_name(file_name) }
      @permissions.validate(files)
    end

    def create_card(card_name, xml)
      card_type = task_type(card_name)
      card = Card.create_initial_draft!(name: card_name, journal: @journal, card_task_type: card_type)
      card.update_from_xml(xml)
      card.reload.publish('Initial Version')
      card
    end

    def set_permissions(card, file_name)
      @permissions.apply(@journal, file_name) do |action, roles|
        CardPermissions.set_roles(card, action, roles)
      end
    end

    def task_type(card_name)
      CardTaskType.named(card_name) || CardTaskType.custom_card
    end

    def base_name(file_name)
      File.basename(file_name, '.xml')
    end
  end
end
