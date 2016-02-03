require_dependency "plos_bio/application_controller"

module PlosBio
  class FinalTechCheckController < ApplicationController
    include TechCheckController

    def letter_text(task)
      task.body["finalTechCheckBody"]
    end
  end
end
