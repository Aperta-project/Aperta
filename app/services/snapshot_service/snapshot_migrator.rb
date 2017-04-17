# Service class that handles the migration of Snapshots.  It handles
# the busy work of reaching into the JSONB content and modifying
# the values
class SnapshotMigrator
  def initialize(source_type, keys, converter)
    @source_type = source_type
    @converter = converter
    @keys = keys
  end

  def call!
    Snapshot.where(
      "contents ->> 'name' = '#{@source_type}'"
    ).find_each do |snapshot|
      Rails.logger("Migrating snapshot #{snapshot.id}")
      @keys.each do |key|
        index = find_index(snapshot, key)
        next unless !index.nil? && source_exists?(snapshot)
        snapshot.contents['children'][index]['value'] =
          @converter.call!(snapshot.contents['children'][index]['value'])
        snapshot.save!
      end
    end
  end

  private

  def source_exists?(snapshot)
    index = find_index(snapshot, 'name')
    id = snapshot.contents['children'][index]['value']
    arr ||= @source_type.split('-')
    klass ||= arr.map(&:capitalize).join.constantize
    klass.exists?(id)
  end

  def find_index(snapshot, key)
    snapshot.contents['children'].find_index do |current_key|
      current_key['name'] == key
    end
  end
end
