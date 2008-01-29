require File.dirname(__FILE__) + '/../../spec_helper'

describe Schemr::DSL::InlineInterpreter do
  it "should eval a line that contains a string" do
    line_eval("\"eval this string\"").should == "eval this string"
  end
  
  it "should eval a line that is valid" do
    line_eval("1 + 2").should == 3
    line_eval("{:some => :hash}").should == {:some => :hash}
  end
  
  it "should raise parser errors when evaluating an invalid line" do
    lambda { line_eval("{:unclosed => :brace") }.should raise_error
  end
end

describe Schemr::DSL::InlineInterpreter, "Argument evaluation" do
  it "should evaluate an argument into an array" do
    args_eval("1 + 2").first.should == 3
  end
  
  it "should evaluate arguments seperated by commas" do
    args_eval("\"abc\", :def")[0..1].should == ["abc", :def]
  end
  
  it "should evaluate multiple arguments seperated by commas" do
    args_eval("\"abc\", \"def\", 1 + 2, nil?")[0..3].should == ["abc", "def", 1 + 2, false]
  end
  
  it "should evaluate hash arguments" do
    args_eval(":arg, :abc => :def").last[:abc] == :def
  end
  
  it "should evalutate arguments with a bracketless hash" do
    args_eval("\"abc\", :abc => :def, :ghi => :jkl").last[:abc].should == :def
    args_eval("\"abc\", :abc => :def, :ghi => :jkl").last[:ghi].should == :jkl
  end
  
  it "should match valid rule lines" do
    multiplicity_symbol("<  :one").should == "<"
    multiplicity_symbol("<* :zero_to_many").should == "<*"
    multiplicity_symbol("<+ :one_to_many").should == "<+"
    multiplicity_symbol("<? :zer0_to_many").should == "<?"
    multiplicity_symbol(">  :bad").should be_nil
  end
  
  it "should extract the multiplicity symbols as option" do
    args_eval("                < :name").first.should == :name
    args_eval("        <? :one_or_none").first.should == :one_or_none
    args_eval("<* :as_many_as_you_want").first.should == :as_many_as_you_want
    args_eval("        <+ :one_or_more").first.should == :one_or_more
  end
  
  it "should extract the base_rule symbol as an option" do
    args_eval("<  :child << :parent").last[:base_rule].should == :parent
    args_eval("<? :child << \"parent\"").last[:base_rule].should == "parent"
    args_eval("<* :child << :grandparent.to_s").last[:base_rule].should == "grandparent"
  end
  
  it "should find the base rule symbol after the <<" do
    base_rule_symbol("< :child << :parent").should == ":parent"
    base_rule_symbol("  <* :son << \"father\"").should == "\"father\""
    base_rule_symbol("    <? :child << :parent << :grandparent").should == ":grandparent"
  end
  
  it "should take an optional parent argument" do
    lambda { args_eval("  < :abc", :parent) }.should_not raise_error
  end
  
  it "should pass the parent argument to the options hash" do
    parent = "parent"
    args_eval("< :one_to_many", parent).last[:parent].should == "parent"
    args_eval("< :one_to_many", "parent").last[:parent].should == "parent"
  end
  
  it "should extract the declaration symbol as the inline option" do
    args_eval("!! :non_inline").last[:inline].should be_false
  end
  
  it "should not override the inline option with the declaration symbol" do
    args_eval("!! :inline, :inline => true").last[:inline].should be_true
  end
  
  it "should extract the reference rule as an option" do
    args_eval("# :rule").first.should == :rule
    args_eval("# :rule").last[:reference_rule].should be_true
  end
  
  it "should not extract the reference rule option if it does not start with a #" do
    args_eval("< :inline").last.should_not include(:reference)
  end
  
  it "should extract the reference rule and multiplicity as options" do
    args_eval("#? :rule").last[:multiplicity].should == :zero_to_one
    args_eval("  #+ :rule").last[:multiplicity].should == :one_to_many
    args_eval("    #* :rule").last[:multiplicity].should == :zero_to_many
  end
  
  it "should extract the rule and value" do
    args_eval("< :rule => :value").first.should == :rule
    args_eval("< :rule => :value").second.should == :value
  end
  
  it "should extract the rule and value of optional rules" do
    args_eval("<? :rule => :value").first.should == :rule
    args_eval("<? :rule => :value").second.should == :value
  end
  
  it "should extract the rule and value when the value is an array" do
    args_eval("<? :rule => [:first, :second, :third]").first.should == :rule
    args_eval("<? :rule => [:first, :second, :third]").second.should == [:first, :second, :third]
  end
  
  it "should extract the rule and value for an optional rule" do
    args_eval("<? :type => [:work, :home, :pref, :postal, :dom, :intl]").second.should == [:work, :home, :pref, :postal, :dom, :intl]
  end
  
  it "should extract the rule and array arguments" do
    args_eval("< :name, [:array, :of, :values], [:third]").first.should == :name
    args_eval("< :name, [:array, :of, :values], [:third]").second.should == [:array, :of, :values]
    args_eval("< :name, [:array, :of, :values], [:third]")[2].should == [:third]
  end
end

describe Schemr::DSL::InlineInterpreter, "Attribute evaluation" do
  
  it "should match extract a hash for attribute lines" do
    args_eval("^ :attrib => :value").should == [:attrib, :value]
  end
  
  it "should extract a hash with a nil value for an attribute without a value" do
    args_eval("^ :attribute").should == [:attribute]
  end
  
  it "should act the same for optional attributes" do
    args_eval("^? :attrib => :value").should == args_eval("^ :attrib => :value")
  end
end