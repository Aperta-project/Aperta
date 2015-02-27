class AddCollaboratorsOverlay < PageFragment
  text_assertions :collaborator, ".collaborator .name"

  def add_collaborators(*users)
    users.map(&:full_name).each do |name|
      pick_from_select2_single name, name, class: 'collaborator-select'
    end
  end

  def has_collaborators?(*collaborators)
    collaborators.all? do |collaborator|
      has_collaborator? collaborator.full_name
    end
  end

  def has_no_collaborators?
    has_no_css?(".collaborator")
  end

  def remove_collaborators(*collaborators)
    collaborators.map(&:full_name).each do |name|
      first('.collaborator .email').hover
      find('.delete-button').click
    end
  end

  def save
    find('.button-primary', text: 'SAVE').click
    expect(session).to have_no_css('.show-collaborators-overlay')
  end
end

