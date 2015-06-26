require "spec_helper"

# Test module for Setting.
class Configuration
  def self.reset!
    @_settings = nil
    @_default_settings = nil
  end

  include Settingable::Settings
end

RSpec.describe Settingable::Settings do
  subject { Configuration.settings }
  before(:each) { Configuration.reset! }

  it "extends the base" do
    ancestors = (class << Configuration; self; end).ancestors
    expect(ancestors)
      .to include(Settingable::Settings::ClassMethods)
  end

  describe ".settings" do
    it "returns the same instance" do
      expect(Configuration.settings).to be_a(Configuration)
      expect(Configuration.settings).to be(Configuration.settings)
    end
  end

  describe ".configure" do
    it "yields itself" do
      expect { |b| Configuration.configure(&b) }.to yield_with_args(subject)
    end

    it "returns itself" do
      expect(Configuration.configure {}).to be subject
    end
  end

  describe ".[]" do
    it "maps to the .settings instance" do
      subject[:hello] = "world"
      expect(Configuration[:hello]).to eq "world"
      expect(Configuration[:hello]).to be subject[:hello]
    end
  end

  describe "#initialize" do
    subject { Configuration.new(settings) }
    let(:settings) { { foo: "bar" }.freeze }
    let(:defaults) { { hello: "world", foo: "baz" }.freeze }
    before(:each) { Configuration.default_settings(defaults) }

    it "merges instance variables" do
      expect(subject[:hello]).to eq "world"
      expect(subject[:foo]).to eq "bar"
    end

    it "doesn't modify defaults" do
      subject[:hello] = "you"
      expect(defaults[:hello]).to eq "world"
    end
  end

  describe "#method_missing" do
    it "maps the correct methods" do
      subject[:hello] = "world"
      expect(subject.hello).to eq("world")
      expect(subject.hello).to be subject[:hello]

      subject.foo = "bar"
      expect(subject[:foo]).to eq("bar")
      expect(subject[:foo]).to be subject.foo
    end
  end
end
