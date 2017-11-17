class CountriesController < ApplicationController
  include CountriesHelper

  def index
    render json: { countries: countries.sort_alphabetical }
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
end
