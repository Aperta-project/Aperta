require 'rails_helper'

describe Setting do
  describe 'validations and defaults via SettingTemplate' do
    context 'possible values' do
      context 'the setting has an empty array of possible values' do
        it "does not validate the value against anything" do
          template = FactoryGirl.create(:setting_template, value: "foo")
          setting = FactoryGirl.create(:setting, setting_template: template, value: "foo")
          expect(setting).to be_valid
        end
      end
      context "the setting's possible values are present" do
        it "validates the inclusion of the value in the possible values" do
          template = FactoryGirl.create(:setting_template, :with_possible_values, value: "foo", possible_values: ["foo", "bar"])
          setting = FactoryGirl.create(:setting, value: "foo", setting_template: template)
          expect(setting).to be_valid
          setting.value = "baz"
          expect(setting).to have(1).errors_on(:value)
        end
      end
    end
  end
end
