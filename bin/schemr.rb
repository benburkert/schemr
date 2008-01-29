$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../lib"))

require 'schemr'

module Schemr::SchemrEngine
  module_function
  def execute(options)
    src = options.has_key?(:input)  ? open("#{Dir.pwd}/#{options[:input]}", "r")  : STDIN
    out = options.has_key?(:output) ? open("#{Dir.pwd}/#{options[:output]}", "w") : STDOUT
    rule_tree = Schemr::DSL::ParseEngine.new(src.read).parse
    element_tree = Schemr::DOM::TranslationEngine.new(options[:translator].to_sym).translate(rule_tree)
    out << Schemr::RenderEngine.new(element_tree).render_as(options[:renderer].to_sym)
  end
end

COMMAND_LINE = {
  :input =>      ["-i", "--input", "FILE_NAME", "Specifies the input target."],
  :output =>     ["-o", "--output", "FILE_NAME", "Specifies the output target."],
  :translator => ["-t", "--translator", "[dtd|xsd|relaxng|micro|kwalify]", "Invokes the translation engine."],
  :renderer   => ["-r", "--renderer", "[dtd|xml|html|yaml|json]", "Invokes the render engine."] }
  
SHORT = COMMAND_LINE.collect {|key, value| value[0]}
LONG = COMMAND_LINE.collect {|key, value| value[1]}

if ARGV.any? {|arg| arg == "-h" || arg == "--help"}
  puts "SHORT\t\tLONG\t\tFORMAT\t\t\t\tDESCRIPTION"
  COMMAND_LINE.collect do |key, value|
    puts value.collect {|s| s.length < 8 ? s + "\t" : s }.join("\t")
  end
  exit
end

options = {}

ARGV.each_with_index do |arg, index|
  COMMAND_LINE.each do |key, value|
    options[key] = ARGV[index + 1] if arg == value[0]
    options[key] = ARGV[index + 1] if arg == value[1]
  end
end

Schemr::SchemrEngine.execute(options)