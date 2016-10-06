module Authorizations

  # ObjectsAuthorizedViaThroughAssociationQuery represents the query
  # responsible for finding all authorized objects through has_many :through
  # associations, e.g.:
  #
  #    Authorizations::Authorization.new(
  #      assignment_to: Journal,
  #      authorizes: Task,
  #      via: :tasks
  #    )
  #
  # where in journal.rb the following definitions exist:
  #
  #    has_many :papers
  #    has_many :tasks, through: :papers
  #
  # It only knows its a has_many :through association by looking at up
  # Journal.reflections['tasks'] definition.
  #
  # == Columns returned
  #
  # Running this query will return the following columns:
  #
  #   * <klass.table_name>.id AS id
  #   * <assignments_table>.role_id AS role_id
  #   * <assignments_table>.permission_id AS permission_table
  #
  # The < and > brackets are used above because the table references are
  # dynamic. See the corresponding constructor arguments for more information.
  #
  # == Note
  #
  # This query does not enforce permission requirements. That must be done
  # separately (see ObjectsPermissibleByRequiredPermissionsQuery).
  #
  #
  # == Warning for multiple levels of has_many :through
  # Also, has_many :through currently supports one-level of throughness. Doing
  # any more levels may work but has not be tested.
  class ObjectsAuthorizedViaThroughAssociationQuery
    attr_reader :assignments_table, :auth_config, :common_query, :klass, :target

    # == Constructor Arguments
    # * assignments_table: the Arel::Table reference representing the \
    #     assignments table to use for this query
    # * auth_config: the Authorization(s) path to JOIN against
    # * klass: the type/class that is being queried against
    # * target: the ActiveRecord::Relation being queried against
    def initialize(auth_config:, target:, assignments_table:, klass:)
      @auth_config = auth_config
      @common_query = ObjectsAuthorizedCommonQuery.new(
        auth_config: auth_config,
        klass: klass,
        assignments_table: assignments_table
      )
      @assignments_table = assignments_table
      @klass = klass
      @target = target
    end

    def to_arel
      query = common_query.to_arel
      add_joins_and_conditions(query, auth_config.reflection)
      common_query.add_permission_state_check(query)
    end

    def to_sql
      to_arel.to_sql
    end

    private

    # This adds the necessary JOINs and WHERE clause conditions to the
    # given query based on the provided reflection. The reflection here
    # is expected to be an actual
    # ActiveRecord::Reflection::AssociationReflection or subclass instance.
    def add_joins_and_conditions(query, reflection)
      # construct the join from journals table to the assignments_table
      query.join(join_table).on(
        join_table.primary_key.eq(
          assignments_table[:assigned_to_id]
        ).and(
          assignments_table[:assigned_to_type].eq(
            assigned_to_klass.base_class.name
          )
        )
      )

      # construct the join from papers table to the journals table
      query.outer_join(through_table).on(
        through_table[through_reflection.foreign_key].eq(
          join_table.primary_key
        )
      )

      # construct the join from tasks table to the papers table
      query.outer_join(klass.arel_table).on(
        klass.arel_table[reflection.foreign_key].eq(
          through_klass.arel_table.primary_key
        )
      )

      common_query.add_column_condition(
        query: query,
        column: through_klass.arel_table.primary_key,
        values: @target.where_values_hash[through_target_reflection.foreign_key]
      )

      query
    end

    # Returns the class that the current Authorization instance is
    # assigned_to.
    def assigned_to_klass
      @assigned_to_klass ||= common_query.assigned_to_klass
    end

    # Returns the Arel::Table instance for the +assigned_to_klass+
    def join_table
      @join_table ||= common_query.join_table
    end

    # Returns the ActiveRecord::Reflection::AssociationReflection (or subclass)
    # instance for this ThroughReflection
    def delegate_reflection
      @delegate_reflection ||= auth_config.reflection.delegate_reflection
    end

    # Returns the String name of the association we're going :through.
    # E.g. "has_many :tasks, through: :papers" would return 'papers'
    def through_association
      @through_association ||= delegate_reflection.options[:through].to_s
    end

    # Returns the ActiveRecord::Reflection::AssociationReflection (or subclass)
    # instance for this ThroughReflection based on looking it up through the
    # :through_association:
    # E.g. on Journal a "has_many :tasks, through: :papers" would return the
    # value for Journal.reflections['papers']
    def through_reflection
      @through_reflection ||= begin
        common_query.assigned_to_klass.reflections[through_association]
      end
    end

    # Returns the class of the through association.
    # E.g. on Journal a "has_many :tasks, through: :papers" would return the
    # klass for of the :papers association – Paper.
    def through_klass
      @through_klass ||= through_reflection.klass
    end

    # Returns the Arel::Table instance of the +through_klass+.
    # E.g. on Journal a "has_many :tasks, through: :papers" would return the
    # Arel::Table for of the :papers association – papers.
    def through_table
      @through_table ||= through_klass.arel_table
    end

    # Returns the ActiveRecord::Reflection::AssociationReflection (or subclass)
    # instance on the :through klass.
    # E.g. on Journal a "has_many :tasks, through: :papers" would return the
    # the value of Paper.reflections['tasks']
    def through_target_reflection
      @through_target_reflection ||= begin
        # If we have a through association it may be a has_many or a has_one
        # so we check both the singular and the plural forms.
        plural_reflection = auth_config.reflection.name.to_s.pluralize
        singular_reflection = auth_config.reflection.name.to_s.singularize
        through_klass.reflections[plural_reflection] ||
          through_klass.reflections[singular_reflection]
      end
    end
  end
end
