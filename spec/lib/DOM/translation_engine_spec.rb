require File.dirname(__FILE__) + '/../../spec_helper'

describe Schemr::DOM::TranslationEngine, "translator mapping" do
  it "should include the dtd translator" do
    Schemr::DOM::TranslationEngine::TRANSLATOR_MAP.values.should include(Schemr::DOM::DtdTranslator)
  end
  
  it "should map :dtd to DtdTranslator" do
    Schemr::DOM::TranslationEngine::TRANSLATOR_MAP[:dtd].should == Schemr::DOM::DtdTranslator
  end
end

describe Schemr::DOM::TranslationEngine, "#initialize" do
  it "should lookup the translator and extend itself if the first argument is a key in the translator map" do
    Schemr::DOM::TranslationEngine.new(:dtd).should be_is_a(Schemr::DOM::DtdTranslator)
  end
end

describe Schemr::DOM::TranslationEngine, "#translate" do
  it "should produce a element tree from a rule tree" do
    template = <<-EOF
!!! :dtd_example
EOF
    rule_tree = Schemr::DSL::ParseEngine.new(template).parse
    element_tree = Schemr::DOM::TranslationEngine.new(:dtd).translate(rule_tree)
    element_tree.should be_instance_of(Schemr::DOM::ElementTree)
  end
end