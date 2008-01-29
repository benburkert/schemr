require File.dirname(__FILE__) + '/../../spec_helper'

def new_element(*args)
  Schemr::DOM::Element.new(*args)
end

describe Schemr::DOM::Element, "'s new instances" do
  it "should expect the first argument of the constructor to to be the identifier" do
    new_element("name").identifier.should == "name"
  end
  
  it "should assign options as attributes in their string form" do
    new_element("name", :attr => :value).attributes.should == {"attr" => "value"}
  end
end

describe Schemr::DOM::Element, "by default" do
  it "should not have any attributes" do
    new_element("name").attributes.should be_empty
  end
  
  it "should not have any children" do
    new_element("name").children.should be_empty
  end
end

describe Schemr::DOM::Element do
  it "should respond to messages to attributes" do
    new_element("name", :attr => :value).attr.should == "value"
  end
  
  it "should add attributes if setter method does not exist" do
    element = new_element("identifier")
    element.name = "name"
    element.name.should == "name"
  end
  
  it "should add new attribute keys as symbols" do
    element = new_element("identifier")
    element["convert_to_sym"] = "value"
    element[:convert_to_sym].should == "value"
  end
  
  it "should add new attributes as nil if the key is not found" do
    element = new_element("identifier")
    element[:some_key]
    element.attributes.keys.should include("some_key")
    element[:some_key].should be_nil
    element.some_key.should be_nil
  end
  
  it "should still call method_missing if the method is not an attribute" do
    element = new_element("identifier")
    lambda { element.some_method_that_doesnt_exist }.should raise_error(NoMethodError)
  end
end