class VersionedMetadataOverlay < CardOverlay
  def expect_version(version)
    expect(page).to have_content(version)
  end
end
