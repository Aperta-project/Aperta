def print_merge_fields(fields, level = 0)
  fields.each do |field|
    print '__' * level, field[:name]
    print '[]' if field[:is_array]
    print "\n"
    print_merge_fields(field[:children], level + 1) if field[:children]
  end
end

namespace :reports do
  task print_letter_template_scenarios: :environment do
    TemplateContext.scenarios.each do |name, klass|
      puts "\n#{name}"
      print_merge_fields(klass.merge_fields)
    end
  end
end
