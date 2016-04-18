namespace :data do
  namespace :migrate do
    namespace :snapshots do
      desc 'Adds id fields to old snapshots'
      task snapshot_ids: :environment do
        Snapshot.all.each do |snapshot|
          SnapshotIDer.new(snapshot).add_all_ids
        end
      end
    end
  end
end

# Old snapshots do not contain the ids of the items they snapshotted.
# This adds (sometimes fake) IDs to those old snapshots in order to
# maintain the same json schema.
class SnapshotIDer
  def initialize(snapshot, counter: 0)
    @snapshot = snapshot
    @counter = counter
  end

  def add_all_ids
    add_an_id @snapshot.contents
    fix_children @snapshot.contents
    @snapshot.save!
  end

  def fix_children(dict)
    return unless dict['children']

    eligible_children = [
      'figure',
      'supporting-information-file',
      'author',
      'funder'
    ]

    dict['children'].each do |child|
      if eligible_children.include?(child['name'])
        add_an_id child
      else
        idenate_nested_question child
      end

      if child['children']
        child['children'].each do |grandchild|
          fix_children grandchild
        end
      end

      @snapshot.save!
    end
  end

  def add_an_id(obj)
    # Make it idempotent and ensure it doesn't feke out good data
    return if already_has_id?(obj)

    obj['children'].append(
      'name' => 'id',
      'value' => generate_id,
      'type' => 'integer'
    )
  end

  def already_has_id?(obj)
    obj['children'].find { |c| c['name'] == 'id' }
  end

  def idenate_nested_question(q)
    return unless q['type'] == 'question'
    new_id = NestedQuestion.find_by(ident: q['name']).id || generate_id
    q['value']['id'] = new_id
  end

  def generate_id
    id = "#{@snapshot.paper.id}#{@counter}"
    @counter += 1
    id.to_i
  end
end
