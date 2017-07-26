class NedCountries < NedConnection
  def countries
    typeclass = search("typeclasses").body.detect { |tc|
      tc["description"] == "Country Types"
    }

    search("typeclasses/#{typeclass['id']}/typevalues").body.map { |c|
      c["shortdescription"]
    }
  end
end
