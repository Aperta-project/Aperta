# rubocop:disable Metrics/ModuleLength, Metrics/MethodLength, Style/TrailingCommaInLiteral
module CustomCard
  module DefaultCardPermissions

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
