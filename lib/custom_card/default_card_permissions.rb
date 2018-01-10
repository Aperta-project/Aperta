# rubocop:disable Metrics/MethodLength, Style/TrailingCommaInLiteral, Layout/SpaceInsideBrackets
module CustomCard
  class DefaultCardPermissions
    def initialize(journal)
      @journal = journal
      @permissions = default_card_permissions
    end

    def validate(names)
      perms = @permissions.keys
      matching = names.sort == perms.sort
      raise StandardError, 'Mismatched custom card permissions' unless matching
    end

    def apply(key)
      permissions = @permissions[key]
      roles = get_roles(permissions)
      actions = get_actions(permissions)
      actions.each do |action|
        action_roles = roles_with_action(permissions, action)
        active_roles = roles.slice(*action_roles).values
        yield(action, active_roles)
      end
    end

    def match(name, permissions)
      apply(name) do |action, roles|
        yield(roles_with_action(permissions, action), roles.map(&:name))
      end
    end

    private

    def get_roles(permissions)
      roles = @journal.roles.where(name: permissions.keys).load
      roles.each_with_object({}) { |role, hash| hash[role.name] = role }
    end

    def get_actions(permissions)
      permissions.values.flatten.uniq
    end

    def roles_with_action(permissions, action)
      permissions.keys.select { |key| permissions[key].include?(action) }
    end

    def default_card_permissions
      {
        'additional_information'  => {
          'Academic Editor'       => ['view'],
          'Billing Staff'         => ['view'],
          'Collaborator'          => ['view', 'edit'],
          'Cover Editor'          => ['view', 'edit', 'view_discussion_footer'],
          'Creator'               => ['view', 'edit'],
          'Handling Editor'       => ['view', 'edit', 'view_discussion_footer'],
          'Internal Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Production Staff'      => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Publishing Services'   => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Reviewer'              => ['view'],
          'Staff Admin'           => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
        },

        'competing_interests'     => {
          'Academic Editor'       => ['view'],
          'Billing Staff'         => ['view'],
          'Collaborator'          => ['view', 'edit'],
          'Cover Editor'          => ['view', 'edit'],
          'Creator'               => ['view', 'edit'],
          'Handling Editor'       => ['view', 'edit'],
          'Internal Editor'       => ['view', 'edit'],
          'Production Staff'      => ['view', 'edit'],
          'Publishing Services'   => ['view', 'edit'],
          'Reviewer'              => ['view'],
          'Staff Admin'           => ['view', 'edit'],
        },

        'cover_letter'            => {
          'Academic Editor'       => ['view',         'view_discussion_footer'],
          'Billing Staff'         => ['view',         'view_discussion_footer'],
          'Collaborator'          => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Cover Editor'          => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Creator'               => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Handling Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Internal Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Production Staff'      => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Publishing Services'   => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Staff Admin'           => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
        },

        'data_availability'       => {
          'Academic Editor'       => ['view',         'view_discussion_footer'],
          'Billing Staff'         => ['view',         'view_discussion_footer'],
          'Collaborator'          => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Cover Editor'          => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Creator'               => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Handling Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Internal Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Production Staff'      => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Publishing Services'   => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Reviewer'              => ['view',         'view_discussion_footer'],
          'Staff Admin'           => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
        },

        'early_version'           => {
          'Academic Editor'       => ['view'],
          'Billing Staff'         => ['view'],
          'Collaborator'          => ['view', 'edit'],
          'Cover Editor'          => ['view', 'edit', 'view_discussion_footer'],
          'Creator'               => ['view', 'edit'],
          'Handling Editor'       => ['view', 'edit', 'view_discussion_footer'],
          'Internal Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Production Staff'      => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Publishing Services'   => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Reviewer'              => ['view'],
          'Staff Admin'           => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
        },

        'ethics_statement'        => {
          'Academic Editor'       => ['view',         'view_discussion_footer'],
          'Billing Staff'         => ['view',         'view_discussion_footer'],
          'Collaborator'          => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Cover Editor'          => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Creator'               => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Handling Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Internal Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Production Staff'      => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Publishing Services'   => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Reviewer'              => ['view',         'view_discussion_footer'],
          'Staff Admin'           => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
        },

        'financial_disclosure'    => {
          'Academic Editor'       => ['view'],
          'Billing Staff'         => ['view'],
          'Collaborator'          => ['view', 'edit'],
          'Cover Editor'          => ['view', 'edit', 'view_discussion_footer'],
          'Creator'               => ['view', 'edit'],
          'Handling Editor'       => ['view', 'edit', 'view_discussion_footer'],
          'Internal Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Production Staff'      => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Publishing Services'   => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Reviewer'              => ['view'],
          'Staff Admin'           => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
        },

        'preprint_decision'       => {
          'Cover Editor'          => [                'view_discussion_footer'],
          'Handling Editor'       => [                'view_discussion_footer'],
          'Internal Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Production Staff'      => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Publishing Services'   => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Staff Admin'           => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
        },

        'preprint_posting'        => {
          'Academic Editor'       => ['view'],
          'Billing Staff'         => ['view'],
          'Collaborator'          => ['view', 'edit'],
          'Cover Editor'          => ['view'],
          'Creator'               => ['view', 'edit'],
          'Handling Editor'       => ['view'],
          'Internal Editor'       => ['view'],
          'Journal Setup Admin'   => ['view'],
          'Participant'           => ['view', 'edit'],
          'Production Staff'      => ['view'],
          'Publishing Services'   => ['view', 'edit'],
          'Reviewer'              => ['view'],
          'Reviewer Report Owner' => ['view'],
          'Staff Admin'           => ['view', 'edit'],
        },

        'reporting_guidelines'    => {
          'Academic Editor'       => ['view',         'view_discussion_footer'],
          'Billing Staff'         => ['view',         'view_discussion_footer'],
          'Collaborator'          => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Cover Editor'          => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Creator'               => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Handling Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Internal Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Production Staff'      => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Publishing Services'   => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Reviewer'              => ['view',         'view_discussion_footer'],
          'Staff Admin'           => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
        },

        'upload_manuscript'       => {
          'Academic Editor'       => ['view'],
          'Billing Staff'         => ['view'],
          'Collaborator'          => ['view', 'edit'],
          'Cover Editor'          => ['view', 'edit', 'view_discussion_footer'],
          'Creator'               => ['view', 'edit'],
          'Handling Editor'       => ['view', 'edit', 'view_discussion_footer'],
          'Internal Editor'       => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Production Staff'      => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Publishing Services'   => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
          'Reviewer'              => ['view'],
          'Staff Admin'           => ['view', 'edit', 'view_discussion_footer', 'edit_discussion_footer'],
        }
      }
    end
  end
end
