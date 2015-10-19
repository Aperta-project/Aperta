class Snapshot::BaseSerializer
  def snapshot_property name, type, value
    { :name => name, :type => type, :value => value }
  end

  def snapshot_children plural_name, singular_name, value, singular_type = "text"
    children = []
    value.each do |child|
      children.push snapshot_property(singular_name, singular_type, child)
    end
    { :name => plural_name, :type => "properties", :children => children }
  end
end
