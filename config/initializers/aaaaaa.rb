# Rails.logger.warn ">>>>>>>>>"
# Rails.logger.warn TaskType.types
# Rails.logger.warn ">>>>>>>>>"
# p ">>>>>>>>>"
# p TaskType.types
# p ">>>>>>>>>"
#
# ObjectSpace.define_finalizer(TaskType, proc {|id| p "Destroyed TaskType #{id}"; Rails.logger.warn "DESTROYED" })
# ObjectSpace.define_finalizer(TaskType.types, proc {|id| p "Destroyed TaskType.types #{id}"; Rails.logger.warn "DESTROYED" })
#

ActiveSupport::Dependencies.log_activity = true
ActiveSupport::Dependencies.logger = Rails.logger
