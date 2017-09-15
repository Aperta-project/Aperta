# rubocop:disable Metrics/ModuleLength
module Hierarchical
  extend ActiveSupport::Concern

  def hierarchy
    contents = load_hierarchy(id)
    attrs = extract_attributes(contents)
    validations = extract_validations(contents)
    contents = merge_attributes(contents, attrs, validations)
    root = construct_hierarchy(contents)
    ContentHierarchy.new(root)
  end

  private

  def load_hierarchy(id)
    result = self.class.connection.select_all(combined_sql(id))
    rows = result.map do |row|
      row.each { |key, value| row[key] = result.column_types[key].type_cast_from_database(value) }
    end
    rows.group_by { |row| row['id'] }
  end

  def extract_attributes(contents)
    contents.each_with_object({}) do |(id, rows), attrs|
      attrs[id] = rows.each_with_object({}) do |row, hash|
        type = row['value_type']
        hash[row['attribute']] = row["#{type}_value"]
      end
    end
  end

  VALIDATION_KEYS = %w[validation_type validator error_message].freeze

  def extract_validations(contents)
    contents.each_with_object({}) do |(id, rows), validations|
      unique = rows.each_with_object({}) do |row, hash|
        values = VALIDATION_KEYS.map { |key| row[key] }.compact
        next if values.empty?
        hash[row['val_id']] = VALIDATION_KEYS.each_with_object({}) { |key, validation| validation[key] = row[key] }
      end
      validations[id] = unique.values
    end
  end

  def merge_attributes(contents, attrs, validations)
    contents.each_with_object({}) do |(id, rows), hash|
      rows.first.try do |row|
        clean_attributes(row)
        id = row['id']
        result = row.merge(attrs[id].compact)
        result['validations'] = validations[id] if validations[id].any?
        hash[id] = result
      end
    end
  end

  METADATA_KEYS = %w[val_id attribute path value_type].freeze

  def clean_attributes(row)
    METADATA_KEYS.each { |key| row.delete(key) }
    VALIDATION_KEYS.each { |key| row.delete(key) }
    Attributable::CONTENT_TYPES.each { |type| row.delete("#{type}_value") }
    row.compact!
  end

  def node_map(contents)
    contents.each_with_object({}) { |(id, row), hash| hash[id] = ContentNode.new(row) }
  end

  def construct_hierarchy(contents)
    root = nil
    nodes = node_map(contents)
    contents.each do |id, row|
      parent_id = row.delete('parent_id')
      if parent_id.nil?
        root = nodes[id]
      else
        parent = nodes[parent_id]
        next unless parent
        parent.children << nodes[id]
      end
    end

    root
  end

  # This recursive query linearizes the card_content hierarchy based on the parent_id.

  # The WITH portion of the query is called a Common Table Expression (CTE),
  # which acts as a temporary table accumulating the records selected during the query.
  # Note that "hierarchy" is not a reserved work; it's just a particularly good name for the CTE.

  # Recursive queries use the UNION SELECT syntax to specify a base case and an induction case.
  # The first SELECT (base) pulls the root record (parent_id is null);
  # the second SELECT (cc) joins each child card_content record to its parent.

  # The actual recursion occurs in the "inner join hierarchy" line of the induction SELECT,
  # where the card content record is joined to the records being accumulated in the CTE.

  # Postgres executes the base SELECT once, and the induction SELECT repeatedly,
  # joining child records to their parents, and adding them to the CTE,
  # until the induction SELECT returns zero rows, which terminates the recursive query.

  # The query computes the path to the root for each card_content record.
  # It does this by, in the base SELECT, creating a PATH array containing the root id;
  # and in the induction SELECT, appending the child id (cc.id) to the PATH array.

  # The final SELECT at the bottom pulls the rows from the CTE temporary table,
  # sorting them by the path array from the root to the leaves.

  # This particular query joins the card_contents table with the content_attributes
  # and card_content_validations, so the entirety of a card is loaded in one query.
  # Attributes are unique by name, but validations cannot be distinguised by their content,
  # so the query output disambiguates them by their validation ids.

  def combined_sql(id)
    <<-SQL
    with recursive hierarchy as (
      select
        base.id, base.parent_id, array[base.id] AS path,
        base.content_type, base.ident,
        attr.name as attribute,
        attr.value_type, attr.string_value, attr.integer_value, attr.boolean_value, attr.json_value,
        vals.id as val_id,
        vals.validation_type, vals.validator, vals.error_message
      from
        card_contents base
        left outer join content_attributes attr on attr.card_content_id = base.id
        left outer join card_content_validations vals on vals.card_content_id = base.id
      where
        parent_id is NULL and card_version_id = #{id}

      UNION

      select
        cc.id, cc.parent_id, (base.path || cc.id) as path,
        cc.content_type, cc.ident,
        attr.name as attribute,
        attr.value_type, attr.string_value, attr.integer_value, attr.boolean_value, attr.json_value,
        vals.id as val_id,
        vals.validation_type, vals.validator, vals.error_message
      from
        card_contents cc
        inner join hierarchy base on base.id = cc.parent_id
        left outer join content_attributes attr on attr.card_content_id = cc.id
        left outer join card_content_validations vals on vals.card_content_id = cc.id
      where
        card_version_id = #{id}
    )

    select * from hierarchy order by path;
    SQL
  end
end
