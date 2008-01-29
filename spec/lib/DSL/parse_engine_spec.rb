require File.dirname(__FILE__) + '/../../spec_helper'

describe Schemr::DSL::ParseEngine do
  
  def new_engine(template)
    Schemr::DSL::ParseEngine.new(template)
  end
  
  def parse(template)
    new_engine(template).parse
  end
  
  it "parse should return nil for an empty string" do
    parse('').should be_nil
  end
  
  it "parse should return nil if the template does not start with !!!" do
    parse('Hello, World!').should be_nil
  end
  
  it "should interpret lines that are not rules or attributes" do
    doc = parse("!!! :test \n  @test_attribute = 'test value'")
    doc.instance_variables.any? {|val| val == "@test_attribute"}.should be_true
  end
  
  it "should parse a document with only the declaration tag" do
    parse('!!! :test').class.should == Schemr::DSL::RuleTree
  end
  
  it "should parse the argument as the name in the declaration tag" do
    parse('!!! :test').name.should == "test"
  end
  
  it "should parse the declarator and a rule tag without errors" do
    lambda { parse("!!! :test \n  < :rule1")}.should_not raise_error
  end
  
  it "should parse a doc with a single rule" do
    doc = parse("!!! :test \n  < :rule1")
    doc.name.should == "test"
    
    doc[:rule1].should_not be_nil
  end
  
  it "should parse a doc with two rules" do
    doc = parse("!!! :test \n  < :rule1\n  < :rule2")
    doc.name.should == "test"
    doc.nested_rules.length.should == 2
    doc[:rule1].should_not be_nil
    doc[:rule2].should_not be_nil
  end
  
  it "should parse a doc with two rules with the same name" do
    doc = parse("!!! :test \n  < :sub_rule\n  < :sub_rule")
    doc.nested_rules.length.should == 2
    doc[0].name.should_not be_nil
    doc[0].name.should == doc[1].name
  end
  
  it "should parse a doc with sub_rules with sub_rules" do
    doc = parse("!!! :test \n  < :parent_sub_rule\n    < :child_sub_rule")
    doc.nested_rules.length.should == 1
    doc[:parent_sub_rule].nested_rules.length.should == 1
    doc[:parent_sub_rule][:child_sub_rule].should_not be_nil
  end
  
  it "should parse a doc with two rules, one with sub_rules" do
    doc = parse("!!! :test \n  < :parent_sub_rule\n    < :child_sub_rule\n  < :sub_rule")
    doc.nested_rules.length.should == 2
    doc[:parent_sub_rule].nested_rules.length.should == 1
    doc[:parent_sub_rule][:child_sub_rule].should_not be_nil
    doc[:sub_rule].should_not be_nil
  end
  
  it "should ignore a blank line" do
    doc = parse("!!! :test\n\n  < :rule")
    doc.nested_rules.length.should == 1
    doc[:rule].should_not be_nil
  end
  
  it "should ignore multiple blank lines" do
    doc = parse("!!! :test\n\n\n\n  < :rule\n\n\n\n\n\n\n\n    < :sub_rule")
    doc.nested_rules.length.should == 1
    doc[:rule].nested_rules.length.should == 1
    doc[:rule][:sub_rule].should_not be_nil
  end
  
  it "should ignore lines with only spaces" do
    doc = parse("!!! :test\n\n      \n  \n  < :rule\n\n    \n    < :sub_rule")
    doc.nested_rules.length.should == 1
    doc[:rule].nested_rules.length.should == 1
    doc[:rule][:sub_rule].should_not be_nil
  end
  
  it "should treat uqualified rule declerations as a :one multiplicity" do
    doc = parse("!!! :test \n  < :rule1")
    doc[:rule1].min.should == 1
    doc[:rule1].max.should == 1
  end
  
  it "should not override the multiplicity argument" do
    doc = parse("!!! :test\n  < :rule, :multiplicity => :one_to_many")
    doc[:rule].max.should == :many
  end
  
  it "args_eval should wrap a single argument in braces" do
    new_engine("!!! :test").args_eval(":rule").should == [:rule]
  end
  
  it "args_eval should wrap multiple arguments in braces" do
    new_engine("!!! :test").args_eval(":bunch, :of, :arguments").should == [:bunch, :of, :arguments]
  end
  
  it "args_eval should wrap hash arguments in curly's" do
    new_engine("!!! :test").args_eval(":first_arg, :abc => :def").last.should == {:abc => :def}
  end
  
  it "args_eval should wrap multiple hash arguments in curly's" do
    new_engine("!!! :test").args_eval(":first_arg, :abc => :def, :hij => 123, :xyz => \"456\"").last.should == {:abc => :def, :hij => 123, :xyz => "456"}
  end
  
  it "args_eval should accept regular and hash arguments" do
    new_engine("!!! :test").args_eval(":abc, 123, :def => 456, :xyz => \"xyz\"").should == [:abc, 123, {:def => 456, :xyz => "xyz"}]
  end
  
  it "should parse a rule with a zero_to_many multiplicity" do
    doc = parse("!!! :test\n  <* :zero_to_many_rule")
    doc[:zero_to_many_rule].min.should == 0
    doc[:zero_to_many_rule].max.should == :many
  end
  
  it "should parse a rule with a one_to_many multiplicity" do
    doc = parse("!!! :test\n  <+ :one_to_many_rule")
    doc[:one_to_many_rule].min.should == 1
    doc[:one_to_many_rule].max.should == :many
  end
  
  it "should parse a rule with a zero_to_one multiplicity" do
    doc = parse("!!! :test\n  <? :zero_to_one_rule")
    doc[:zero_to_one_rule].min.should == 0
    doc[:zero_to_one_rule].max.should == 1
  end
  
  it "should parse a document with multiple rules with different multiplicity" do
    doc = parse("!!! :test\n  <? :zero_to_one\n    <* :zero_to_many\n      < :one\n  <+ :one_to_many")
    doc[:zero_to_one].min = 0
    doc[:zero_to_one].max = 1
    doc[:zero_to_one][:zero_to_many].min = 0
    doc[:zero_to_one][:zero_to_many].max = :many
    doc[:zero_to_one][:zero_to_many][:one].min = 1
    doc[:zero_to_one][:zero_to_many][:one].max = 1
    doc[:one_to_many].min = 1
    doc[:one_to_many].max = :many
  end
  
  it "should parse a rule with attributes" do
    doc = parse("!!! :test\n < :rule\n    ^ :attribute => \"test attribute\"")
    doc[:rule].attributes[:attribute].should == "test attribute"
  end
  
  it "parse_attribute_key should parse the key out of an attribute line" do
    new_engine("!!! :test").parse_attribute_key("^ :key => :value").should == :key
    new_engine("!!! :test").parse_attribute_key("^ \"key\" => \"value\"").should == "key"
  end
  
  it "parse_attribute_value should parse the value out of an attribute line" do
    new_engine("!!! :test").parse_attribute_value("^ :key => :value").should == :value
    new_engine("!!! :test").parse_attribute_value("^ \"key\" => \"value\"").should == "value"
  end
  
  it "should parse a rule with multiple attributes" do
    doc = parse("!!! :test\n  < :rule\n    ^ :first => 1\n    ^ :second => /.*/")
    doc[:rule].first.should == 1
    doc[:rule].second.should == /.*/
  end
  
  it "should parse an optional attribute" do
    doc = parse("!!! :test\n  < :rule\n    ^? :key => :value")
    doc[:rule].optional_attributes[:key].should == :value
  end
  
  it "should parse non inline rules" do
    doc = parse("!!! :test\n  !! :rule\n")
    doc[:rule].should_not be_inline
    doc[:rule].name.should == "rule"
  end
  
  it "should parse nested rule declarations" do
    doc = parse("!!! :test\n  < :rule\n    !! :non_inline")
    doc[:rule][:non_inline].should_not be_inline
    doc[:rule][:non_inline].name.should == "non_inline"
  end
  
  it "should parse attributes for rule declarations" do
    doc = parse("!!! :test\n !! :non_inline\n    ^ :key => :value")
    doc[:non_inline].key.should == :value
  end
  
  it "should parse multiple rule declarations and inline rules" do
    doc = parse <<-EOF
!!! :test
  !! :rule1
    ^ :mask => /abc/
    !! :rule1A, :default => "zero"
      ^ :mask => /def/
  <? :rule2, :default => (1 + 2)
    < :rule1A
    <* :rule2B, :default => :many
    EOF
    
    doc[:rule1].should_not be_inline
    doc[:rule1].mask.should == /abc/
    doc[:rule1][:rule1A].should_not be_inline
    doc[:rule1][:rule1A].default.should == "zero"
    doc[:rule2].name.should == "rule2"
    doc[:rule2].should be_inline
    doc[:rule2][:rule1A].should be_inline
    doc[:rule2][:rule2B].should be_inline
    doc[:rule2][:rule2B].default.should == :many
    doc[:rule2].default.should == 3
  end
  
  it "should parse the base rule after a << on the line" do
    doc = parse <<-EOF
!!! :test
  !! :parent
  < :child << :parent
EOF
    doc[:child].base_rule.should == doc[:parent]
  end
  
  it "should parse referenced rules" do
    doc = parse <<-EOF
!!! :test
  !! :declared
    ^ :attribute
  <? :inline, :default => "abc"
    # :declared
EOF
    
    doc[:declared].should_not be_inline
    doc[:inline].should be_inline
    doc[:inline][:declared].should be_inline
  end
  
  it "should parse abstract rules" do
    doc = parse <<-EOF
!!! :test
  !! :abstract
EOF
    
    doc[:abstract].should be_abstract
  end
  
  it "should parse a child rules with a value" do
    doc = parse <<-EOF
!!! :test
  <* :adr
    <? :type => [:work, :home, :pref, :postal, :dom, :intl]
EOF
    doc[:adr].nested_rules.length.should == 1
    doc[:adr][:type].value.should == [:work, :home, :pref, :postal, :dom, :intl]
  end
end