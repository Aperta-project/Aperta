require 'rest_client'
module BenchmarkSuite
  class Emailer
    attr_accessor :test_name

    def self.call(test_name)
      new(test_name: test_name).email
    end

    def initialize(test_name:)
      @test_name = test_name
    end

    def email
      RestClient.post("https://api:#{ENV.fetch('MAILGUN_API_KEY')}@api.mailgun.net/v2/sandboxcd344b254a6446dd860757fcc93d7546.mailgun.org/messages",
                      from: 'Mailgun Sandbox <postmaster@sandboxcd344b254a6446dd860757fcc93d7546.mailgun.org>',
                      to: 'Mike Mazur <mike@neo.com>',
                      subject: "Performance test results for: #{test_name}",
                      text: "Attached",
                      multipart: true,
                      attachment: File.new(BenchmarkSuite.path(test_name), 'rb'))
    end
  end
end
