# rubocop:disable all
module Authorizations
  class QueryAgainstAuthorization
    attr_reader :assignments, :assigned_to_klass, :authorization, :permissible_states

    def initialize(authorization:, klass:, target:, assignments:, assigned_to_klass:, permissible_states:)
      @authorization = authorization
      @klass = klass
      @target = target
      @assignments = assignments
      @assigned_to_ids = assignments.map(&:assigned_to_id)
      @assigned_to_klass = assigned_to_klass
      @permissible_states = permissible_states
    end

    def base_query
      assigned_to_klass
        .joins(authorization.via.to_sym).includes(authorization.via.to_sym)
        .where(id: assignments.map(&:assigned_to_id))
    end

    def query_against_specific_model
      query = base_query.where(@klass.table_name => { id: @target.id } )

      if @target.class.column_names.include?('required_permission_id')
        field = "#{@target.class.table_name}.required_permission_id"
        assigned_permission_ids = assignments.flat_map(&:permissions).map(&:id)
        query.where(
          "#{field} IS NULL OR #{field} IN (:permission_ids)",
          permission_ids: assigned_permission_ids
        )
      end
      query
    end

    def query
      if @target.is_a?(ActiveRecord::Base)
        query = query_against_specific_model
      elsif @target.is_a?(ActiveRecord::Relation)
        query = query_against_active_record_relation
      end

      if !permissible_states.include?('*') && @klass.column_names.include?("publishing_state")
        query = query.where(@klass.table_name => { publishing_state: permissible_states } )
      end

      authorized_objects = if @authorization.via != :self
        query.flat_map(&authorization.via).uniq
      else
        query.uniq
      end
    end

    private

    def query_against_active_record_relation
      query = base_query

      reflection = authorization.assignment_to.reflections[authorization.via.to_s]

      updated_where_values = @target.where_values.map do |value|
        if value.is_a?(Arel::Nodes::Node) && value.respond_to?(:right) && value.right.is_a?(Arel::Nodes::BindParam)
          # no-op
        else
          value = value.to_sql if value.respond_to?(:to_sql)
          value.gsub(/\b([^\s]+)\s*(\=|\!\=|<>)/) do |field_name|
            field_name_includes_table_reference = field_name.include?('.')
            unless field_name_includes_table_reference
              "#{reflection.table_name}.#{field_name}"
            else
              field_name
            end
          end
        end
      end.compact

      if updated_where_values.any?
        query = query.where(updated_where_values)
      else
        query = query.merge @target
      end

      if @target.model.column_names.include?('required_permission_id')
        field = "#{@target.table.name}.required_permission_id"
        query = query.where(
          "#{field} IS NULL OR #{field} IN (:permission_ids)",
          permission_ids: assignments.flat_map(&:permissions).map(&:id)
        )
      end
      query
    end
  end
end
# rubocop:enable all
