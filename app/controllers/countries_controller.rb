class CountriesController < ApplicationController

  include CountriesHelper

  def index
    render json: { countries: countries }
  end

  private

  def countries
    if NedCountries.enabled?
      NedCountries.new.countries.sort_alphabetical
    else
      # default country list if NED is not configured
      countries_list.sort_alphabetical
    end
  end
end
