require File.dirname(__FILE__) + '/../../spec_helper'

describe Schemr::DtdRenderer, "#render" do
  def new_element_tree(*args)
    Schemr::DOM::ElementTree.new(*args)
  end
  
  def new_element(*args)
    Schemr::DOM::Element.new(*args)
  end
  
  def ELEMENT(name, content = nil, category = nil)
    Schemr::DOM::Element.new("ELEMENT",
      {
        "element-name" => name,
        "element-content" => content,
        "category" => category
      })
  end
  
  def ATTLIST(element_name, attribute_name, type, value)
    Schemr::DOM::Element.new("ATTLIST",
      {
        "element-name" => element_name,
        "attribute-name" => attribute_name,
        "attribute-type" => type,
        "default-value" => value
      })
  end
  
  before(:each) do
    @root = new_element_tree("DOCTYPE")
    @root["test"]
    @out = ""
    @endl = "\n"
  end
  
  it "should raise an error if the root element is not a DOCTYPE" do
    element_tree = new_element_tree "element_identifier"
    lambda { render(element_tree, @out) }.should raise_error("The root element must be DOCTYPE")
  end
  
  it "should raise an error if the DOCTYPE element does not have one attribute for the name" do
    @root.attributes = Hash.new
    lambda { render(@root, @out) }.should raise_error("DOCTYPE does not have a name")
  end
  
  it "should raise an error if the output destination does not respond to <<" do
    @out = nil
    lambda { render(@root, @out) }.should raise_error("Output destination does not respond to <")
  end
  
  #it "should wrap the output in the DOCTYPE element" do
  #  render(@root, @out)
  #  @out.should == "<!DOCTYPE test [\n\n\n]>"
  #end
  
  it "should ignore any elements that are not ATTLIST's or ELEMENT's" do
    @root << new_element("random_element")
    render(@root, @out)
    @out.strip.should be_empty
  end
  
  it "should be able to render EMPTY elements" do
    @root << ELEMENT("test_element", nil, "EMPTY")
    render(@root, @out)
    @out["<!ELEMENT test_element EMPTY>"].should_not be_nil
  end
  
  it "should be able to render ANY elements" do
    @root << ELEMENT("test_element", nil, "ANY")
    render(@root, @out)
    @out["<!ELEMENT test_element ANY>"].should_not be_nil
  end
  
  it "should be able to render PCDATA elements" do
    @root << ELEMENT("test_element", nil, "(#PCDATA)")
    render(@root, @out)
    @out["<!ELEMENT test_element (#PCDATA)>"].should_not be_nil
  end
  
  it "should render elements with contents" do
    @root << ELEMENT("test_element", "(another_element)")
    render(@root, @out)
    @out["<!ELEMENT test_element (another_element)>"].should_not be_nil
  end
  
  it "should render ATTLIST elements" do
    @root << ELEMENT("person", "ANY")
    @root << ATTLIST("person", "number", "CDATA", "#REQUIRED")
    render(@root, @out)
    @out["<!ATTLIST person number CDATA #REQUIRED>"].should_not be_nil
  end
  
  it "should render ELEMENT's before ATTLIST's" do
    @root << ATTLIST("person", "number", "CDATA", "#REQUIRED")
    @root << ELEMENT("person", "ANY")
    render(@root, @out)
    @out.index("<!ELEMENT person ANY>").should < @out.index("<!ATTLIST person number CDATA #REQUIRED")
  end
end