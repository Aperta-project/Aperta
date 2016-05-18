# FakeIhatService is a way to pretend to be ihat. It is intended for feature
# specs where ensuring the full lifecycle of a procesing a paper is
# important.
module FakeIhatService
  def self.complete_paper_processing!(paper_id:, user_id:)
    process_job!(paper_id: paper_id, user_id: user_id)
  end

  def self.process_job!(
    paper_id:,
    user_id:,
    job_id: SecureRandom.hex,
    state: 'completed'
  )
    # This is the jobs URL in Aperta that ihat posts back to
    url = Rails.application.routes.url_helpers.ihat_jobs_url(
      host: Capybara.server_host,
      port: Capybara.server_port
    )

    # ihat payloads are encrypted
    encrypted_metadata = Verifier.new(
      paper_id: paper_id,
      user_id: user_id
    ).encrypt

    # these are the params that ihat will post back Aperta
    params = {
      job: {
        id:  job_id,
        state: state,
        options: {
          metadata: encrypted_metadata
        },
        outputs: [{ file_type: 'epub', url: "http://ihat.example.com/paper.epub" }]
      }
    }

    # Make the request in a new thread so as to not block the app server
    # thread that will receive/process this incoming HTTP request. This is only
    # a problem when inside of a pry session.
    thr = Thread.new do
      RestClient.post(
        url,
        params.to_json,
        content_type: :json,
        accept: :json
      )
    end

    # If our thread fails, raise hell
    thr.abort_on_exception = true

    # Don't return from method until our thread is finished
    thr.join
  end
end
