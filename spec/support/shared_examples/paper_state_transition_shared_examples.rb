shared_examples_for "transitions save state_updated_at" do |aasm_event_hash|
  it "sets state_updated_at to the current time" do
    blk = aasm_event_hash.values.first
    callable = blk || proc {
      if [:submit!, :submit_minor_check!].include? aasm_event
        paper.send(aasm_event, paper.creator, *method_args)
      else
        paper.send(aasm_event, *method_args)
      end
    }

    Timecop.freeze(Time.current.utc) do
      instance_eval &callable
      expect(paper.state_updated_at).to eq(Time.current.utc)
    end
  end
end
