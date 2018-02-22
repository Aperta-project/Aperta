class SecurityAudit < ActiveRecord::Base
  DB_PARAMS = YAML.load_file(Rails.root.join('config', 'database.yml'))
  establish_connection DB_PARAMS['development']

  belongs_to :user

  def payload=(json)
    super
    hash = JSON.parse(json)
    self.key_names  = format_names(find_keys(hash))
    self.data_types = format_names(find_types(hash))
  end

  def find_keys(data)
    case data
    when Hash
      data.keys + data.flat_map {|k, v| find_keys(v)}
    when Array
      data.flat_map {|each| find_keys(each)}
    else
      []
    end
  end

  def find_types(data)
    case data
    when Hash
      data.values.map(&:class) + data.flat_map {|k, v| find_types(v)}
    when Array
      data.flat_map {|each| find_types(each)}
    else
      [data.class]
    end
  end

  def format_names(list)
    list.map(&:to_s).uniq.sort.join(',')
  end
end
