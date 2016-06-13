class InstitutionalAccountsController < ApplicationController
  def index
    render json: { institutional_accounts: ReferenceJson.institutional_accounts.items }
  end
end
