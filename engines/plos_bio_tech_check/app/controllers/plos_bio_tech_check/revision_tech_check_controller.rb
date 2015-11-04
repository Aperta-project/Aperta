require_dependency "plos_bio_tech_check/application_controller"

module PlosBioTechCheck
  class RevisionTechCheckController < ApplicationController
    include TechCheckController

    def letter_text(task)
      task.body["revisedTechCheckBody"]
    end
  end
end
