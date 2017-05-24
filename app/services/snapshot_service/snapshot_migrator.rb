# Service class that handles the migration of Snapshots.  It handles
# the busy work of reaching into the JSONB content and modifying
# the values
class SnapshotMigrator
  def initialize(source_type, keys, converter, dry_run)
    @source_type = source_type
    @converter = converter
    @keys = keys
    @dry_run = dry_run
  end

  def call!
    Snapshot.where(
      "contents ->> 'name' = '#{@source_type}'"
    ).find_each do |snapshot|
      puts "Migrating snapshot #{snapshot.id}"
      @keys.each do |key|
        index = find_index(snapshot, key)
        next unless !index.nil? && source_exists?(snapshot)
        old_value = snapshot.contents['children'][index]['value']
        new_value = @converter.call!(snapshot.contents['children'][index]['value'])

        if old_value.present?
          log_value_diff(snapshot.id, key, old_value, new_value)
        end
        unless @dry_run
          snapshot.contents['children'][index]['value'] = new_value
          snapshot.save!
        end
      end
    end
  end

  private

  def log_value_diff(snapshot_id, key_name, old_value, new_value)
    if old_value != new_value
      puts "Html sanitized for snapshot #{snapshot_id} #{key_name}: #{Diffy::Diff.new(old_value, new_value, context: 1).to_s(:html)} "
    end
  end

  def source_exists?(snapshot)
    index = find_index(snapshot, 'id')
    id = snapshot.contents['children'][index]['value']
    arr = @source_type.split('-')
    klass = arr.map(&:capitalize).join.constantize
    klass.exists?(id)
  end

  def find_index(snapshot, key)
    snapshot.contents['children'].find_index do |current_key|
      current_key['name'] == key
    end
  end
end
