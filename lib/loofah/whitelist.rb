require 'set'

module Loofah::HTML5::WhiteList
  # ruby metaprogramming doesn't allow the redefinition of constants
  # unsetting the constants to eradicate continous server warning
  send(:remove_const, 'ALLOWED_CSS_PROPERTIES')
  send(:remove_const, 'ACCEPTABLE_CSS_PROPERTIES')

  new_props = Set.new %w[azimuth background-color border-bottom-color
  border-collapse border-color border-left-color border-right-color
  border-top-color clear color cursor direction display elevation
  float font font-family font-size font-style font-variant font-weight
  height letter-spacing line-height overflow pause pause-after pause-before
  pitch pitch-range richness speak speak-header speak-numeral speak-punctuation
  speech-rate stress text-align text-decoration text-indent unicode-bidi
  vertical-align voice-family volume white-space width list-style-type]

  # setting back our constants to the right values
  const_set('ACCEPTABLE_CSS_PROPERTIES', new_props)
  const_set('ALLOWED_CSS_PROPERTIES', new_props)

  ::Loofah::MetaHelpers.add_downcased_set_members_to_all_set_constants ::Loofah::HTML5::WhiteList
end
