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
      countries_list
    end
  rescue => ex
    Rails.logger.error("Error retrieving country list: #{ex}")
    countries_list
  end
end
