module Authorizations
  class ObjectsThroughAuthorizationsQuery
    include QueryHelpers
    attr_reader :auth_configs, :klass, :target, :permissible_assignments_table

    def initialize(target:, klass:, auth_configs:, permissible_assignments_table:)
      @auth_configs = auth_configs
      @klass = klass
      @target = target
      @permissible_assignments_table = permissible_assignments_table
    end

    # +permission_state_column+ should return the column that houses
    # a model's state.
    #
    # This is so permissions that are tied to states can add a
    # WHERE condition in the query for matching against the right states.
    #
    # Right now this is set up to work for Paper(s). If the system needs to
    # evolve to work with other kinds of models this is the entry point for
    # refactoring, replacing, or removing.
    def permission_state_column
      'publishing_state'
    end

    def to_sql
      to_arel.to_sql
    end

    def to_arel
      auth_configs.map do |ac|
        assigned_to_klass = ac.assignment_to
        reflection = ac.assignment_to.reflections[ac.via.to_s]
        join_table = assigned_to_klass.arel_table
        target_table = klass.arel_table
        query = ObjectsAuthorizedCommonQuery.new(
          auth_config: ac,
          klass: klass,
          permissible_assignments_table: permissible_assignments_table
        ).to_arel

        if assigned_to_klass <=> @klass
          query = ObjectsAuthorizedThroughSelf.new(
            target: target,
            auth_config: ac,
            permissible_assignments_table: permissible_assignments_table,
            klass: klass
          ).to_arel

          query

        elsif reflection.nil?
          fail MissingAssociationForAuthConfiguration, <<-ERROR.strip_heredoc
            Expected to find #{ac.via.inspect} association defined on
            #{assigned_to_klass}, but did not. This was because the following
            Authorizations::Configuration was configured:

            #{ac.inspect}
          ERROR

        elsif reflection.collection? || reflection.has_one?
          # E.g. Journal has_many :tasks, :through => :papers
          if reflection.respond_to?(:through_options)
            loop do
              # this is the Paper reflection
              delegate_reflection = reflection.delegate_reflection
              through_reflection = assigned_to_klass.reflections[delegate_reflection.options[:through].to_s]
              through_klass = through_reflection.klass
              through_table = through_reflection.klass.arel_table

              # If we have a thru association it may be a has_many or a has_one
              # so we check both the singular and the plural forms.
              plural_reflection = reflection.name.to_s.pluralize
              singular_reflection = reflection.name.to_s.singularize
              through_target_reflection = begin
                through_klass.reflections[plural_reflection] || through_klass.reflections[singular_reflection]
              end
              through_target_table = through_target_reflection.klass.arel_table

              # construct the join from journals table to the permissible_assignments_table
              query.outer_join(join_table).on(
                join_table.primary_key.eq(permissible_assignments_table[:assigned_to_id]).and(permissible_assignments_table[:assigned_to_type].eq(assigned_to_klass.base_class.name))
              )

              # construct the join from papers table to the journals table
              query.outer_join(through_table).on(
                through_table[through_reflection.foreign_key].eq(
                  join_table.primary_key
                )
              )

              # construct the join from tasks table to the papers table
              query.outer_join(target_table).on(target_table[reflection.foreign_key].eq(through_klass.arel_table.primary_key))

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


            query.where(join_table.primary_key.eq(permissible_assignments_table[:assigned_to_id]).and(permissible_assignments_table[:assigned_to_type].eq(assigned_to_klass.base_class.name)))

            add_permission_state_check_to_query(query)
            query
          else
            query.outer_join(join_table).on(join_table.primary_key.eq(permissible_assignments_table[:assigned_to_id]).and(permissible_assignments_table[:assigned_to_type].eq(assigned_to_klass.base_class.name)))
            query.outer_join(target_table).on(target_table[reflection.foreign_key].eq(join_table.primary_key))
            foreign_key_value = @target.where_values_hash[reflection.foreign_key]
            if foreign_key_value
              foreign_key_values = [ foreign_key_value ].flatten
              query.where(join_table.primary_key.in(foreign_key_values))
            end

            add_permission_state_check_to_query(query)

            query
          end
        elsif reflection.belongs_to?
          query.outer_join(join_table).on(join_table.primary_key.eq(permissible_assignments_table[:assigned_to_id]).and(permissible_assignments_table[:assigned_to_type].eq(assigned_to_klass.base_class.name)))
          query.outer_join(target_table).on(join_table[reflection.foreign_key].eq(target_table.primary_key))

          foreign_key_value = @target.where_values_hash[reflection.foreign_key]
          if foreign_key_value
            foreign_key_values = [ foreign_key_value ].flatten
            query.where(join_table.primary_key.in(foreign_key_values))
          end

          add_permission_state_check_to_query(query)

          query
        else
          fail "I don't know what you're trying to pull. I'm not familiar with this kind of association: #{reflection.inspect}"
        end
      end
    end

    def add_permission_state_check_to_query(query)
      local_permission_state_column = if klass.respond_to?(:delegate_state_to)
        delegate_permission_state_to_association = klass.delegate_state_to.to_s
        delegate_state_table = klass.reflections[delegate_permission_state_to_association].klass.arel_table
        delegate_state_table[permission_state_column]
      elsif klass.column_names.include?(permission_state_column.to_s) # e.g. Paper has its own publishing state column
        klass.arel_table[permission_state_column]
      end

      return unless local_permission_state_column

      query.join(table[:permissions]).on(
        table[:permissions][:id].eq(permissible_assignments_table[:permission_id])
      )
      query.outer_join(table[:permission_states_permissions]).on(
        table[:permission_states_permissions][:permission_id].eq(permissible_assignments_table[:permission_id])
      )
      query.outer_join(table[:permission_states]).on(
        table[:permission_states][:id].eq(table[:permission_states_permissions][:permission_state_id])
      )

      # Check to see if we need to JOIN on the table that owns the
      # local_permission_state_column. This is necessary if a class is
      # delegating their state permission column to an association, but that
      # associaton has not been loaded, e.g. Task -> Paper#publishing_state
      if !query.join_sources.map(&:left).map(&:name).include?(local_permission_state_column.relation.name)
        query.join(local_permission_state_column.relation).on(
          local_permission_state_column.relation.primary_key.eq(
            klass.arel_table[
              klass.reflections[delegate_permission_state_to_association].foreign_key
            ]
          )
        )
      end

      query.where(
        table[:permission_states][:name].eq(local_permission_state_column).or(
          table[:permission_states][:name].eq(PermissionState::WILDCARD.to_s)
        )
      )

      # If the @klass uses STI then we need to add conditions which enforces
      # scope based on the permissions.applies_to column.
      if @klass.column_names.include?(@klass.inheritance_column)
        qs = [@klass].concat(@klass.descendants).reduce(nil) do |q, permissible_klass|
          eligible_ancestors = (permissible_klass.ancestors & permissible_klass.base_class.descendants) << permissible_klass.base_class
          condition = klass.arel_table[:type].eq(permissible_klass.name).and(
            table[:permissions][:applies_to].in(eligible_ancestors.map(&:name))
          )
          q ? q.or(condition) : condition
        end
        query.where(qs)
      else
        # no-op for non-STI klasses
      end

      query
    end
  end
end
