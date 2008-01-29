require File.dirname(__FILE__) + '/../../spec_helper'

describe Schemr::XmlRenderer, "#render" do
  def new_element_tree(*args)
    Schemr::DOM::ElementTree.new(*args)
  end
  
  def new_element(*args)
    Schemr::DOM::Element.new(*args)
  end
  
  before(:each) do
    @root = new_element_tree("test")
    @out = ""
    @endl = "\n"
  end
  
  it "should have a root element for the tree name" do
    render(@root, @out)
    @out.index("<test").should == 0
  end
  
  it "should include the root element's attributes" do
    @root.attributes["new_attribute"] = "new value"
    render(@root, @out)
    @out["<test new_attribute=\"new value\""].should_not be_nil
  end
  
  it "should have an empty root element if the element tree has no children" do
    render(@root, @out)
    @out["<test/>"].should_not be_nil
  end
  
  it "should render all child elements" do
    @root << new_element(:first_child, :some_attribute => "some value")
    render(@root, @out)
    @out["<first_child some_attribute=\"some value\"/>"].should_not be_nil
  end
end

describe Schemr::XmlRenderer, "dtd rendering" do
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
end