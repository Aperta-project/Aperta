module CustomCard
  # The purpose of this class is to return the view and edit permissions of an existing Task.
  #
  # This is most useful when migrating a legacy Task to a custom Card and the developer wants
  # to ensure that the correct permissions are carried over.
  #
  # Usage:
  #   CustomCard::PermissionInquiry.new(legacy_class_name: "TahiStandardTasks::CoverLetterTask").legacy_permissions
  #
  # Result:
  # { view: ["Academic Editor", "Billing Staff", "Collaborator", "Cover Editor"],
  #   edit: ["Collaborator", "Cover Editor", "Creator"]}
  #
  class PermissionInquiry
    attr_reader :legacy_class_name

    def initialize(legacy_class_name:)
      @legacy_class_name = legacy_class_name
    end

    # returns hash where key is an action name and value is a list of role names with a permission with that action
    def legacy_permissions
      [:view, :edit].each_with_object({}) do |action, result|
        roles = Role.joins(:permissions).where(permissions: { action: action, applies_to: legacy_class_name }).order(:name)
        result[action] = roles.pluck(:name).uniq
      end
    end
  end
end
