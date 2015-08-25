namespace :assets do
  task :precompile do
    # total hack to rename all .map files that rails asset pipeline
    # changes to the original (minus digest)

    # Needed because assets are compiled in ember and contain a
    # special footer (e.g. //#sourceMappingURL=foo.map) that does not
    # contain the cache busting digest.

    Dir.glob(Rails.root.join('public', 'assets', '**', '*.map')).each do |item|
      if File.file?(item) && item.match(/-[a-f0-9]{64}/)
        File.rename(item, item.gsub(/-[a-f0-9]{64}/, ''))
      end
    end
  end
end
