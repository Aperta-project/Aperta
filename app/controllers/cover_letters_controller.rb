class CoverLettersController < ApplicationController

  def create
    @paper = Paper.find(params[:cover_letter][:paper_id])
    @cover_letter = @paper.cover_letter.create!(cover_letter_params)
    render json: @cover_letter, serializer: CoverLetterSerializer, root: 'cover_letter'
  end

  def update
    @cover_letter = cover_letter.find(params[:id])
    @cover_letter.update! cover_letter_params
    render json: @cover_letter, serializer: CoverLetterSerializer, root: 'cover_letter'
  end

  def cover_letter_params
    params.require(:cover_letter).permit(:body)
  end

end
