# Used to clean up snapshots from nodes that are irrelevant for comparisons
require 'json'

module SnapshotSanitizer
  CHECK_FIELDS = ['id', 'owner_type', 'owner_id', 'grant_number', 'website', 'additional_comments', 'funder'].freeze
  IGNORE_FIELDS = [['name', 'type', 'value'], ['children', 'name', 'type']].freeze

  def self.sanitize(snapshot)
    return snapshot unless snapshot.is_a?(Hash) || snapshot.is_a?(Array)

    if snapshot.is_a?(Array)
      return snapshot if snapshot.empty?
      snapshot = clean(snapshot)
      snapshot.map(&method(:sanitize))
    elsif snapshot.is_a?(Hash)
      snapshot.delete_if { |key| ['id', 'answer_type'].include?(key) }
      snapshot.each do |key, value|
        snapshot[key] = sanitize(value)
      end
    end
  end

  def self.clean(content)
    temp = []
    content.each_with_index do |obj|
      if IGNORE_FIELDS.include?(obj.keys.sort)
        temp << obj if CHECK_FIELDS.include?(obj['name'])
      end
    end
    content - temp
  end
end
