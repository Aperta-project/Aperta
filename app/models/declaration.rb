class Declaration < ActiveRecord::Base

  DEFAULT_DECLARATION_QUESTIONS = [
    "COMPETING INTERESTS: do the authors have any competing interests?",
    "ETHICS STATEMENT: (if applicable) the authors declare the following ethics statement:",
    "FINANCIAL DISCLOSURE: did the funders have any role in study design, data collection and analysis, decision to publish, or preperation of the manuscript?"
  ]

  belongs_to :paper

  def self.default_declarations
    DEFAULT_DECLARATION_QUESTIONS.map { |q| Declaration.new question: q }
  end
end
