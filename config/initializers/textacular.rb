# fuzzy searches are subject to a similarity threshold imposed by the 
# pg_trgm module.  The default is 0.3, meaning that at least 30% of the
# total string must match your search content.

PG_SIMILARLITY = 0.1
ActiveRecord::Base.connection.execute("SELECT set_limit(#{PG_SIMILARLITY});")
