module AuthorizationSpecHelper
  extend ActiveSupport::Concern

  class_methods do
    def permissions(label=nil, &blk)
      let_name = ['permissions', label].compact.join('_')
      let!(let_name) do
        PermissionSpecHelper.create_permissions(label, &blk)
      end
    end

    def permission(action:, applies_to:, states:)
      let_name = ['permission', action, applies_to].compact.join('_')
      let!(let_name) do
        PermissionSpecHelper.create_permission(let_name, action: action, applies_to: applies_to, states: states)
      end
    end

    def role(name, participates_in: [], &blk)
      let_name = ['role', name].compact.join('_').gsub(/\s+/, '_')
      let!(let_name) do
        RoleSpecHelper.create_role(name, participates_in: participates_in, &blk)
      end
    end
  end

  def assign_user(user, to:, with_role:)
    user.assignments.where(assigned_to: to, role: with_role).first_or_create
  end

  def count_queries(message, &blk)
    queries = 0
    subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |key, started, finished, unique_id, data|
      queries += 1
    end
    yield blk
    puts "#{message} took #{queries} queries"
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  def clear_roles_and_permissions
    # start with a blank state for these examples
    Role.destroy_all
    Permission.destroy_all
    PermissionState.destroy_all
  end

end
