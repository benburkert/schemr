require 'spec/rake/spectask'
require 'spec/rake/verify_rcov'
require 'rake/rdoctask'

task :default => :spec

desc 'Continuous build target'
task :cruise do
  out = ENV['CC_BUILD_ARTIFACTS']
  mkdir_p out unless File.directory? out if out
  
  mkdir_p "doc"
  mkdir_p "doc/rdoc"

  Rake::Task["spec:rcov:verify"].invoke
  mv 'doc/rdoc', "#{out}/rdoc" if out
  mv 'doc/coverage', "#{out}/rspec coverage" if out
  
  Rake::Task["spec:doc:html"].invoke
  mv 'doc/rspec_report', "#{out}/rspec report" if out
  
  Rake::Task["saikuro"].invoke
  mv 'doc/saikuro/cyclomatic', "#{out}/cyclomatic complexity" if out
  mv 'doc/saikuro/token', "#{out}/token complexity" if out
  
end

desc "Run the specs for schemr"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts  = ["--colour"]
end

namespace :spec do
  desc "Generate RCov report for schemr"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_files  = FileList['spec/**/*_spec.rb']
    t.rcov        = true
    t.rcov_dir    = 'doc/coverage'
    t.rcov_opts   = ['--text-report', '--exclude', "spec/,#{File.expand_path(File.join(File.dirname(__FILE__),'../../..'))},lib/util.rb"] 
  end

  namespace :rcov do
    desc "Verify RCov threshold for schemr"
    RCov::VerifyTask.new(:verify => "spec:rcov") do |t|
      t.threshold = 100.0
      t.index_html = File.join(File.dirname(__FILE__), 'doc/coverage/index.html')
    end
  end
  
  desc "Generate specdoc for schemr"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_files  = FileList['spec/**/*_spec.rb']
    t.spec_opts   = ["--format", "specdoc:SPECDOC"]
  end

  namespace :doc do
    desc "Generate html specdoc for schemr"
    Spec::Rake::SpecTask.new(:html => :rdoc) do |t|
      t.spec_files    = FileList['spec/**/*_spec.rb']
      mkdir_p "doc/rspec_report"
      t.spec_opts     = ["--format", "html:doc/rspec_report/index.html", "--diff"]
    end
  end
end

task :rdoc => :doc
task "SPECDOC" => "spec:doc"

desc "Generate rdoc for schemr"
Rake::RDocTask.new(:doc) do |t|
  t.rdoc_dir = 'doc/rdoc'
  #t.main     = 'README'
  t.title    = "SchemR"
  t.options  = ['--line-numbers', '--inline-source']
  #t.rdoc_files.include('README', 'SPECDOC', 'MIT-LICENSE')
  t.rdoc_files.include('lib/**/*.rb')
end

desc "Generate a report for the cyclomatic complexity"
task :saikuro do
  system "saikuro -c -i lib -y 0 -w 3 -e 5 -o doc/saikuro/cyclomatic"
  mv 'doc/saikuro/cyclomatic/index_cyclo.html', 'doc/saikuro/cyclomatic/index.html'
  
  system "saikuro -t -i lib -y 0 -w 3 -e 5 -o doc/saikuro/token"
  mv 'doc/saikuro/token/index_token.html', 'doc/saikuro/token/index.html'
end

namespace :doc do 
  desc "Generate all documentation (rdoc, specdoc, specdoc html and rcov) for schemr"
  task :all => ["spec:doc:html", "spec:doc", "spec:rcov", "doc"]
end