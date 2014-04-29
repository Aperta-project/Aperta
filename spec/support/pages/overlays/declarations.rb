class EnterDeclarationsOverlay < CardOverlay
  def ethics_declaration
    find_declaration(/ethics/i)
  end

  def disclosure_declaration
    find_declaration(/disclosure/i)
  end

  def interests_declaration
    find_declaration(/interests/i)
  end

  def declarations
    expect(page).to have_css '.declaration'
    all('.declaration').map { |d| DeclarationFragment.new d }
  end

  def save_declarations
    click_on 'Save declarations'
  end

  private
  def find_declaration name
    d = find(".declaration", text: name)
    DeclarationFragment.new d
  end
end
