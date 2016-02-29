require 'csv'

module PlosServices
  class ExampleData
    def to_csv
      csv_text = File.read("#{Rails.root}/example_data.csv")
      csv = CSV.parse(csv_text, :headers => true)
    end
  end
end
