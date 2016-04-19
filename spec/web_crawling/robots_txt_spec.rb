require 'rails_helper'

describe 'robots.txt' do
  it 'disables web crawling' do
    robots_txt = File.read(Rails.root.join('public/robots.txt'))
    expect(robots_txt).to eq("User-agent: *\nDisallow: /\n")
  end
end
