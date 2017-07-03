namespace :reports do
  task analyze_cover_letters: :environment do
  	papers = blanks = balanced = unbalanced = returns = both = 0

    inactive_states = %w(rejected withdrawn accepted)
    current_papers = Paper.select(:id).where.not(publishing_state: inactive_states).pluck(:id).map(&:to_i)

  	Paper.where(id: current_papers).order(:id).all.each do |paper|
  		cover_letters = paper.tasks.where(type: 'TahiStandardTasks::CoverLetterTask').all
  		cover_letters.each do |letter|
  			answers = letter.answers.load
  			answers.each do |answer|
  				text = answer.value
  				(blanks += 1; next) if text.blank?
  				papers += 1

  				has_returns = text =~ /\n/
  				returns += 1 if has_returns

  				matched = text =~ /\<[\S].*\>/
  				balanced += 1 if matched

  				unmatched = text =~ /(\<[\S])|(\>[\S])/
  				unbalanced += 1 if unmatched

  				brackets = matched || unmatched
  				messy = has_returns && brackets
  				both += 1 if messy

  				tag = if messy
	  				"*** Returns and Brackets"
	  			elsif (!has_returns)
	  				"*?* No Newlines [#{text.length}]"
		  		elsif matched
	  				"*+* matched brackets"
		  		elsif unmatched
	  				"*-* unmatched brackets"
		  			else
	  				nil
	  			end

  				puts "Paper [#{paper.id}] Answer [#{answer.id}]: #{tag} \n#{text}" if tag
  			end
  		end
  	end
  	puts "Papers: #{papers}, Blanks: #{blanks}, (Returns: #{returns}, Balanced: #{balanced}, Unbalanced: #{unbalanced}, Both: #{both})"
  end
end
