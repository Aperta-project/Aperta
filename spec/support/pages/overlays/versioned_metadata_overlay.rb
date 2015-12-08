class VersionedMetadataOverlay < CardOverlay
  def expect_version(version)
    expect(page).to have_content(version)
  end

  def expect_versions(version1, version2)
    expect(page).to have_content(version1)
    expect(page).to have_content(version2)
  end
end
