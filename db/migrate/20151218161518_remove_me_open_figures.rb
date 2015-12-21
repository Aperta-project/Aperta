class RemoveMeOpenFigures < ActiveRecord::Migration
  class Figure < ActiveRecord::Base
  end

  def change
    # do something
    Figure.last
  end
end
