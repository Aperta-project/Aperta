#
# The System represents the application. It's explicitly called out
# so it can be used in the data-driven authorization (R&P) sub-system.
#
# It does not have associations for getting from the System to journals, papers,
# tasks, discussions, etc at this time because the only System-level role is
# Site Admin. However, these may need to be added as more System-level roles
# come into play based on the kinds of assignments that will take part in.
#
class System < ActiveRecord::Base
end
