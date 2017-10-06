class CountriesController < ApplicationController
  include CountriesHelper

  def index
    render json: { countries: countries.sort_alphabetical }
  end

  private

  def countries
    return countries_list unless NedCountries.enabled?

    begin
      NedCountries.new.countries
    rescue => ex
      log_error("Error retrieving country list: #{ex}")
      countries_list
    end
  end

  def log_error(error)
    Rails.logger.error(error)
    Bugsnag.notify(error)
  end
end
