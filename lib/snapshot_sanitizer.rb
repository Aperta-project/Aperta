# Used to clean up snapshots from nodes that are irrelevant for comparisons
require 'json'

module SnapshotSanitizer
  def self.sanitize(snapshot)
    return snapshot unless snapshot.is_a?(Hash) || snapshot.is_a?(Array)

    if snapshot.is_a?(Array)
      return snapshot if snapshot.empty?

      check_fields = ['id', 'owner_type', 'owner_id', 'grant_number', 'website', 'additional_comments', 'funder']
      ignore_fields = [['name', 'type', 'value'], ['name', 'type', 'children']]

      snapshot = clean(snapshot, check_fields, ignore_fields)

      snapshot.each_with_index do |obj, _index|
        obj = sanitize(obj)
      end
    elsif snapshot.is_a?(Hash)
      snapshot.delete_if { |key, _value| ['id', 'answer_type'].include?(key) }

      snapshot.each do |key, value|
        snapshot[key] = sanitize(value)
      end
    end
  end

  def self.clean(json, check_fields, ignore_fields)
    temp = []
    json.each_with_index do |obj, _index|
      if ignore_fields.include?(obj.keys)
        temp << obj if check_fields.include?(obj['name'])
      end
    end
    json - temp
  end
end
