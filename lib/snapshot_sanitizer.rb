# Used to clean up snapshots from nodes that are irrelevant for comparisons
require 'json'

module SnapshotSanitizer
  def self.sanitize(snapshot)
    return snapshot unless snapshot.is_a?(Hash) || snapshot.is_a?(Array)

    if snapshot.is_a?(Array)
      return snapshot if snapshot.empty?
      check_fields = ['id', 'owner_type', 'owner_id', 'grant_number', 'website', 'additional_comments', 'funder']
      ignore_fields = [['name', 'type', 'value'], ['children', 'name', 'type']]
      snapshot = clean(snapshot, check_fields, ignore_fields)
      snapshot.map(&method(:sanitize))
    elsif snapshot.is_a?(Hash)
      snapshot.delete_if { |key| ['id', 'answer_type'].include?(key) }
      snapshot.each do |key, value|
        snapshot[key] = sanitize(value)
      end
    end
  end

  def self.clean(content, check_fields, ignore_fields)
    temp = []
    content.each_with_index do |obj|
      if ignore_fields.include?(obj.keys.sort)
        temp << obj if check_fields.include?(obj['name'])
      end
    end
    content - temp
  end
end
