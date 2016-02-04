require_dependency "plos_bio/application_controller"

module PlosBio
  class InitialTechCheckController < ApplicationController
    include TechCheckController

    def letter_text(task)
      task.body["initialTechCheckBody"]
    end
  end
end
