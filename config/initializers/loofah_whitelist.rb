# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'set'

# ruby metaprogramming doesn't allow the redefinition of constants
# unsetting the constants to eradicate continous server warning
::Loofah::HTML5::WhiteList.send(:remove_const, 'ALLOWED_CSS_PROPERTIES')
::Loofah::HTML5::WhiteList.send(:remove_const, 'ACCEPTABLE_CSS_PROPERTIES')

new_props = Set.new %w[azimuth background-color border-bottom-color
                       border-collapse border-color border-left-color
                       border-right-color border-top-color clear color
                       cursor direction display elevation float font
                       font-family font-size font-style font-variant
                       font-weight height letter-spacing line-height
                       overflow pause pause-after pause-before pitch
                       pitch-range richness speak speak-header
                       speak-numeral speak-punctuation speech-rate
                       stress text-align text-decoration text-indent
                       unicode-bidi vertical-align voice-family volume
                       white-space width list-style-type]

# setting back our constants to the right values
::Loofah::HTML5::WhiteList.const_set('ACCEPTABLE_CSS_PROPERTIES', new_props)
::Loofah::HTML5::WhiteList.const_set('ALLOWED_CSS_PROPERTIES', new_props)

::Loofah::MetaHelpers.add_downcased_set_members_to_all_set_constants ::Loofah::HTML5::WhiteList
