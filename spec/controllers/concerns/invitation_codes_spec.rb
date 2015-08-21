require 'rails_helper'
require File.join(File.dirname(__FILE__), "invitation_codes_examples")

describe InvitationCodes do
  controller(ActionController::Base) do
    include InvitationCodes

    def index
      redirect_to "/"
    end
  end

  include_examples "controller supports invitation codes"
end
