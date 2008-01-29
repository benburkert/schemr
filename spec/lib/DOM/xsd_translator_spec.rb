require File.dirname(__FILE__) + '/../../spec_helper'

describe Schemr::DOM::XsdTranslator, "#tree_and_root" do
  before(:each) do
    @rule_tree = Schemr::DSL::RuleTree.new(:xsd_test)
  end
  
  it "should create a root element with xs:schema identifier" do
    tree, root = tree_and_root
    root.identifier.should == "xs:schema"
  end
  
  it "should create root with a xmlns:xs attribute equal to 'http://www.w3.org/2001/XMLSchema'" do
    tree, root = tree_and_root
    root['xmlns:xs'].should == "http://www.w3.org/2001/XMLSchema"
  end
  
  it "should create root with a xmlns:xml attribute equal to 'http://www.w3.org/XML/1998/namespace'" do
    tree, root = tree_and_root
    root['xmlns:xml'].should == "http://www.w3.org/XML/1998/namespace"
  end
  
  it "should create root with a xs:import child element" do
    tree, root = tree_and_root
    root.children.first.identifier.should == "xs:import"
  end
  
  it "should the child xs:import element with a namespace attribute 'http://www.w3.org/XML/1998/namespace'" do
    tree, root = tree_and_root
    root.children.first["namespace"].should == "http://www.w3.org/XML/1998/namespace"
  end
  
  it "should the child xs:import element with a schemaLocation attribute 'http://www.w3.org/2001/xml.xsd'" do
    tree, root = tree_and_root
    root.children.first["schemaLocation"].should == "http://www.w3.org/2001/xml.xsd"
  end
  
  it "should be the same element" do
    tree, root = tree_and_root
    tree.should == root
  end
end

describe Schemr::DOM::XsdTranslator, "#translate_rule" do
  
  def new_rule(*args)
    Schemr::DSL::Rule.new(*args)
  end
  
  it "should translate a rule with no children, attributes, or value to an xs:element" do
    rule = new_rule(:name)
    element = translate_rule(rule)
    element.identifier.should == "xs:element"
  end
  
  it "should set the name attribute of a rule with no children, attributes, or value" do
    rule = new_rule(:name)
    element = translate_rule(rule)
    element["name"].should == "name"
  end
  
  it "should set the type attribute of a rule with no children, attributes, or value as xs:string" do
    rule = new_rule(:name)
    element = translate_rule(rule)
    element["type"].should == "xs:string"
  end
  
  it "should add a xs:complexType element if there are any attributes or nested rules" do
    rule = new_rule(:name, :some_attribute => nil)
    element = translate_rule(rule)
    element.children.first.identifier.should == "xs:complexType"
  end
  
  it "should add attributes of the rule as child elements" do
    rule = new_rule(:name, :some_attribute => nil)
    element = translate_rule(rule)
    element.children.first.children.first.identifier.should == "xs:attribute"
    element.children.first.children.first.name.should == "some_attribute"
  end
  
  it "should add a xs:sequence to the xs:complexType element if the rule has nested rules" do
    rule = new_rule(:parent)
    rule << new_rule(:child)
    element = translate_rule(rule)
    element.children.first.children.first.identifier.should == "xs:sequence"
  end
  
  it "should add any nested rules to the xs:sequence element" do
    rule = new_rule(:parent)
    rule << new_rule(:child)
    element = translate_rule(rule)
    element.children.first.children.first.children.first.identifier.should == "xs:element"
    element.children.first.children.first.children.first.name.should == "child"
  end
end

describe Schemr::DOM::XsdTranslator, "translating reference rules" do
  
  def new_rule(*args)
    Schemr::DSL::Rule.new(*args)
  end
  
  it "should add any nested referenced rules to the xs:sequence element as reference elements" do
    rule = new_rule(:parent)
    rule << new_rule(:child, :reference_rule => new_rule(:child))
    element = translate_rule(rule)
    element.children.first.children.first.children.first.identifier.should == "xs:element"
    element.children.first.children.first.children.first.ref.should == "tns:child"
  end
  
  it "should add a one to one referenced rule to the xs:sequence with a minimum occurrence of 1" do
    rule = new_rule(:parent)
    rule << new_rule(:child, :reference_rule => new_rule(:child))
    element = translate_rule(rule)
    element.children.first.children.first.children.first.identifier.should == "xs:element"
    element.children.first.children.first.children.first.minOccurs.should == "1"
  end
  
  it "should add a zero to one referenced rule to the xs:sequence with a minimum occurrence of 0" do
    rule = new_rule(:parent)
    rule << new_rule(:child, :reference_rule => new_rule(:child), :multiplicity => :zero_to_one)
    element = translate_rule(rule)
    element.children.first.children.first.children.first.identifier.should == "xs:element"
    element.children.first.children.first.children.first.minOccurs.should == "0"
  end
  
  it "should add a zero to one referenced rule to the xs:sequence with a maximum occurence of 1" do
    rule = new_rule(:parent)
    rule << new_rule(:child, :reference_rule => new_rule(:child), :multiplicity => :zero_to_one)
    element = translate_rule(rule)
    element.children.first.children.first.children.first.identifier.should == "xs:element"
    element.children.first.children.first.children.first.maxOccurs.should == "1"
  end
  
  it "should add a one to many referenced rule to the xs:sequence with a maximum occurence of 'unbounded'" do
    rule = new_rule(:parent)
    rule << new_rule(:child, :reference_rule => new_rule(:child), :multiplicity => :zero_to_many)
    element = translate_rule(rule)
    element.children.first.children.first.children.first.identifier.should == "xs:element"
    element.children.first.children.first.children.first.maxOccurs.should == "unbounded"
  end
end

describe Schemr::DOM::XsdTranslator, "#translate_attributes" do
  
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
  
  it "should return xs:attribute elements" do
    rule = new_rule(:name, :some_attribute => nil)
    attributes = translate_attributes(rule)
    attributes.first.identifier.should == "xs:attribute"
  end
  
  it "should set the type of valueless attributes to xs:string" do
    rule = new_rule(:name, :some_attribute => nil)
    attributes = translate_attributes(rule)
    attributes.first["type"].should == "xs:string"
  end
end