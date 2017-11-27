# Used to clean up snapshots from nodes that are irrelevant for comparisons
module SnapshotSanitizer
  CHECK_FIELDS = ['id', 'owner_type', 'owner_id', 'grant_number', 'website', 'additional_comments', 'funder'].freeze
  IGNORE_FIELDS = [['name', 'type', 'value'], ['children', 'name', 'type']].freeze

  def self.sanitize(snapshot)
    return snapshot unless snapshot.is_a?(Hash) || snapshot.is_a?(Array)

    if snapshot.is_a?(Array)
      return snapshot if snapshot.empty?
      snapshot = clean_snapshot(snapshot)
      snapshot.map(&method(:sanitize))
    else
      snapshot = snapshot.except('id', 'answer_type')
      snapshot.each do |key, value|
        snapshot[key] = sanitize(value)
      end
    end
  end

  def self.clean_snapshot(content)
    content.inject([]) do |clean_array, obj|
      clean_array << obj unless IGNORE_FIELDS.include?(obj.keys.sort) || CHECK_FIELDS.include?(obj['name'])
      clean_array
    end
  end
end
