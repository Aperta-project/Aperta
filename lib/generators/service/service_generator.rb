# This is a generator for services.
class ServiceGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def copy_service_file
    template 'service.rb.erb', "app/services/#{file_name}.rb"
  end

  def copy_service_spec_file
    template 'service_spec.rb.erb', "spec/services/#{file_name}_spec.rb"
  end

  private

  def service_class_name
    file_name.classify
  end
end
