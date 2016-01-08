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

    def role(name, &blk)
      let_name = ['role', name].compact.join('_')
      let!(let_name) { RoleSpecHelper.create_role(name, &blk) }
    end
  end

  def assign_user(user, to:, with_role:)
    user.assignments.create(assigned_to: to, role: with_role)
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

end
