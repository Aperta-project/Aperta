class CountriesController < ApplicationController
  include CountriesHelper

  def index
    render json: { countries: countries.sort_alphabetical }
  end

  private

  # rubocop:disable Lint/HandleExceptions
  def countries
    if NedCountries.enabled?
      NedCountries.new.countries
    else
      countries_list
    end
  rescue countries_list
  end
end
