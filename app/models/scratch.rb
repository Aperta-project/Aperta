class Scratch < ActiveRecord::Base
  # This model exists to allow us to test whether the database is writeable
  # during the health checks done for the load balancer.
  # Clearly we cannot write garbage to any (other) production table for such a
  # purpose, so it only makes sense to have a separate table for that purpose.

  validates_presence_of :contents
end
