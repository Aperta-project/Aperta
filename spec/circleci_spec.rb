require 'spec_helper'

describe 'CircleCI yml configuration' do
  describe 'Missing file globs?' do
    it 'ensures we are not missing any directories with specs that start with "f"' do
      # Grab every ruby spec file that we can find starting in the
      # ROOT directory of the project
      all_specs = []
      Dir.chdir(File.dirname(__FILE__) + '/../') do
        all_specs = Dir.glob("**/spec/**/*_spec.rb")
      end

      # find out what the first directory is under "/spec/"
      top_level_spec_dirs = all_specs.map do |spec_path|
        spec_path.scan(/\/spec\/([^\/]+)/)
      end.flatten.uniq

      # if there are more than one first-directories that start with
      # "f" than the circle.yml file needs to be updated to fix its
      # file-glob
      non_feature_spec_dirs = top_level_spec_dirs - %w(features)
      expect(
        non_feature_spec_dirs.select { |path| path.start_with?('f') }
      ).to be_empty
    end
  end

end
