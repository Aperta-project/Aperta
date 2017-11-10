def print_merge_fields(fields, level = 1)
  fields.each do |field|
    print '  ' * level, field[:name]
    print '[]' if field[:many]
    print "\n"
    print_merge_fields(field[:children], level + 1) if field[:children]
  end
end

namespace :reports do
  task print_letter_template_scenarios: :environment do
    TemplateContext.scenarios.each do |name, klass|
      puts "#{name} | #{klass}"
      print_merge_fields(klass.merge_fields)
    end
  end
end
