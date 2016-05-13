module PlosBioTechCheck
  class RevisionTechCheckController < ApplicationController
    include TechCheckController

    def letter_text(task)
      task.body["revisedTechCheckBody"]
    end
  end
end
