puts "Starting seed data load from 'db/data.yml' file"
time = Benchmark.realtime do
  Rake::Task['db:data:load'].invoke
end
puts "Data load complete (#{time.round(3)}s)"
