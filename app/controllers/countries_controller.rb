class CountriesController < ApplicationController

  include CountriesHelper

  rescue_from NedCountries::ConnectionError, with: :render_ned_error

  def index
    render json: { countries: countries }
  end

  private

  def countries
    if NedCountries.enabled?
      NedCountries.new.countries
    else
      # default country list if NED is not configured
      countries_list
    end
  end

  def render_ned_error
    head 500
  end

end
