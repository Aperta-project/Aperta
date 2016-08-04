shared_examples_for "transitions save state_updated_at" do |aasm_event_hash|
  it "sets state_updated_at to the current time" do
    blk = aasm_event_hash.values.first ||
      fail(
        ArgumentError,
        "Please provide a key/value proc that performs the state transition, " +
        "e.g.: submit: -> { paper.submit! arg1, arg2 }")

    Timecop.freeze(Time.current.utc) do
      instance_eval &blk
      expect(paper.state_updated_at).to eq(Time.current.utc)
    end
  end
end
