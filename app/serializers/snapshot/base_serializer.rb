module Snapshot
  class BaseSerializer
    def snapshot_property name, type, value
      { :name => name, :type => type, :value => value }
    end

    def snapshot_children name, value
      { :name => name, :type => "properties", :children => value }
    end
  end
end
