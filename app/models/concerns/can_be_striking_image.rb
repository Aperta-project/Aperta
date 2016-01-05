# Mixin for models that can be a striking image
module CanBeStrikingImage
  def striking_image
    paper.striking_image == self
  end

  def striking_image=(value)
    if value
      paper.update! striking_image: self
    elsif striking_image
      paper.update! striking_image: nil
    end
  end
end
