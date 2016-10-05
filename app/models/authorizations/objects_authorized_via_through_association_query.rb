module Authorizations
  class ObjectsAuthorizedViaThroughAssociationQuery
    attr_reader :auth_config, :target, :assignments_table,
      :common_query, :common_arel, :klass

    def initialize(auth_config:, target:, assignments_table:, klass:)
      @auth_config = auth_config
      @common_query = ObjectsAuthorizedCommonQuery.new(
        auth_config: auth_config,
        klass: klass,
        assignments_table: assignments_table
      )
      @assignments_table = assignments_table
      @common_arel = common_query.to_arel
      @klass = klass
      @target = target
    end

    def to_sql
      to_arel.to_sql
    end

    def to_arel
      # E.g. Journal has_many :tasks, :through => :papers
      query = common_arel
      reflection = auth_config.reflection

      loop do
        # construct the join from journals table to the assignments_table
        query.outer_join(join_table).on(
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

        foreign_key_value = @target.where_values_hash[through_target_reflection.foreign_key]
        if foreign_key_value
          foreign_key_values = [ foreign_key_value ].flatten
          query.where(through_klass.arel_table.primary_key.in(foreign_key_values))
        end

        # the next two lines are for supporting a :through that goes thru a :through
        # it is completely untested and may not even be important. If it isn't we may
        # be able to get rid of the whole looping construct
        break unless delegate_reflection.respond_to?(:delegate_reflection)
        reflection = delegate_reflection
      end

      query.where(
        join_table.primary_key.eq(
          assignments_table[:assigned_to_id]
        ).and(
          assignments_table[:assigned_to_type].eq(
            assigned_to_klass.base_class.name
          )
        )
      )

      common_query.add_permission_state_check_to_query(query)
    end

    private

    def assigned_to_klass
      @assigned_to_klass ||= common_query.assigned_to_klass
    end

    def join_table
      @join_table ||= common_query.join_table
    end

    # this is the Paper reflection
    def delegate_reflection
      @delegate_reflection ||= auth_config.reflection.delegate_reflection
    end

    def through_association
      @through_association ||= delegate_reflection.options[:through].to_s
    end

    def through_reflection
      @through_reflection ||= begin
        common_query.assigned_to_klass.reflections[through_association]
      end
    end

    def through_klass
      @through_klass ||= through_reflection.klass
    end

    def through_table
      @through_table ||= through_klass.arel_table
    end

    def through_target_reflection
      @through_target_reflection ||= begin
        # If we have a thru association it may be a has_many or a has_one
        # so we check both the singular and the plural forms.
        plural_reflection = auth_config.reflection.name.to_s.pluralize
        singular_reflection = auth_config.reflection.name.to_s.singularize
        through_klass.reflections[plural_reflection] ||
          through_klass.reflections[singular_reflection]
      end
    end
  end
end
