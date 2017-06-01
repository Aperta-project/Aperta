require 'differ'

# Service class that handles the migration of Snapshots.  It handles
# the busy work of reaching into the JSONB content and modifying
# the values
class SnapshotMigrator
  def initialize(source_type, keys, converter, dry_run: false)
    @source_type = source_type
    @converter = converter
    @keys = keys
    @dry_run = dry_run
  end

  def call!
    Snapshot.where(
      "contents ->> 'name' = '#{@source_type}'"
    ).find_each do |snapshot|
      # puts "Migrating #{@source_type} snapshot #{snapshot.id}"
      @keys.each do |key|
        index = find_index(snapshot, key)
        next unless !index.nil? && source_exists?(snapshot)
        before = snapshot.contents['children'][index]['value']
        next if before.blank?
        after = @converter.call!(before)
        snapshot.contents['children'][index]['value'] = after
        if @dry_run
          next if before.strip == after.strip
          # diffs = Differ.diff_by_word(after, before).to_s.gsub(/\s/, ' ')
          # puts "SNAPSHOT #{@source_type} MIGRATION: #{diffs}"
        else
          snapshot.save!
        end
      end
    end
  end

  private

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
