namespace 'nested-questions' do
  desc 'Prints questions which have been deleted. The most recent deletes are printed last.'
  task print_deleted: :environment do
    puts "------------------- Deleted Questions Start ----------------------------"
    NestedQuestion.only_deleted.sort_by(&:deleted_at).each do |nq|
      puts "ID:    #{nq.id} Deleted at: #{nq.deleted_at}"
      puts "Ident: #{nq.ident}"
      puts "Type:  #{nq.value_type}"
      puts "Text:  #{nq.text}"
    end
    puts "------------------- Deleted Questions End ------------------------------"
  end

  desc 'Prints questions which have been updated. The most recent updates are printed last.'
  task print_updated: :environment do
    puts "------------------- Updated Questions Start ----------------------------"
    NestedQuestion.all.sort_by(&:updated_at).each do |nq|
      puts "ID:    #{nq.id} Updated at: #{nq.updated_at}"
      puts "Ident: #{nq.ident}"
      puts "Type:  #{nq.value_type}"
      puts "Text:  #{nq.text}"
      puts
    end
    puts "------------------- Updated Questions End ------------------------------"
  end
end
