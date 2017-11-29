RSpec.shared_examples_for :behavior_subclass do
  it 'should not allow some random attr' do
    expect {
      described_class.new(xxx_attr: true, **args)
    }.to raise_error(ActiveRecord::UnknownAttributeError)
  end
end
