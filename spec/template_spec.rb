require File.dirname(__FILE__) + '/spec_helper'
require 'rubygems'
begin
  require 'xml/libxml'
  describe "Dtd examples" do
    it "should be able to parse the wadl example into dtd" do
      open("#{File.dirname(__FILE__)}/templates/wadl", "r+") do |f|
        rule_tree = Schemr::DSL::ParseEngine.new(f.readlines.join).parse
        element_tree = Schemr::DOM::TranslationEngine.new(:dtd).translate(rule_tree)
        out = Schemr::RenderEngine.new(element_tree).render_as(:dtd)
        
        dtd = XML::Dtd.new(out)
      end
    end
  
    it "should be able to parse the xcalendar example into dtd" do
      open("#{File.dirname(__FILE__)}/templates/xcalendar", "r+") do |f|
        rule_tree = Schemr::DSL::ParseEngine.new(f.readlines.join).parse
        element_tree = Schemr::DOM::TranslationEngine.new(:dtd).translate(rule_tree)
        out = Schemr::RenderEngine.new(element_tree).render_as(:dtd)
        
        dtd = XML::Dtd.new(out)
      end
    end
  
    it "should be able to parse the xcard example into dtd" do
      open("#{File.dirname(__FILE__)}/templates/xcard", "r+") do |f|
        rule_tree = Schemr::DSL::ParseEngine.new(f.readlines.join).parse
        element_tree = Schemr::DOM::TranslationEngine.new(:dtd).translate(rule_tree)
        out = Schemr::RenderEngine.new(element_tree).render_as(:dtd)
        
        dtd = XML::Dtd.new(out)
      end
    end
    
    it "should be able to parse the department example into dtd" do
      open("#{File.dirname(__FILE__)}/templates/department", "r+") do |f|
        rule_tree = Schemr::DSL::ParseEngine.new(f.readlines.join).parse
        element_tree = Schemr::DOM::TranslationEngine.new(:dtd).translate(rule_tree)
        out = Schemr::RenderEngine.new(element_tree).render_as(:dtd)
        
        dtd = XML::Dtd.new(out)
      end
    end
  end
rescue LoadError
end
begin
  require 'rexml/document'
  describe "Dtd examples" do
    it "should be able to parse the wadl example into xml" do
      open("#{File.dirname(__FILE__)}/templates/wadl", "r+") do |f|
        rule_tree = Schemr::DSL::ParseEngine.new(f.readlines.join).parse
        element_tree = Schemr::DOM::TranslationEngine.new(:dtd).translate(rule_tree)
        out = Schemr::RenderEngine.new(element_tree).render_as(:xml)
        
        xml = REXML::Document.new(out)
      end
    end

    it "should be able to parse the xcalendar example into xml" do
      open("#{File.dirname(__FILE__)}/templates/xcalendar", "r+") do |f|
        rule_tree = Schemr::DSL::ParseEngine.new(f.readlines.join).parse
        element_tree = Schemr::DOM::TranslationEngine.new(:dtd).translate(rule_tree)
        out = Schemr::RenderEngine.new(element_tree).render_as(:xml)
    
        xml = REXML::Document.new(out)
      end
    end

    it "should be able to parse the xcard example into xml" do
      open("#{File.dirname(__FILE__)}/templates/xcard", "r+") do |f|
        rule_tree = Schemr::DSL::ParseEngine.new(f.readlines.join).parse
        element_tree = Schemr::DOM::TranslationEngine.new(:dtd).translate(rule_tree)
        out = Schemr::RenderEngine.new(element_tree).render_as(:xml)
        
        xml = REXML::Document.new(out)
      end
    end
  
    it "should be able to parse the department example into xml" do
      open("#{File.dirname(__FILE__)}/templates/department", "r+") do |f|
        rule_tree = Schemr::DSL::ParseEngine.new(f.readlines.join).parse
        element_tree = Schemr::DOM::TranslationEngine.new(:dtd).translate(rule_tree)
        out = Schemr::RenderEngine.new(element_tree).render_as(:xml)
        
        xml = REXML::Document.new(out)
      end
    end
  end
rescue LoadError
end

describe "Xsd examples" do
  it "should be able to parse the wadl example into xml" do
    open("#{File.dirname(__FILE__)}/templates/wadl", "r+") do |f|
      rule_tree = Schemr::DSL::ParseEngine.new(f.readlines.join).parse
      element_tree = Schemr::DOM::TranslationEngine.new(:xsd).translate(rule_tree)
      out = Schemr::RenderEngine.new(element_tree).render_as(:xml)
      puts out
      xml = REXML::Document.new(out)
    end
  end

  it "should be able to parse the xcalendar example into xml" do
    open("#{File.dirname(__FILE__)}/templates/xcalendar", "r+") do |f|
      rule_tree = Schemr::DSL::ParseEngine.new(f.readlines.join).parse
      element_tree = Schemr::DOM::TranslationEngine.new(:xsd).translate(rule_tree)
      out = Schemr::RenderEngine.new(element_tree).render_as(:xml)
      
      xml = REXML::Document.new(out)
    end
  end

  it "should be able to parse the xcard example into xml" do
    open("#{File.dirname(__FILE__)}/templates/xcard", "r+") do |f|
      rule_tree = Schemr::DSL::ParseEngine.new(f.readlines.join).parse
      element_tree = Schemr::DOM::TranslationEngine.new(:xsd).translate(rule_tree)
      out = Schemr::RenderEngine.new(element_tree).render_as(:xml)
      
      xml = REXML::Document.new(out)
    end
  end

  it "should be able to parse the department example into xml" do
    open("#{File.dirname(__FILE__)}/templates/department", "r+") do |f|
      rule_tree = Schemr::DSL::ParseEngine.new(f.readlines.join).parse
      element_tree = Schemr::DOM::TranslationEngine.new(:xsd).translate(rule_tree)
      out = Schemr::RenderEngine.new(element_tree).render_as(:xml)
      
      xml = REXML::Document.new(out)
    end
  end
end