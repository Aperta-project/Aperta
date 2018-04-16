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

# An instance of this model represents a half-finished feature whose
# presence we're still masking from production users. Because of our
# current deployment stack, it is more convenient to enable and
# disable these features in the database than in environment
# variables.
#
# FeatureFlag[:YOUR_FEATURE] returns a boolean
#
# NOTE: To create a NEW feature flag, modify the create_feature_flags
# rake task! Ditto to remove an unneeded flag once all conditionals
# have been removed.
#
# To turn a feature on or off, visit /admin/feature_flags as a user
# with the site_admin role.
#
class FeatureFlag < ActiveRecord::Base
  include ViewableModel
  # Fields:
  # name: string (acts as ID)
  # active: boolean (true if the incomplete feature should be visible)

  def user_can_view?(_check_user)
    true # everyone can view these
  end

  def self.contain_exactly!(flags)
    transaction do
      flags.each do |flag|
        find_or_create_by(name: flag) do |feature|
          feature.active = false
        end
      end
      where.not(name: flags).destroy_all
    end
  end

  # This is a nice bit of sugar, but it also ensures that it's harder
  # to accidentally *set* flags, AND it abstracts away the fact that
  # these are in the database instead of the environment.
  def self.[](flag)
    find_by(name: flag.to_s).try(:active)
  end
end
