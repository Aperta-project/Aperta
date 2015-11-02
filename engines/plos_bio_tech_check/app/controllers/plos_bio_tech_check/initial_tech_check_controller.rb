require_dependency "plos_bio_tech_check/application_controller"

module PlosBioTechCheck
  class InitialTechCheckController < ApplicationController
    include TechCheckController

    def letter_text(task)
      task.body["initialTechCheckBody"]
    end
  end
end
