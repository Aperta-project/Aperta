require 'rails_helper'

describe BillingFTPUploader do
  describe '#initialize' do
    it 'raises an error for nil argument' do
      expect { BillingFTPUploader.new(nil) }.to raise_exception(ArgumentError)
    end
  end
end
