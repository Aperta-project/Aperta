require_dependency "plos_bio_tech_check/application_controller"

module PlosBioTechCheck
  class FinalTechCheckController < ApplicationController
    include TechCheckController

    def letter_text(task)
      task.body["finalTechCheckBody"]
    end
  end
end
