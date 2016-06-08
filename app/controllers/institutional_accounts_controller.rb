class InstitutionalAccountsController < ApplicationController
  def index
    render json: { institutional_accounts: ReferenceJson.find_by(name: 'Institutional Account List').items }
  end
end
