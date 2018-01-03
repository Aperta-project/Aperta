# This model exists to allow us to test whether the database is writeable
# during the health checks done for the load balancer.
# Clearly we cannot write garbage to any (other) production table for such a
# purpose, so it only makes sense to have a separate table for that purpose.

# WHAT DO WE WANT TO DO WITH THIS AND THE ASSOCIATED DATA?
class Scratch < ActiveRecord::Base
  validates :contents, presence: true
end
