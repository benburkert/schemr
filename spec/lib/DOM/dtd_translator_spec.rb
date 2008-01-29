require File.dirname(__FILE__) + '/../../spec_helper'

describe Schemr::DOM::DtdTranslator, "#tree_and_root" do
  before(:each) do
    @rule_tree = Schemr::DSL::RuleTree.new(:dtd_test)
  end
  
  it "should be the same element" do
    tree, root = tree_and_root
    tree.should == root
  end
  
  it "should return an ElementTree for tree" do
    tree, root = tree_and_root
    tree.should be_instance_of(Schemr::DOM::ElementTree)
  end
  
  it "should return an Element for root" do
    tree, root = tree_and_root
    root.is_a?(Schemr::DOM::Element).should be_true
  end
  
  it "should have a DOCTYPE element as the root" do
    tree, root = tree_and_root
    root.identifier.should == "DOCTYPE"
  end
  
  it "should have an 'root-element' attribute for the tree's name" do
    tree, root = tree_and_root
    root['root-element'].should == "dtd_test"
  end
end

describe Schemr::DOM::DtdTranslator, "#translate_attributes" do
  def new_rule(*args)
    Schemr::DSL::Rule.new(*args)
  end
  
  before(:each) do
    @rule_tree = Schemr::DSL::RuleTree.new(:dtd_test)
    @tree, @root = tree_and_root
  end
  
  it "should return an empty array if a rule has no atttributes" do
    translate_attributes(new_rule(:name)).should be_empty
  end
  
  it "should return ATTLIST elements" do
    rule = new_rule(:name, :some_attribute => nil)
    attributes = translate_attributes(rule)
    attributes.first.identifier.should == "ATTLIST"
  end
  
  it "should return elements with an attribute 'attribute-name' equal to the attribute name" do
    rule = new_rule(:name, :some_attribute => nil)
    attributes = translate_attributes(rule)
    attributes.first.attributes["attribute-name"].should == "some_attribute"
  end
  
  it "should return elements with an attribute 'element-name' equal to the rule name" do
    attributes = translate_attributes(new_rule(:name, :some_attribute => nil))
    attributes.first.attributes["element-name"].should == "name"
  end
  
  it "should set the element's 'default-value' attribute to '#REQUIRED' if the attribute is not optional and a value is not given" do
    attributes = translate_attributes(new_rule(:name, :some_attribute => nil))
    attributes.first.attributes["default-value"].should == "#REQUIRED"
  end
  
  it "should set the element's 'default-value' attribute to '#FIXED ' followed by the value in quotes if the attribute is not optional and a value is given" do
    attributes = translate_attributes(new_rule(:name, :some_attribute => "abc"))
    attributes.first.attributes["default-value"].should == '#FIXED "abc"'
  end
  
  it "should set the element's 'default-value' to '#IMPLIED' if the attribute is optional and the value is not given" do
    rule = new_rule(:name)
    rule.optional_attributes[:some_optional_attribute] = nil
    attributes = translate_attributes(rule)
    attributes.first.attributes["default-value"].should == "#IMPLIED"
  end
  
  it "should set the element's 'default-value' to :value in quotes if the attribute is optional and a value is given" do
    rule = new_rule(:name)
    rule.optional_attributes[:some_optional_attribute] = "def"
    attributes = translate_attributes(rule)
    attributes.first.attributes["default-value"].should == '"def"'
  end
  
  it "should set the element's 'attribute-type' to 'CDATA' if the attribute value is not given" do
    attributes = translate_attributes(new_rule(:name, :some_attribute => nil))
    attributes.first.attributes["attribute-type"].should == 'CDATA'
  end
  
  it "should set the element's 'attribute-type' to 'CDATA' if the attribute value is a string" do
    attributes = translate_attributes(new_rule(:name, :some_attribute => "abcd"))
    attributes.first.attributes["attribute-type"].should == "CDATA"
  end
  
  it "should description" do
    
  end
end

describe Schemr::DOM::DtdTranslator do
  def new_rule(*args)
    Schemr::DSL::Rule.new(*args)
  end
  
  before(:each) do
    @rule_tree = Schemr::DSL::RuleTree.new(:dtd_test)
    @tree, @root = tree_and_root
  end
  
  it "should translate an empty rule tree to an empty element tree" do
    translate_nested_rules
    @tree.children.should be_empty
  end
  
  it "should translate a single rule into a ELEMENT" do
    @rule_tree << new_rule(:name)
    lambda { translate_nested_rules }.should change{@tree.children.length}.by(1)
    @tree.children.first.identifier.should == "ELEMENT"
  end
end
  
describe Schemr::DOM::DtdTranslator, "#translate_rule" do
  
  def new_rule(*args)
    Schemr::DSL::Rule.new(*args)
  end
  
  it "should translate a rule with no children and no value to an element with category (#PCDATA)" do
    rule = new_rule(:name)
    element = translate_rule(rule)
    element.category.should == "(#PCDATA)"
  end
  
  it "should translate a rule with a string value to an element with category (#PCDATA)" do
    rule = new_rule(:name, "value")
    element = translate_rule(rule)
    element.category.should == "(#PCDATA)"
  end
  
  it "should have nil for the attribute 'category' if the rule has nested rules" do
    rule = new_rule(:parent)
    rule << new_rule(:child)
    translate_rule(rule).category.should == ""
  end
  
  it "should set the value of 'element-content' to a list of the nested rule name in parenthesis if the rule has one nested rules" do
    rule = new_rule(:parent)
    rule << new_rule(:child)
    element = translate_rule(rule)
    element["element-content"].should == "(child)"
  end
  
  it "should set the value of 'element-content' to nil if there are no nested rules" do
    new_rule(:name)["element-content"].should == nil
  end
  
  it "should set the value of 'element-content' to a list of the nested rule names in parenthesis, seperated by commas if the rule has multiple nested rules" do
    rule = new_rule(:parent)
    rule << new_rule(:first)
    rule << new_rule(:second)
    rule << new_rule(:third)
    element = translate_rule(rule)
    element["element-content"].should == "(third,second,first)"
  end
  
  it "should set the value of 'element-content' to the nested rule name followed by + if the nested rule has a multiplicity of :one_to_many" do
    rule = new_rule(:parent)
    rule << new_rule(:child, :multiplicity => :one_to_many)
    element = translate_rule(rule)
    element["element-content"].should == "(child+)"
  end
  
  it "should set the value of 'element-content' to the nested rule name followed by * if the nested rule has a multiplicity of :zero_to_many" do
    rule = new_rule(:parent)
    rule << new_rule(:child, :multiplicity => :zero_to_many)
    element = translate_rule(rule)
    element["element-content"].should == "(child*)"
  end
  
  it "should set the value of 'element-content' to the nested rule name followed by ? if the nested rule has a multiplicity of :zero_to_one" do
    rule = new_rule(:parent)
    rule << new_rule(:child, :multiplicity => :zero_to_one)
    element = translate_rule(rule)
    element["element-content"].should == "(child?)"
  end
  
  it "should set the value of 'element-content' to a list of the nested rule names with a symbol in parenthesis, seperated by commas if the rule has multiple nested rules with a multiplicity value" do
    rule = new_rule(:parent)
    rule << new_rule(:first, :multiplicity => :zero_to_one)
    rule << new_rule(:second, :multiplicity => :one_to_many)
    rule << new_rule(:third)
    rule << new_rule(:fourth, :multiplicity => :zero_to_many)
    element = translate_rule(rule)
    element["element-content"].should == "(third,second+,first?,fourth*)"
  end
  
  it "should set the value of 'element-category' to EMPTY if the rule has attributes but no value" do
    rule = new_rule(:parent)
    rule.attributes[:attr] = :value
    translate_rule(rule).category.should == "EMPTY"
  end
end

describe Schemr::DOM::DtdTranslator, "Examples" do
  
  def parse(template)
    Schemr::DSL::ParseEngine.new(template).parse
  end
  
  def translate(rule_tree)
    @tree, @root = tree_and_root(rule_tree)
    translate_nested_rules(rule_tree)
  end
  
  it "should translate a template without any rules as an empty element tree with identifier DOCTYPE and a nil attribute for the name" do
    template = <<-EOF
!!! :dtd_example
EOF
    rule_tree = parse(template)
    translate(rule_tree)
    
    @tree.children.should be_empty
    @tree.identifier.should == "DOCTYPE"
    @tree['root-element'].should == "dtd_example"
  end
  
  it "should translate a basic rule without as an ELEMENT element with attribute 'element-name' as the rule name " do
    template = <<-EOF
!!! :dtd_example
  < :single_rule
EOF
    rule_tree = parse(template)
    translate(rule_tree)
    
    @tree.children.first.identifier.should == "ELEMENT"
    @tree.children.first["element-name"].should == "single_rule"
  end
  
  it "should translate two rules into two elements" do
    template = <<-EOF
!!! :dtd_example
  < :first
  < :second
EOF
    rule_tree = parse(template)
    translate(rule_tree)
    
    @tree.children.first["element-name"].should == "first"
    @tree.children.second["element-name"].should == "second"
  end
  
  it "should translate a root rule and one nested rule" do
    template = <<-EOF
!!! :dtd_example
  < :parent
    < :child
EOF
    rule_tree = parse(template)
    translate(rule_tree)
    parent, child = @tree.children.first, @tree.children.second
    
    parent["element-name"].should == "parent"
    parent["element-content"].should == "(child)"
    child["element-name"].should == "child"
    child["category"].should == "(#PCDATA)"
  end
  
  it "should translate multi-level nested rules" do
    template = <<-EOF
!!! :dtd_example
  < :grandparent
    < :parent
      < :child
EOF
    rule_tree = parse(template)
    translate(rule_tree)
    grandparent, parent, child = @tree.children[0..2]
    
    grandparent["element-name"].should == "grandparent"
    grandparent["element-content"].should == "(parent)"
    parent["element-name"].should == "parent"
    parent["element-content"].should == "(child)"
    child["element-name"].should == "child"
    child["category"].should == "(#PCDATA)"
  end
  
  it "should translate multiple nested rules with different multiplicities" do
    template = <<-EOF
!!! :dtd_example
  < :parent
    <+ :one_to_many
    <* :zero_to_many
    <  :one
    <? :zero_to_one
EOF
    rule_tree = parse(template)
    translate(rule_tree)
    parent, one_to_many, zero_to_many, one, zero_to_one = @tree.children[0..4]
    
    parent["element-content"].should == "(zero_to_one?,zero_to_many*,one,one_to_many+)"
  end
  
  it "should translate attributes to ATTLIST elements" do
    template = <<-EOF
!!! :dtd_example
  < :rule
    ^ :attribute
EOF
    
    rule_tree = parse(template)
    translate(rule_tree)
    attribute = @tree.children.second
    attribute.identifier.should == "ATTLIST"
    attribute["element-name"].should == "rule"
    attribute["attribute-name"].should == "attribute"
    attribute["attribute-type"].should == "CDATA"
    attribute["default-value"].should == "#REQUIRED"
  end
  
  it "should translate optional attributes to ATTLIST elements" do
    template = <<-EOF
!!! :dtd_example
  < :rule
    ^? :optional_attribute
    EOF
    
    rule_tree = parse(template)
    translate(rule_tree)
    attribute = @tree.children.second
    attribute.identifier.should == "ATTLIST"
    attribute["element-name"].should == "rule"
    attribute["attribute-name"].should == "optional_attribute"
    attribute["attribute-type"].should == "CDATA"
    attribute["default-value"].should == "#IMPLIED"
  end
    
  it "should not translate instance rules" do
    template = <<-EOF
!!! :dtd_example
  !! :first
  
  < :rule
    # :first
    EOF
    rule_tree = parse(template)
    translate(rule_tree)
    @tree.children.find_all {|element| element["element-name"] == "first" && element.identifier == "ELEMENT"}.length.should == 1 
  end
  
  it "should translate repetitive rules" do
    rule_tree = parse <<-EOF
!!! :dtd_example
  < :pathA
    < :common
      < :childA
  < :pathB
    < :common
      < :childB
EOF
    translate(rule_tree)
    common = @tree.children.find {|c| c.identifier == "ELEMENT" && c["element-name"] == "common"}
    common["element-content"].should == "(childA)|(childB)"
  end
  
  it "should ignore repetitive rules that are duplicates" do
    rule_tree = parse <<-EOF
!!! :dtd_example
  < :pathA
    < :common
      < :child
  < :pathB
    < :common
      < :child
EOF
    translate(rule_tree)
    common = @tree.children.find {|c| c.identifier == "ELEMENT" && c["element-name"] == "common"}
    common["element-content"].should == "(child)"
  end
  
  it "should ignore repetitive rules that are duplicates and empty" do
    rule_tree = parse <<-EOF
!!! :dtd_example 
  < :pathA
    < :common
  < :pathB
    < :common
EOF
    translate(rule_tree)
    common = @tree.children.find {|c| c.identifier == "ELEMENT" && c["element-name"] == "common"}
    common["element-content"].should be_empty
  end
  
  it "should not add an OR symbol to the end of the element-content" do
    rule_tree = parse <<-EOF
!!! :wadl
  !! :doc
    ^ :title
  !! :option
    # :doc
  !! :param
    #* :doc
    #* :option

  
EOF
    translate(rule_tree)
    @tree.children.any? {|c| c["element-content"] == "(doc)|"}.should be_false
  end
end