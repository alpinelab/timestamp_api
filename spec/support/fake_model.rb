require "spec_helper"

def fake_model(name, base_model_class = nil, &block)
  fake_class = Class.new(base_model_class || TimestampAPI::Model)
  allow(fake_class).to receive(:name).and_return(name)
  TimestampAPI::ModelRegistry.register(fake_class)
  fake_class.class_eval(&block) unless block.nil?
  stub_const("::#{name}", fake_class)
end
