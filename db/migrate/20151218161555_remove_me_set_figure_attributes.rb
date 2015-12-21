class RemoveMeSetFigureAttributes < ActiveRecord::Migration
  class Figure < ActiveRecord::Base
  end

  def change
    f = Figure.new
    f.aaron = "hello"
    f.save
  end
end
