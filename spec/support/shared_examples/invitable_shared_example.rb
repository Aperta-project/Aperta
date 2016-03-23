shared_examples_for 'a task that sends out invitations' do |invitee_role:|
  describe '#invitee_role' do
    it 'returns the expected invitee_role' do
      expect(task.invitee_role).to_not be_nil
      expect(task.invitee_role).to eq invitee_role
    end
  end
end
