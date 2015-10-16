class Snapshot::BaseSerializer
  def snapshot_property name, type, value
    { :name => name, :type => type, :value => value }
  end

  def snapshot_children plural_name, singular_name, value
    children = []
    value.each do |child|
      children.push snapshot_property(singular_name, "text", child)
    end
    { :name => plural_name, :type => "properties", :children => children }
  end
end
