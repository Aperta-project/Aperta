class SecurityAudit < ActiveRecord::Base
  DB_PARAMS = YAML.load_file(Rails.root.join('config', 'database.yml'))
  establish_connection DB_PARAMS['development']

  belongs_to :user

  def payload=(json)
    super
    hash = JSON.parse(json)
    self.key_names  = find_keys(hash)
    self.data_types = find_types(hash)
  end

  def find_keys(hash)
    format_names(hash.keys)
  end

  def find_types(hash)
    format_names(hash.values.map(&:class))
  end

  private

  def format_names(list)
    list.map(&:to_s).uniq.sort.join(',')
  end
end
