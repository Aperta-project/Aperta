class AddCollaboratorsOverlay < PageFragment

  def add_collaborators(*users)
    users.map(&:full_name).each do |name|
      select_from_chosen name, class: 'collaborator-select', skip_synchronize: true
    end
  end

  def has_collaborators?(*collaborators)
    collaborators.all? do |collaborator|
      has_css?(".collaborator .name", text: collaborator.full_name)
    end
  end

  def has_no_collaborators?
    has_no_css?(".collaborator")
  end

  def remove_collaborators(*collaborators)
    collaborators.map(&:full_name).each do |name|
      find('.collaborator', text: name).hover
      find('.delete-button').click
    end
  end

  def save
    find('.button-primary', text: 'SAVE').click
    expect(session).to have_no_css('.show-collaborators-overlay')
  end
end

