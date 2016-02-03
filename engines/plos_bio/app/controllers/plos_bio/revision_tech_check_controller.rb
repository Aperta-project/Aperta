require_dependency "plos_bio/application_controller"

module PlosBio
  class RevisionTechCheckController < ApplicationController
    include TechCheckController

    def letter_text(task)
      task.body["revisedTechCheckBody"]
    end
  end
end
