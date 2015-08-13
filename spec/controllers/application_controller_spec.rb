require 'rails_helper'
require File.join(File.dirname(__FILE__), "concerns/invitation_codes_examples")

describe ApplicationController do
  controller do
    def index
      redirect_to "/"
    end
  end

  include_examples "controller supports invitation codes"
end
