shared_examples_for "transitions save state_updated_at" do |aasm_event|
  it "sets state_updated_at to the current time" do
    Timecop.freeze(Time.current.utc) do
      if [:submit!, :submit_minor_check!].include? aasm_event
        paper.send(aasm_event, paper.creator)
      else
        paper.send(aasm_event)
      end
      expect(paper.state_updated_at).to eq(Time.current.utc)
    end
  end
end
