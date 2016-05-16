module PlosBioTechCheck
  class InitialTechCheckController < ApplicationController
    include TechCheckController

    def letter_text(task)
      task.body["initialTechCheckBody"]
    end
  end
end
