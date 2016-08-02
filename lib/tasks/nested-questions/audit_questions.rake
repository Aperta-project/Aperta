namespace 'nested-questions' do
  desc "Audits nested questions to make sure none have been added or removed"
  task audit: :environment do
    expected_questions_file = File.read(questions_file)
    expected_questions = JSON.parse(expected_questions_file)

    errors = false
    puts "Verification started.\n\n"

    expected_questions.each do |expected|
      actual = NestedQuestion.find_by(id: expected["id"])
      if actual.nil?
        puts "Question #{expected["id"]}, ident: '#{expected["ident"]}':\n  Question was removed."
        errors = true
      else
        errors ||= verify_question(expected, actual)
      end
    end

    NestedQuestion.all.each do |actual|
      expected = expected_questions.find { |q| q["id"] == actual.id }

      if expected.nil?
        puts "Question #{actual.id}, ident: '#{actual.ident}':\n  Question was added."
        errors = true
      else
        errors ||= verify_question(expected, actual)
      end
    end

    if errors
      puts "Errors found.\n\n"
    else
      puts "No errors found.\n\n"
    end

    puts "Verification complete."
  end

  def verify_question(expected, actual)
    errors = false

    expected.each do |key, value|
      if value != actual.send(key.to_sym)
        puts "Question #{expected["id"]}, ident: '#{expected["ident"]}':\n  expected '#{key}=#{value}' got '#{key}=#{actual.send(key.to_sym)}'."
        errors = true
      end
    end

    errors
  end

  def questions_file
    "#{Rails.root}/lib/tasks/nested-questions/expected_questions.json"
  end

  task dump_questions: :environment do
    puts "Think carefully before running this command.  Removing questions will also remove their answers"
    puts "and we will lose data in production with no chance of recovery."

    unless ARGV[1] == "I have thought about this"
      puts "Aborting."
      return
    end

    questions = ""
    NestedQuestion.all.map do |q|
      e = { id: q.id,
            text: q.text,
            value_type: q.value_type,
            ident: q.ident,
            parent_id: q.parent_id,
            lft: q.lft,
            rgt: q.rgt,
            position: q.position,
            owner_type: q.owner_type,
            owner_id: q.owner_id }
      questions << "#{e.to_json},\n\n"
    end

    questions = questions.chomp(",\n\n")

    f = File.open(questions_file, "w")
    f.write "[ #{questions} ]"
    f.close
  end
end
