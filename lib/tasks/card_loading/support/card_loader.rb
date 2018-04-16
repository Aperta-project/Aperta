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

require_relative "./card_factory"
Dir[Rails.root.join("lib/tasks/card_loading/configurations/*.rb")].each { |f| require f }
Dir[Rails.root.join("lib/tasks/card_loading/configurations/nonstandard_configurations/*")].each { |f| require f }

# This class is responsible for looking up one or more CardConfiguration
# classes and sending it to the CardFactory so that new Cards can be created in
# the system with the correct attributes.
#
class CardLoader
  def self.load_standard(journal: nil)
    CardFactory.new(journal: journal).create(standard_card_configuration_klasses)
  end

  def self.load(owner_klass, journal: nil)
    CardFactory.new(journal: journal).create(find_configuration_klass(owner_klass))
  end

  # find particular card configuration klass by examining it's name
  def self.find_configuration_klass(name)
    configuration_klass = card_configuration_klasses.find { |klass| klass.name == name }
    raise "Cannot find card configuration class for #{name}" unless configuration_klass
    configuration_klass
  end

  # array of all normal card configuration classes
  #  [CardConfiguration::Author, CardConfiguration::AuthorsTask ...]
  def self.standard_card_configuration_klasses
    @standard_configurations ||= begin
      CardConfiguration.constants.map(&CardConfiguration.method(:const_get)).grep(Class)
    end
  end

  # array of all card configuration classes we don't want on production
  def self.nonstandard_card_configuration_klasses
    @nonstandard_configurations ||= begin
      mmodule = CardConfiguration::NonstandardConfigurations
      mmodule.constants.map(&mmodule.method(:const_get)).grep(Class)
    end
  end

  def self.card_configuration_klasses
    standard_card_configuration_klasses + nonstandard_card_configuration_klasses
  end
end
