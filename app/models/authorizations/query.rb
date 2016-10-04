# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'emberize'

# rubocop:disable all
module Authorizations
  class Error < ::StandardError ; end
  class QueryError < Error ; end
  class MissingAssociationForAuthConfiguration < Error ; end

  # Query represents the quer(y|ies) for finding the authorized objects from
  # the database based on how the authorizations sub-system is configured,
  # what the user is assigned to, what roles the person has, and what
  # permissions they have thru those roles.
  class Query
    attr_reader :permission, :klass, :user

    # == Constructor Arguments
    # * permission - is the permission you are checking for authorization \
    #                against
    # * target - is the object, class, or ActiveRecord::Relation that is being \
    #            being authorized
    # * user - is the user who the query will be check for authorization against
    # * participations_only - a boolean specifying if only targets a user
    #                         participates in should be returned. If not
    #                         specified, it depends on the target passed in. For
    #                         Class or ActiveRecord::Relation, it is true, for
    #                         Array or ActiveRecord::Base, it is false.
    def initialize(permission:, target:, user:, participations_only: :default)
      @permission = permission.to_sym
      @user = user
      @target = target
      @participations_only = participations_only

      # we're looking for everything, e.g. Task got passed in
      if target.is_a?(Class)
        @klass = target
        @target = target.all
        @participations_only = true if @participations_only == :default

        # we're looking for a specific object, e.g. Task.first got passed in
      elsif target.is_a?(ActiveRecord::Base)
        @klass = target.class
        @target = @klass.where(id: target.id)
        @participations_only = false if @participations_only == :default

        # we're looking for a set of objects with a pre-existing query, e.g. Task.where(name: "Bar") got passed in
      elsif target.is_a?(ActiveRecord::Relation)
        @klass = target.model
        @participations_only = true if @participations_only == :default

        # we're looking for a specific of objects e.g. [Task.first, Task.last] got passed in
      elsif target.is_a?(Array)
        @klass = target.first.class
        @participations_only = false if @participations_only == :default
      end
    end

    def all
      return ResultSet.new unless @target

      if user.site_admin? && !@participations_only
        load_all_objects
      else
        load_authorized_objects
      end
    end

    private

    def table
      @table ||= {
        roles: Role.arel_table,
        permissions_roles: Arel::Table.new(Role.reflections['permissions'].join_table),
        permissions: Permission.arel_table,
        permission_requirements: PermissionRequirement.arel_table,
        permission_states_permissions: Arel::Table.new(Permission.reflections['states'].join_table),
        permission_states: PermissionState.arel_table,
        results: Arel::Table.new(:results),
        results_with_permissions: Arel::Table.new(:results_with_permissions)
      }
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


    # Our version of Arel won't let us union more than two things. So we get around that.
    def union(a, list=[])
      if list.blank?
        return a
      elsif list.count == 1
        return a.union(list.first)
      else
        return Arel::Nodes::Union.new(a, union(list.first, list[1..-1]))
      end
    end


    # +load_all_objects+ is a way to bypass R&P queries. It is intended to be
    # used in the case of Site Admins(s) or other System-level roles that
    # have access to everything in the system.
    #
    # Note: If :participations_only is true then this will never return any
    # records. This is because System accounts should _never_ be considered
    # participants.
    def load_all_objects
      result_set = ResultSet.new

      permission_names = Permission.where(applies_to: eligible_applies_to).pluck(:action)
      permission_hsh = {}
      permission_names.each do |name|
        permission_hsh[name.to_sym] = { states: [PermissionState::WILDCARD] }
      end

      if @target.is_a?(Class)
        result_set.add_objects(@target.all, with_permissions: permission_hsh)
      elsif @target.is_a?(ActiveRecord::Base)
        result_set.add_objects([@target], with_permissions: permission_hsh)
      elsif @target.is_a?(ActiveRecord::Relation)
        result_set.add_objects(@target.all, with_permissions: permission_hsh)
      end

      result_set
    end


    # Returns the eligible values for a permission applies_to given the
    # @klass being queried. This searches the class, any of its descendants,
    # as well as any ancestors in the lineage from the @klass to its base-class.
    def eligible_applies_to
      eligible_ancestors = @klass.ancestors & @klass.base_class.descendants
      [
        @klass.descendants,
        @klass,
        eligible_ancestors,
        @klass.base_class
      ].flatten.map(&:name).uniq
    end


    # This walks the authorization configuration file and creates a path from 
    # a authorized parent to all authorized children
    # For example: paper authorizes tasks.
    def auth_configs
      @auth_configs ||= begin
        Authorizations.configuration.authorizations.select do |ac|
          # if what we're authorizing is the same class or an ancestor of @klass
          ac.authorizes >= @klass
        end
      end.concat([Authorizations::Authorization.new(
        assignment_to: @klass,
        authorizes: @klass,
        via: :self
      )])
    end

    def add_permission_state_check_to_query(query, permissions_query)
      local_permission_state_column = if klass.respond_to?(:delegate_state_to)
        delegate_permission_state_to_association = klass.delegate_state_to.to_s
        delegate_state_table = klass.reflections[delegate_permission_state_to_association].klass.arel_table
        delegate_state_table[permission_state_column]
      elsif klass.column_names.include?(permission_state_column.to_s) # e.g. Paper has its own publishing state column
        klass.arel_table[permission_state_column]
      end

      return unless local_permission_state_column

      query.join(table[:permissions]).on(
        table[:permissions][:id].eq(permissions_query[:permission_id])
      )
      query.outer_join(table[:permission_states_permissions]).on(
        table[:permission_states_permissions][:permission_id].eq(permissions_query[:permission_id])
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


    def load_authorized_objects
      if klass.respond_to?(:delegate_state_to)
        @delegate_permission_state_to_association = klass.delegate_state_to.to_s
      elsif klass.column_names.include?(permission_state_column.to_s)
        @permission_state_check = true
      end

      assignments_subquery = PermissibleAssignmentsQuery.new(user: @user, permission: @permission,
        klass: @klass, applies_to: eligible_applies_to, auth_configs: auth_configs,
        participations_only: @participations_only).to_arel

      permissions_query = Arel::Table.new(:permissions_query)
      permissions_table = Arel::Nodes::As.new(permissions_query, assignments_subquery)

      authorization_paths = auth_configs.map do |ac|
        assigned_to_klass = ac.assignment_to
        reflection = ac.assignment_to.reflections[ac.via.to_s]
        join_table = assigned_to_klass.arel_table
        target_table = @klass.arel_table

        query = permissions_query.project(
          klass.arel_table.primary_key.as('id'),
          permissions_query[:role_id].as('role_id'),
          permissions_query[:permission_id].as('permission_id')
        )

        query.project(klass.arel_table[:paper_id]) if klass.column_names.include?('paper_id')

        if assigned_to_klass <=> @klass
          query.outer_join(join_table).on(
            join_table.primary_key.eq(permissions_query[:assigned_to_id]).and(
              permissions_query[:assigned_to_type].eq(assigned_to_klass.base_class.name)
            )
          )

          id_values = @target.where_values_hash['id']
          if id_values.present?
            id_values = [ id_values ].flatten
            query = query.where(join_table.primary_key.in(id_values))
          end

          add_permission_state_check_to_query(query, permissions_query)

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

              # construct the join from journals table to the permissions_query
              query.outer_join(join_table).on(
                join_table.primary_key.eq(permissions_query[:assigned_to_id]).and(permissions_query[:assigned_to_type].eq(assigned_to_klass.base_class.name))
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


            query.where(join_table.primary_key.eq(permissions_query[:assigned_to_id]).and(permissions_query[:assigned_to_type].eq(assigned_to_klass.base_class.name)))

            add_permission_state_check_to_query(query, permissions_query)
            query
          else
            query.outer_join(join_table).on(join_table.primary_key.eq(permissions_query[:assigned_to_id]).and(permissions_query[:assigned_to_type].eq(assigned_to_klass.base_class.name)))
            query.outer_join(target_table).on(target_table[reflection.foreign_key].eq(join_table.primary_key))
            foreign_key_value = @target.where_values_hash[reflection.foreign_key]
            if foreign_key_value
              foreign_key_values = [ foreign_key_value ].flatten
              query.where(join_table.primary_key.in(foreign_key_values))
            end

            add_permission_state_check_to_query(query, permissions_query)

            query
          end
        elsif reflection.belongs_to?
          query.outer_join(join_table).on(join_table.primary_key.eq(permissions_query[:assigned_to_id]).and(permissions_query[:assigned_to_type].eq(assigned_to_klass.base_class.name)))
          query.outer_join(target_table).on(join_table[reflection.foreign_key].eq(target_table.primary_key))

          foreign_key_value = @target.where_values_hash[reflection.foreign_key]
          if foreign_key_value
            foreign_key_values = [ foreign_key_value ].flatten
            query.where(join_table.primary_key.in(foreign_key_values))
          end

          add_permission_state_check_to_query(query, permissions_query)

          query
        else
          fail "I don't know what you're trying to pull. I'm not familiar with this kind of association: #{reflection.inspect}"
        end
      end

      return ResultSet.new if authorization_paths.empty?

      u = union(authorization_paths.first, authorization_paths[1..-1])

      results_with_permissions_query = Arel::SelectManager.new(klass.arel_table.engine).
        with(permissions_table).
        project(
          table[:results][:id],
          Arel.sql("string_agg(distinct(concat(permissions.action::text, ':', permission_states.name::text)), ', ') AS permission_actions"),
        ).
        from( Arel.sql('(' + u.to_sql + ')').as(table[:results].table_name) ).
        outer_join(table[:permission_requirements]).on(
          table[:permission_requirements][:required_on_type].eq(klass.name).and(
            table[:permission_requirements][:required_on_id].eq(table[:results][:id])
          )
        ).
        join(table[:roles]).on(
          table[:roles][:id].eq(table[:results][:role_id])
        ).
        join(table[:permissions_roles]).on(
          table[:permissions_roles][:role_id].eq(table[:roles][:id])
        ).
        join(table[:permissions]).on(
          table[:permissions][:id].eq(table[:permissions_roles][:permission_id])
        ).
        join(table[:permission_states_permissions]).on(
          table[:permission_states_permissions][:permission_id].eq(table[:permissions][:id])
        ).
        join(table[:permission_states]).on(
          table[:permission_states][:id].eq(table[:permission_states_permissions][:permission_state_id])
        ).
        where(
          table[:results][:id].not_eq(nil).and(
            table[:permission_requirements].primary_key.eq(nil).or(
              table[:permission_requirements][:permission_id].eq(table[:results][:permission_id])
            )
          ).and(
            table[:permissions][:applies_to].in(eligible_applies_to)
          )
        ).
        group(table[:results][:id])

      results_with_permissions = Arel::SelectManager.new(klass.arel_table.engine).
        project(klass.arel_table[Arel.star], 'permission_actions').
        from( Arel.sql('(' + results_with_permissions_query.to_sql + ')').as('results_with_permissions') ).
        join(klass.arel_table).on(klass.arel_table[:id].eq(table[:results_with_permissions][:id]))

      objects  = @target.from( Arel.sql("(#{results_with_permissions.to_sql}) AS #{klass.table_name} ") )

      # pull out permissions
      rs = ResultSet.new
      objects.each do |task|
        permission_states = Hash.new { |h,k| h[k] = { states: [] } }

        # Permission_actions come thru as a string column, e.g:
        #   "read:*, talk:in_progress, talk:in_review, view:*, write:in_progress"
        #
        # They need to be parsed out and the permission states should be
        # grouped by their corresponding permission action.
        objects.first.permission_actions.
          split(/\s*,\s*/).
          map { |f| f.split(/:/) }.
          each { |permission, state| permission_states[permission][:states] << state }
        rs.add_object(task, with_permissions: permission_states)
      end
      rs
    end
  end
end
# rubocop:enable all
