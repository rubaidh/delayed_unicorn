require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "delayed_unicorn"
    gem.summary = %Q{If you're thinking this is a cross between Unicorn and delayed_job, you're on the right track.}
    gem.description = %Q{So, Unicorn is the new shiny on the Ruby block. It's taken the concepts that
    old school Unix-heads have been applying to creating cross-platform, scalable,
    performant daemons for years and applied it cleverly to the world of
    Rack-based HTTP servers. (At last!).

    But we've another set of processes to manage in our application servers. It's
    the ones that do work in the background, outside of the HTTP request cycle.
    The same principles ought to apply in terms of process management, logging and
    memory efficiency.}
    gem.email = "mathie@rubaidh.com"
    gem.homepage = "http://github.com/rubaidh/delayed_unicorn"
    gem.authors = ["Rubaidh Ltd", "Graeme Mathieson"]
    gem.add_development_dependency "rspec"
    gem.add_development_dependency "yard"
  end

  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :spec => :check_dependencies

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files = ['README.rdoc', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'bin/*', 'features/**/*.feature']
  end
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
