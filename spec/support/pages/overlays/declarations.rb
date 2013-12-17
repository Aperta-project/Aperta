class DeclarationsOverlay < CardOverlay
  def declarations
    all('.declaration').map { |d| DeclarationFragment.new d }
  end

  def save_declarations
    click_on 'Save declarations'
  end
end
