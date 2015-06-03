require File.expand_path('../boot', __FILE__)

<% if include_all_railties? -%>
require 'rails/all'
<% else -%>
# Pick the frameworks you want:
<%= comment_if :skip_active_record %>require "active_record/railtie"
require "action_controller/railtie"
<%= comment_if :skip_action_mailer %>require "action_mailer/railtie"
require "action_view/railtie"
<%= comment_if :skip_sprockets %>require "sprockets/railtie"
<%= comment_if :skip_test %>require "rails/test_unit/railtie"
<% end -%>

Bundler.require(*Rails.groups)
require "<%= namespaced_name %>"

<%= application_definition %>
