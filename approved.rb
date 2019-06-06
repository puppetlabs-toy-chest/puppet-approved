#!/usr/bin/env ruby

# # What does it mean to be Puppet Approved?
#
# The following criteria describe characteristics that any Puppet Approved module must adhere to. It's expected that your module operates as documented within the constraints described below.
#
# Puppet Approved criteria are still under development and aren't yet considered stable.
#
# **Version 0.1.0.**
#
#
# ## A. Terminology
#
# The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
# "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be
# interpreted as described in [RFC 2119](http://www.faqs.org/rfcs/rfc2119.html).
#
# Failure to meet requirements that specify "MUST", "MUST NOT",  or "REQUIRED" will not be accepted into Puppet Approved. Failure to meet requirements that specify "SHALL", "SHALL NOT", "SHOULD",
# "SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" are acceptable but should be considered suggestions for improvement.
#
#
# ## B. Format
#
# The following documents the criteria used by Puppet Labs when reviewing modules for Puppet Approved. Each section is broken into three parts.
# **Requirements** describes  what a Puppet Approved module must and/or should comply to.
# **Resources** provides documentation and tools to help you improve your module.
# **Validation** provides specifics on how Puppet Labs validates Puppet Approved modules, if available.
#
require 'puppet-lint'
require 'json'
require 'rainbow/ext/string'
require 'git'

if ARGV[0].nil?
  puts `grep '^# ' approved.rb | sed 's/^# //'`
  exit
end

#client = Octokit::Client.new(:access_token => 'TOKEN')
repo = ARGV[0]
repo_name = repo.split("/").last.chomp(".git")
repo_user = repo.split("/")[-2]
if File.directory?(repo)
  WORKING_DIR = repo
else
  tmpdir = Dir.mktmpdir
  WORKING_DIR = "#{tmpdir}/#{repo_name}"

  Git.clone(repo, "#{tmpdir}/#{repo_name}")
end

puts ""
puts "---------------------------#{"-" * repo_name.length}"
puts "Starting Approval Eval for #{repo_name}".color(:cyan)
puts "by #{repo_user}".color(:blue)
puts "github uri: ".color(:blue) + repo
puts "---------------------------#{"-" * repo_name.length}"
puts ""

README_SECTIONS = %w[Module\ description Setup Usage Reference Limitations Development]
METADATA_FIELDS = %w[name version author summary license source project_page issues_url operatingsystem_support]

manifest_glob = Dir.glob(WORKING_DIR + '/manifests/**/**')

def checkmark
  "\u{2714}".color(:green)
end

def xmark
  "\u{2718}".color(:red)
end

def flowermark
  "\u{2055}".color(:yellow)
end

# ## 1. Style
# Modules that are developed with a consistent style are much more approachable for users and contributors. They're easier to refactor and are often more future-proof.
#
# ### Requirements
#
# Puppet Approved modules **must not** produce warnings (exceptions noted in validation section).
#
# ### Resources
# - [Puppet Labs Style Guide](https://docs.puppetlabs.com/guides/style_guide.html)
# - [puppet-lint](http://puppet-lint.com/) cli tool
# - [puppet-lint guide](http://puppet-lint.com/checks/) on resolving each check
# - community [puppet linter](http://puppetlinter.com/) service
#
# ### Validation
# Puppet Labs will run the puppet-lint cli tool on your modules manifests, using the following configuration.
#
# *   PuppetLint.configuration.fail_on_warnings
# *   PuppetLint.configuration.send('relative')
# *   PuppetLint.configuration.send('disable_80chars')
# *   PuppetLint.configuration.send('disable_class_inherits_from_params_class')
# *   PuppetLint.configuration.send('disable_class_parameter_defaults')
# *   PuppetLint.configuration.send('disable_documentation')
# *   PuppetLint.configuration.send('disable_single_quote_string_with_variables')
# *   PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]
#
#

puts "====STYLE".color(:cyan)

def manifest_directory?
  File.directory?(File.join(WORKING_DIR, '/manifests'))
end

def puppet_lint
  manifest_glob = Dir.glob(WORKING_DIR + '/manifests/**/**')
  pl = PuppetLint.new
  PuppetLint.configuration.fail_on_warnings
  PuppetLint.configuration.send('relative')
  PuppetLint.configuration.send('disable_80chars')
  PuppetLint.configuration.send('disable_class_inherits_from_params_class')
  PuppetLint.configuration.send('disable_class_parameter_defaults')
  PuppetLint.configuration.send('disable_documentation')
  PuppetLint.configuration.send('disable_single_quote_string_with_variables')
  PuppetLint.configuration.ignore_paths = ["spec//*.pp", "pkg//*.pp"]
  manifest_glob.each do |manifest|
    if manifest.include? ".pp"
      pl.code = File.read(manifest)
      pl.path = manifest
      pl.run
    end
  end
  print "Manifests directory exists and manifests are puppet-lint error free?"
  if pl.errors?
    puts " #{xmark}"
    print(" ⌙ Puppet lint problems found: ")
    pl.print_problems
  else
    puts " #{checkmark}"
  end
end

if manifest_directory?
  puppet_lint
else
  print "Manifests directory does not exist (this is optional)"
  puts " #{flowermark}"
end

# ## 2. Documentation
# Almost more critical than the module itself, thorough and readable documentation is the best way to ensure your module is used successfully and contributed to by others. Cutting corners here will limit usage.
#
# ### Requirements
#
# Puppet Approved modules **must** have a README and **should** conform to our documentation standards (following [this README template](https://docs.puppetlabs.com/puppet/latest/reference/modules_documentation.html) for example).
#
# Example usage **must** be documented in the README and classes, defines, parameters, and resources  used in the example usage **should** be completely documented in the README.
#
# As Puppet Approved matures, we will be routinely raising the bar for module documentation.
#
# ### Resources
# - [Standard README template](https://docs.puppetlabs.com/puppet/latest/reference/modules_documentation.html) on the Puppet Labs docs site.
# - preview of the [puppet strings](https://github.com/puppetlabs/puppetlabs-strings) cli tool.
#
#
# ### Validation
# Validation is based on a human review by the team at Puppet Labs.
#
#

puts "====DOCUMENTATION".color(:cyan)
print "README exists?"
if File.exist? "#{WORKING_DIR}/README.md" or File.exist? "#{WORKING_DIR}/README.markdown"
  puts " #{checkmark}"
  begin
    @readme = File.read("#{WORKING_DIR}/README.md")
  rescue
    @readme = File.read("#{WORKING_DIR}/README.markdown")
  end
else
  puts " #{xmark}"
end

manifestparams = []

if manifest_directory?
  manifest_glob.each do |manifest|
    if manifest.include?(".pp")
      lexed = PuppetLint::Lexer.new.tokenise(File.read(manifest))
      params = PuppetLint::Data.param_tokens(lexed).select{ |token| token.next_token.next_token.value == "=" }.map{ |token| token.value } if PuppetLint::Data.param_tokens(lexed)
      manifestparams.push(params).flatten!
    end
  end
end

#docparams = @readme.split("\n").select { |line| line if line.include? "#####" }.map { |line| line.split("`")[1] }
#
#documented = manifestparams & docparams
#
#paramspercent = manifestparams.size.to_f/documented.size.to_f * 100
#
#puts "#{paramspercent.round(2)}%"
#

def section_present?(section)
  print " ⌙ #{section}"
  if @readme.downcase.include?("## #{section.downcase}")
    puts " #{checkmark}"
  else
    puts " #{xmark}"
  end
end

def field_present?(field)
  print " ⌙ #{field}"
  if @metadata[field]
    puts " #{checkmark}"
  else
    puts " #{xmark}"
  end
end


print "Table of contents?"
if @readme
  if @readme.downcase.include?('#### Table of Contents'.downcase)
    puts " #{checkmark}"
  else
    puts " #{xmark}"
  end

  README_SECTIONS.each { |section| section_present?(section) }
end

# ## 3. Maintenance & Lifecycle
#
# Ideal Puppet Approved modules are regularly maintained, by a diverse group of people and don't lag between development and released artifacts.
#
# ### Requirements
# Puppet Approved modules **should** be regularly maintained and have received updates in the last 6 months, where applicable. Modules **should not** have more than 1 month gap between Forge and VCS. They **should** be contributed to by more than one person or organization.
#
# ### Resources
# Include a contributing guide with your module to provide would-be contributors with some guidelines. See [puppetlabs-ntp](https://github.com/puppetlabs/puppetlabs-ntp/blob/master/CONTRIBUTING.md) for an example.
#
# Publish to Forge quickly and easily with these tools.
# - [puppet blacksmith]() cli publisher
# - [ghpublisher](https://github.com/puppetlabs/ghpublisher) can help you build a travis.ci publishing workflow
#
# ### Validation
# We'll take a look at the development history of the project as a well as a list of contributors by following the Project URL link on Forge.
#
#

puts "====MAINTENANCE & LIFECYCLE".color(:cyan)


# ## 4. License
#
# ### Requirements
# Puppet Approved modules **must** be licensed and **should** be licensed under Apache,  MIT, or BSD licenses.
#
# ### Resources
# [choosealicense.com](http://choosealicense.com/) can help you pick between software licenses for your project.
#
# ### Validation
# The team at Puppet Labs will examine any available license file in the root of your module. They will also query the [Forge API](https://forgeapi.puppetlabs.com/) for the modules [license metadata](https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#fields-in-metadatajson).
#
puts "*CHECKS NOT CURRENTLY IMPLEMENTED*".color(:yellow)

puts "====LICENSE".color(:cyan)
print "LICENSE exists?"
if File.exist? "#{WORKING_DIR}/LICENSE"
  puts " #{checkmark}"
  @license = "#{WORKING_DIR}/LICENSE"
else
  puts " #{xmark}"
end

if File.exist? "#{WORKING_DIR}/metadata.json"
  @metadata = JSON.parse(File.read("#{WORKING_DIR}/metadata.json")) 

  puts "License type: #{@metadata['license']}"

  license_verified = false

  if @metadata['license'] == 'Apache-2.0' and @license
    license_verified = File.read("#{WORKING_DIR}/LICENSE").match /Apache/
    puts "License type verified #{checkmark}" if license_verified

  elsif @metadata['license'] == 'MIT' and @license
    license_verified = File.read("#{WORKING_DIR}/LICENSE").match /MIT/
    puts "License type verified #{checkmark}" if license_verified

  elsif  @metadata['license'] == 'BSD' and @license
    license_verified = File.read("#{WORKING_DIR}/LICENSE").match /BSD/
    puts "License type verified #{checkmark}" if license_verified
  else
    puts "License type not verified #{flowermark}"
  end
end
# ## 5. Originality
#
# Puppet Approved modules are intended to make it simple to find a great module to solve a given automation task. Limiting the number of available choices for a given technology helps simplify the process.
#
# ### Validation
#
# The Puppet Labs team will attempt to limit duplicate modules for a given technology. Multiple modules are acceptable so long as they solve the problem in a sufficiently different way or offer functionality above and beyond existing Puppet Approved modules. The collection of modules will be regularly evaluated against other Forge modules.
#
#

puts "====ORIGINALITY".color(:cyan)

# ## 6. Metadata
#
# Thorough and accurate module metadata helps users find your module on the Puppet Forge and ensures that it takes advantage of all the features Forge offers. The metadata is used throughout; in search filters, module pages and the API service.
#
# ### Requirements
#
# Puppet Approved modules **must**:
#
# *   Accurately express every required metadata field.
# *   Express compatibility metadata for Puppet/PE and OS versions module is compatible with.
# *   Accurately express issues\_url and project_page metadata.
#
# Approved modules **should** provide accurate information for every metadata field.
#
# ### Resources
# - [Geppetto](http://puppetlabs.github.io/geppetto/download.html) has a built-in module metadata editor.
# - [jsonlint.com](http://jsonlint.com/), [syntastic.vim](https://github.com/scrooloose/syntastic) and [jacinto.vim](https://github.com/alfredodeza/jacinto.vim) help you validate and write JSON.
# - Lint module metadata with this [module metadata linter](https://github.com/nibalizer/metadata-json-lint).
# - See our [module publishing documentation](https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html) for more.
#
# ### Validation
# The Puppet Forge's [API service](https://forgeapi.puppetlabs.com) is considered authoritative for any modules metadata. We query the REST endpoint for a module and examine its metadata.
# Example: curl 'https://forgeapi.puppetlabs.com/v3/modules/puppetlabs-ntp'
#
#

puts "*CHECKS NOT CURRENTLY IMPLEMENTED*".color(:yellow)

puts "====METADATA".color(:cyan)
print "metadata.json exists?"
if File.exist? "#{WORKING_DIR}/metadata.json"
  puts " #{checkmark}"
else
  puts " #{xmark}"
end

METADATA_FIELDS.each { |field| field_present?(field) }

if @metadata['requirements'][0]['name'] == 'puppet'
  puts " ⌙ puppet requirement #{checkmark}"
end

# ## 7. SemVer
# Versioning your module according to SemVer rules sets expectations for users upgrading their version of your module, keeping things predictable and consistent.
#
# ### Requirements
# Puppet Approved modules **must** be versioned according to SemVer v1 rules. Candidate releases must be >=1.x.
#
# ### Resources
# You can learn more about SemVer v1 [at its website](http://semver.org/spec/v1.0.0.html).
#
# ### Validation
# We evaluate a modules version against SemVer v1 rules and expect a version greater or equal to 1.0.0 to review for Puppet Approved.
#
#

puts "====SEMVER".color(:cyan)
if @metadata['version'] =~ /\d.\d?\d.\d/
  puts "#{@metadata['version']} #{checkmark}"
else
  puts " #{xmark}"
end

# ## 8. Testing
#
# ### Requirements
# As with any module, it’s a universally accepted best practice to test and validate a module prior to deploying in production.  In that spirit, Puppet Approved modules:
#
# *   **Should** have rspec-puppet tests for manifests.
# *   **Should** have acceptance tests, preferably written with the [beaker](https://github.com/puppetlabs/beaker) framework.
# *   Types, providers, facts, and functions **should** have at least 1 unit test each.
#
# ### Resources
# - [rspec-puppet](http://rspec-puppet.com/) is a really good framework for unit testing Puppet modules.
# - [beaker](https://github.com/puppetlabs/beaker) is an acceptance framework for Puppet modules, capable of testing against Puppet Enterprise and the open-source Puppet projects.
#
# ### Validation
# We'll manually run your tests or inspect your public CI results.
#
#

puts "====TESTING".color(:cyan)

print "Acceptance tests"

def acceptance_tests?
  File.directory?(File.join(WORKING_DIR, 'spec/acceptance'))
end

if acceptance_tests?
  puts " #{checkmark}"
else
  puts " #{xmark}"
end


def unit_tests?
  File.exist?("#{WORKING_DIR}/spec/unit") or File.exist?("#{WORKING_DIR}/spec/classes")
end

print "Unit tests"

if unit_tests?
  puts " #{checkmark}"
else
  puts " #{xmark}"
end

FileUtils.remove_entry_secure(tmpdir) if tmpdir

# ## 9. Puppet Versions & Features
# Though we like to move quickly with new Puppet features, Puppet Approved modules must be stable, reliable and ready for production use.
#
# ### Requirements
#
# Puppet Approved modules:
# - **Must not** rely on experimental Puppet features (like the future parser or in-module hiera data)
# - **Must** be compatible with the Puppet 3 and Puppet Enterprise 3 series.
# - **Should not** directly call out to an [ENC](https://docs.puppetlabs.com/guides/external_nodes.html) like the hiera() function for example.
#
#
# ### Resources
#
# - `puppet --version` should return something in the 3.x series.
#
# - `puppet config print parser` will return `current` or `future`.

puts "====PUPPET VERSIONS & FEATURES".color(:cyan)

puts "*CHECKS NOT CURRENTLY IMPLEMENTED*".color(:yellow)
