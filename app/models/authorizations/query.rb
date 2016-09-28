# Autoloader is not thread-safe in 4.x; it is fixed for Rails 5.
# Explicitly require any dependencies outside of app/. See a9a6cc for more info.
require_dependency 'emberize'

# rubocop:disable all
module Authorizations
  class Error < ::StandardError ; end
  class QueryError < Error ; end
  class CannotFindInverseAssociation < QueryError ; end

  # Query represents the quer(y|ies) for finding the authorized objects from
  # the database based on how the authorizations sub-system is configured,
  # what the user is assigned to, what roles the person has, and what
  # permissions they have thru those roles.
  class Query
    # WILDCARD represents the notion that any state is valid.
    WILDCARD = PermissionState::WILDCARD

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
      :publishing_state
    end

    # +permission_state_join+ allows for a model to delegate their state
    # by implementing a `delegate_state_to` method on the class that
    # returns the name of the association to delegate to as a symbol.
    #
    # For example, having the following method in a model will delegate permission state to Paper:
    #  def self.delegate_state_to
    #    :paper
    #  end
    def permission_state_join
      @klass.try(:delegate_state_to)
    end

    def allowed?(object, states)
      states.include?(WILDCARD) ||
        !object.respond_to?(permission_state_column) ||
        states.member?(object.send(permission_state_column))
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
        permission_hsh[name.to_sym] = { states: [WILDCARD_STATE] }
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

    def assignments_subquery
      assignments = Assignment.all
        .select('
          assignments.id,
          assignments.assigned_to_type,
          assignments.assigned_to_id,
          roles.id AS role_id,
          roles.name AS role_name,
          permissions.id AS permission_id'
        )
      .joins(permissions: :states)
      .where(assignments: { user_id: user.id })

     # explicitly add conditions rather than converting Assignment.all
     # to user.assignments. The reason is that ActiveRecord::Relation
     # will produce bind parameters that will not get handled correctly
     # when we convert to AREL queries below
     assignments_arel = assignments.arel

     auth_configs.each do |ac|
       join_table = ac.assignment_to.arel_table
       source_table = ac.authorizes.arel_table
       association = ac.assignment_to.reflections[ac.via.to_s]

       assignments_arel.outer_join(join_table).on(
         join_table[ ac.assignment_to.primary_key ]
         .eq( Assignment.arel_table[:assigned_to_id] )
         .and(
           Assignment.arel_table[:assigned_to_type].
           eq(ac.assignment_to.name)
         )
       )
     end

    # Append @klass, again, this could possibly be moved to an auth config
     klasses2where = auth_configs.map { |ac| ac.assignment_to } << @klass
     arel_conditions = klasses2where.reduce(nil) do |arel_conditions, klass|
       if arel_conditions
         arel_conditions.or(klass.arel_table.primary_key.not_eq(nil))
       else
         klass.arel_table.primary_key.not_eq(nil)
       end
     end

     assignments_arel.where(arel_conditions)
        .where(Permission.arel_table[:applies_to].in(eligible_applies_to))

     # If we're looking for the wildcard permission then we aren't interested in any one
     # permission, but all of the possible permissions
     if @permission.to_sym != :*
       assignments_arel.where(Permission.arel_table[:action].eq(@permission))
     end

     if @participations_only
       role_accessibility_method = "participates_in_#{@klass.table_name}"
       if Role.column_names.include?(role_accessibility_method)
         assignments_arel.where(Role.arel_table[role_accessibility_method.to_sym].eq(true))
       end
     end

     assignments_arel.group(Assignment.arel_table[:assigned_to_type])
       .group(Assignment.arel_table[:assigned_to_id])
       .group(Assignment.arel_table[:id])
       .group(Role.arel_table[:id])
       .group(Permission.arel_table[:id])

      assignments_arel
    end

    def objects_by_klass klass
      a2_table = Arel::Table.new(:assignments_table)
      composed_a2 = Arel::Nodes::As.new(assignments_table)
    end

    # puts Arel::Nodes::Union.new(queries2union.first.with(composed_a2), Arel::Nodes::Union.new(queries2union.last, anotherqueryhere)).to_sql
    def union(a, list=[])
      if list.blank?
        return a
      elsif list.count == 1
        # return Arel::Nodes::Union.new(a, list.first)
        return a.union(list.first)
      else
        begin
          return Arel::Nodes::Union.new(a, union(list.first, list[1..-1]))
          # return a.union(union(list.first, list[1..-1]))
        rescue Exception => ex
          binding.pry
          raise ex
        end
      end
    end

    def table
      @table ||= {
        roles: Role.arel_table,
        permissions_roles: Arel::Table.new(Role.reflections['permissions'].join_table),
        permissions: Permission.arel_table,
        permission_requirements: PermissionRequirement.arel_table,
        permission_states_permissions: Arel::Table.new(Permission.reflections['states'].join_table),
        permission_states: PermissionState.arel_table,
        results_1: Arel::Table.new(:results_1),
        results_with_permissions: Arel::Table.new(:results_with_permissions)
      }
    end

    def load_authorized_objects
      a2_table = Arel::Table.new(:a2_table)
      composed_a2 = Arel::Nodes::As.new(a2_table, assignments_subquery)

      queries2union = auth_configs.map do |ac|
        assigned_to_klass = ac.assignment_to
        reflection = ac.assignment_to.reflections[ac.via.to_s]
        join_table = assigned_to_klass.arel_table
        target_table = @klass.arel_table

        query = a2_table.project(
          klass.arel_table.primary_key.as('id'),
          a2_table[:role_id].as('role_id'),
          a2_table[:permission_id].as('permission_id')
        )

        query.project(klass.arel_table[:paper_id]) if klass.column_names.include?('paper_id')

        if assigned_to_klass <=> @klass
          query.outer_join(join_table).on(join_table.primary_key.eq(a2_table[:assigned_to_id]).and(a2_table[:assigned_to_type].eq(assigned_to_klass.name)))
          query

        elsif reflection.collection? || reflection.has_one?
          # E.g. Journal has_many :tasks, :through => :papers
          if reflection.respond_to?(:through_options)
            loop do
              # this is the Paper reflection
              delegate_reflection = reflection.delegate_reflection
              through_reflection = assigned_to_klass.reflections[delegate_reflection.options[:through].to_s]
              through_klass = through_reflection.klass
              through_table = through_reflection.klass.arel_table

              # this is the Task reflection (from the perspective of Paper)
              through_target_reflection = through_klass.reflections[reflection.name.to_s]
              through_target_table = through_target_reflection.klass.arel_table

              # construct the join from journals table to the a2_table
              query.outer_join(join_table).on(
                join_table.primary_key.eq(a2_table[:assigned_to_id]).and(a2_table[:assigned_to_type].eq(assigned_to_klass.name))
              )

              # construct the join from papers table to the journals table
              query.outer_join(through_table).on(
                through_table[through_reflection.foreign_key].eq(
                  join_table.primary_key
                )
              )

              # construct the join from tasks table to the papers table
              query.outer_join(target_table).on(target_table[reflection.foreign_key].eq(through_klass.arel_table.primary_key))

              # the next two lines are for supporting a :through that goes thru a :through
              # it is completely untested and may not even be important. If it isn't we may
              # be able to get rid of the whole looping construct
              break unless delegate_reflection.respond_to?(:delegate_reflection)
              reflection = delegate_reflection
            end

            query.where(join_table.primary_key.eq(a2_table[:assigned_to_id]).and(a2_table[:assigned_to_type].eq(assigned_to_klass.name)))

            query
          else
            query.outer_join(join_table).on(join_table.primary_key.eq(a2_table[:assigned_to_id]).and(a2_table[:assigned_to_type].eq(assigned_to_klass.name)))
            query.outer_join(target_table).on(target_table[reflection.foreign_key].eq(join_table.primary_key))
            query
          end
        elsif reflection.belongs_to?
            query.outer_join(join_table).on(join_table.primary_key.eq(a2_table[:assigned_to_id]).and(a2_table[:assigned_to_type].eq(assigned_to_klass.name)))
            query.outer_join(target_table).on(join_table[reflection.foreign_key].eq(target_table.primary_key))
            query
        else
          fail "I don't know what you're trying to pull. I'm not familiar with this kind of association: #{reflection.inspect}"
        end
      end

      return ResultSet.new if queries2union.empty?

      u = union(queries2union.first, queries2union[1..-1])

      sm = Arel::SelectManager.new(klass.arel_table.engine).
        with(composed_a2).
        project(
          table[:results_1][:id],
          Arel.sql("string_agg(distinct(concat(permissions.action::text, ':', permission_states.name::text)), ', ') AS permission_actions")
        ).
        from( Arel.sql('(' + u.to_sql + ')').as(table[:results_1].table_name) ).
        outer_join(table[:permission_requirements]).on(
          table[:permission_requirements][:required_on_type].eq(klass.name).and(
            table[:permission_requirements][:required_on_id].eq(table[:results_1][:id])
          )
        ).
        join(table[:roles]).on(
          table[:roles][:id].eq(table[:results_1][:role_id])
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
          table[:results_1][:id].not_eq(nil).and(
            table[:permission_requirements].primary_key.eq(nil).or(
              table[:permission_requirements][:permission_id].eq(table[:results_1][:permission_id])
            )
          ).and(
            table[:permissions][:applies_to].in(eligible_applies_to)
          )
        ).
        group(table[:results_1][:id])

      sm2 = Arel::SelectManager.new(klass.arel_table.engine).
        project(klass.arel_table[Arel.star], 'permission_actions').
        from( Arel.sql('(' + sm.to_sql + ')').as('results_with_permissions') ).
        join(klass.arel_table).on(klass.arel_table[:id].eq(table[:results_with_permissions][:id]))

      objects  = @target.from( Arel.sql("(#{sm2.to_sql}) AS #{klass.table_name} ") )

      # pull out permissions
      rs = ResultSet.new
      objects.each do |task|
        permissions_to_states_string = Hash[ objects.first.permission_actions.split(/\s*,\s*/).map { |f| f.split(/:/) } ]
        permissions_to_states = Hash[ permissions_to_states_string.map { |k,v|
          [k, { states: v.split(/\s*,\s*/) }]
        } ]

        rs.add_object(task, with_permissions: permissions_to_states)
      end
      rs
    end

    class ResultSet
      def initialize
        @object_permission_map = Hash.new{ |h,k| h[k] = {} }
      end

      def add_object(object, with_permissions: {})
        @object_permission_map[object].merge!(with_permissions) do |key, v1, v2|
          { states: (v1[:states] + v2[:states]).uniq.sort }
        end
      end

      def add_objects(objects, with_permissions: {})
        objects.each do |object|
          add_object object, with_permissions: with_permissions
        end
      end

      def objects
        @object_permission_map.keys
      end

      delegate :each, :map, :length, to: :@object_permission_map

      def as_json
        serializable.as_json
      end

      def serializable
        results = []
        each do |object, permissions|
          item = PermissionResult.new(
            object: { id: object.id, type: object.class.sti_name },
            permissions: permissions,
            id: "#{Emberize.class_name(object.class)}+#{object.id}"
          )

          results.push item
        end
        results
      end
    end
  end
end

class PermissionResult
  attr_accessor :object, :permissions, :id
  include ActiveModel::SerializerSupport

  def initialize(object:, permissions:, id:)
    @object = object
    @permissions = permissions
    @id = id
  end
end
# rubocop:enable all
