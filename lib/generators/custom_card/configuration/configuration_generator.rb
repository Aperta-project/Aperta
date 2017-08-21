module CustomCard
  class ConfigurationGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :name, type: :string, required: true
    argument :legacy_task_klass_name, type: :string, required: false

    def warn_if_no_task_klass
      return if legacy_task_klass_name.present?

      warn <<-MESSAGE.strip_heredoc
      Since you did not provide a task class name as an argument to the
      custom card generator, no data migration will be generated and
      permissions will need to be set manually within the generated
      configuration file.
      MESSAGE
    end

    def warn_if_missing_production_data
      return if legacy_task_klass_name.present? && production_data_loaded?
      die if no?("You do not curently have production data loaded.  Existing permissions will not be derived.  Want to continue?")
    end

    def exit_if_non_existent_legacy_task_klass
      return if legacy_task_klass_name.present? && legacy_task_exists?
      die("Could not find a Task with type '#{legacy_task_klass_name}'.  Ensure correct spelling and namespace.")
    end

    def generate_custom_card_configuration
      template "configuration.template", "lib/custom_card/configurations/#{klass_name.underscore}.rb"
    end

    def generate_custom_card_migration
      return if legacy_task_klass_name.blank?
      generate "custom_card:migration", "\"#{name}\" \"#{legacy_task_klass_name}\""
    end

    private

    def production_data_loaded?
      User.count > 100
    end

    def legacy_task_exists?
      Task.where(type: legacy_task_klass_name).exists?
    end

    def display_name
      name.titleize
    end

    def klass_name
      name.tr(" ", "_").camelize
    end

    def view_permissions
      permissions[:view]
    end

    def edit_permissions
      permissions[:edit]
    end

    def permissions
      @permissions ||= CustomCard::PermissionInquiry.new(legacy_class_name: legacy_task_klass_name).legacy_permissions
    end

    def warn(msg)
      say(msg, :yellow)
    end

    # rubocop:disable Rails/Exit
    def die(msg = nil)
      say(msg, :red) if msg
      exit 1
    end
    # rubocop:enable Rails/Exit
  end
end
