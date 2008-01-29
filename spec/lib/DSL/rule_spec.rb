require File.dirname(__FILE__) + '/../../spec_helper'

def new_rule(*args)
  Schemr::DSL::Rule.new(*args)
end

describe Schemr::DSL::Rule, "default" do
  it "should be :one for multiplicity" do
    new_rule(:name).min.should == 1
    new_rule(:name).max.should == 1
  end
  
  it "should be an inline rule" do
    new_rule("name").should be_inline
  end
  
  it "should not be an abstract rule" do
    new_rule(:rule).should_not be_abstract
  end
  
  it "should not be an instance rule" do
    new_rule(:rule).should_not be_instance
  end
  
  it "should be nil for base_rule" do
    new_rule(:name => "test").base_rule.should be_nil
  end
  
  it "should not have any nested rules" do
    new_rule(:name).nested_rules.should be_empty
  end
  
  it "should be nil for the parent" do
    new_rule(:name).parent.should be_nil
  end
  
  it "should not be a reference rule" do
    new_rule(:name).should_not have_reference
  end
  
  it "should have a nil value" do
    new_rule(:name).value.should be_nil
  end
end

describe Schemr::DSL::Rule, "#initialize" do
  it "should use the first argument as the name" do
    new_rule("name").name.should == "name"
  end
  
  it "should format name as a string" do
    new_rule(:symbol_for_name).name.should == "symbol_for_name"
  end
  
  it "should use the name in the options hash" do
    new_rule(:name => :name_in_options).name.should == "name_in_options"
  end
  
  it "should have the name argument take presidence over the options hash" do
    new_rule(:name_from_args, :name => :name_from_options).name.should == "name_from_args"
  end
  
  it "should extract the multiplicity value from the options hash" do
    new_rule(:name, :multiplicity => :one_to_many).min.should == 1
    new_rule(:name, :multiplicity => :one_to_many).max.should == :many
  end
  
  it "should extract the @inline from the options hash" do
    new_rule(:name, :inline => false).should_not be_inline
  end
  
  it "should be an abstract rule if it is not an inline rule" do
    new_rule(:name, :inline => false).should be_abstract
    new_rule(:name, :inline => true).should_not be_abstract
  end
  
  it "should be an instance rule if it is inline and has a reference rule" do
    ref_rule = new_rule(:rule)
    new_rule(:rule, :reference_rule => ref_rule).should be_instance
  end
  
  it "should grab the @base_rule from the options hash" do
    parent = new_rule(:name => "parent")
    new_rule(:name => "child", :base_rule => parent).base_rule.should == parent
  end
  
  it "should grab the @parent from the options hash" do
    parent = new_rule(:name => "parent")
    new_rule(:name => "child", :parent => parent).parent.should == parent
  end
  
  it "should use the parent's << if the parent responds to <<" do
    parent = new_rule(:parent)
    child = new_rule(:child, :parent => parent)
    child.parent.should == parent
    parent.nested_rules.should include(child)
  end
  
  it "should grab the @reference_rule from the options hash" do
    declaration_rule = new_rule(:declaration)
    rule = new_rule(:rule, :reference_rule => declaration_rule)
    rule.should have_reference
    rule.reference_rule.should == declaration_rule
  end
  
  it "should set the name and value to the first two arguments" do
    rule = new_rule(:rule_name, "rule value")
    rule.name.should == "rule_name"
    rule.value.should == "rule value"
  end
  
  it "should grab the value from the options hash" do
    rule = new_rule(:name => "name", :value => "value")
    rule.value.should == "value"
  end
end

describe Schemr::DSL::Rule, "attributes" do
  it "should be inherited from the base_rule" do
    parent = new_rule(:name => "parent", :some_attribute => :some_value)
    new_rule(:name => "child", :base_rule => parent).some_attribute.should == :some_value
  end
  
  it "should handle unused options in the constructor's options hash as required attributes" do
    new_rule(:name => "test", :attr => "value").attributes.should == {:attr => "value"}
  end
  
  it "should respond to messages to an attribute name" do
    new_rule(:name => "test", :attrib => "value").attrib.should == "value"
  end
  
  it "should respond to messages to an optional attribute name" do
    rule = new_rule(:name => "test")
    rule.optional_attributes.merge!(:key => :value)
    rule.key.should == :value
  end
  
  it "should call the original method_missing if a message to a non existent attribute is recieved" do
    lambda { new_rule.some_non_existent_method_or_attribute }.should raise_error(NoMethodError)
  end
end

describe Schemr::DSL::Rule, "operators" do
  it "should alias [] to the nested rules" do
    parent_rule = new_rule(:name => "parent_rule")
    parent_rule << child_rule = new_rule(:name => "child_rule")
    parent_rule[0].should == parent_rule.nested_rules[0]
  end
  
  it "should alias << to the nested rules" do
    parent_rule = new_rule(:name => "parent_rule")
    parent_rule << child_rule = new_rule(:name => "child_rule")
    parent_rule.nested_rules.should be_include(child_rule)
  end
  
  it "should set the child's parent when <<'ing" do
    parent, child = new_rule("parent"), new_rule("child")
    lambda { parent << child }.should change{ child.parent }.to(parent)
  end
  
  #not working on the build server...
  #it "should raise error on a circular rule chain"# do
    #first, second, third = new_rule(:first), new_rule(:second), new_rule(:third)
    #first << second
    #second << third
    #lambda { third << first }.should raise_error
  #end
end

describe Schemr::DSL::Rule, "nested rules" do
  it "should not include base_rule's nested rules in the nested rules enumeration" do
    base_rule = new_rule(:name => "base_rule")
    base_rule << child_rule = new_rule(:name => "child")
    rule = new_rule(:name => "parent", :base_rule => base_rule)
    rule.nested_rules.should_not be_include(child_rule)
  end
  
  it "should access nested rules by name when the key is a string" do
    parent_rule = new_rule(:name => "parent_rule")
    parent_rule << child_rule = new_rule(:name => "child_rule")
    parent_rule["child_rule"].should == child_rule
  end
  
  it "should alias the << operator to the nested rules" do
    parent = new_rule
  end
end

describe Schemr::DSL::Rule, "multiplicity" do
  it "should translate :one_to_many as @min=1, @max=:many" do
    rule = new_rule(:name => "multiplitiy_test", :multiplicity => :one_to_many)
    rule.min.should == 1
    rule.max.should == :many
  end
  
  it "should translate :zero_to_many as @min=0, @max=:many" do
    rule = new_rule(:multiplicity_test, :multiplicity => :zero_to_many)
    rule.min.should == 0
    rule.max.should == :many
  end
  
  it "should translate :zero_to_one as @min=0, @max=1" do
    rule = new_rule(:multiplicity_test, :multiplicity => :zero_to_one)
    rule.min.should == 0
    rule.max.should == 1
  end
  
  it "should set @min/@max by a symbol" do
    rule = new_rule(:name)
    lambda { rule.multiplicity = :zero_to_one }.should change{rule.min}.to(0)
    lambda { rule.multiplicity = :zero_to_many }.should change{rule.max}.to(:many)
  end
  
  it "should set @min/@max by a range" do
    rule = new_rule(:name)
    lambda { rule.multiplicity = 3..30 }.should change{rule.min}.to(3)
    lambda { rule.multiplicity = 2...20 }.should change{rule.max}.to(19)
  end
  
  it "should set @min/@max to 1 if :multiplicity is not recognized" do
    rule = new_rule(:multiplicity_test, :multiplicity => Time.now)
    rule.min.should == 1
    rule.max.should == 1
  end
end

describe Schemr::DSL::Rule, "reference rule" do
  it "should be found in the rule chain if the reference rule is a symbol" do
    grand_parent = new_rule(:grand_parent)
    grand_parent << parent = new_rule(:parent)
    child = new_rule(:name, :reference_rule => :parent, :parent => parent)
    child.reference_rule.should == parent
  end
end

describe Schemr::DSL::Rule, "base rule" do
  it "should be found in the rule chain if the base rule is a symbol" do
    parent = new_rule(:parent)
    parent << non_inline = new_rule(:non_inline, :inline => false)
    child = new_rule(:name, :parent => parent)
    child.parent.should == parent
    lambda { child.base_rule = :non_inline}.should change{child.base_rule}.to(non_inline)
  end
  
  it "should include all nested rules in the rule chain that are base_ruleable in possible_base_rules" do
    parent, nested = new_rule(:parent), new_rule(:nested)
    parent << nested
    
    parent.possible_base_rules.include?(nested).should be_true
  end
  
  it "should include cousin rules when gathering possible base rules" do
    parent, nested, child = new_rule(:parent), new_rule(:nested), new_rule(:child)
    parent << nested
    parent << child
    
    child.possible_base_rules.include?(nested).should be_true
  end
  
  it "should not include cousin's nested rules when gathering possible base rules" do
    parent, cousin, nested, child = new_rule(:parent), new_rule(:cousin), new_rule(:nested), new_rule(:child)
    parent << cousin
    parent << child
    cousin << nested
    
    child.possible_base_rules.include?(nested).should be_false
  end
  
  it "should extract both the base_rule and parent in constructor" do
    parent, cousin = new_rule(:parent), new_rule(:cousin)
    parent << cousin
    
    child = new_rule(:child, :base_rule => :cousin, :parent => parent)
    child.base_rule.should == cousin
  end
end

describe Schemr::DSL::Rule, "rule chain" do
  it "should be the path to the root rule, starting with the child" do
    grand_parent = new_rule(:grand_parent)
    grand_parent << parent = new_rule(:parent)
    parent << child = new_rule(:child)
    
    child.rule_chain.should == [child, parent, grand_parent]
  end
end