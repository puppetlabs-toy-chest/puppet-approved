require 'puppet-lint'
require 'json'
require 'rainbow/ext/string'
require 'git'

# client = Octokit::Client.new(:access_token => 'TOKEN')
repo = ARGV[0]
repo_name = repo.split("/").last.chomp(".git")
repo_user = repo.split("/")[-2]
tmpdir = Dir.mktmpdir
WORKING_DIR = "#{tmpdir}/#{repo_name}"

FileUtils.remove_entry_secure tmpdir

Git.clone(repo, "#{tmpdir}/#{repo_name}")

puts ""
puts "---------------------------#{"-" * repo_name.length}"
puts "Starting Approval Eval for #{repo_name}".color(:cyan)
puts "by #{repo_user}".color(:blue)
puts "github uri: ".color(:blue) + repo
puts "---------------------------#{"-" * repo_name.length}"
puts ""

README_SECTIONS = %w[Module\ Description Setup Usage Reference Limitations Development]
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

puts "====STYLE".color(:cyan)
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

  pl.print_problems

end

puppet_lint


puts "====DOCUMENTATION".color(:cyan)
print "README exists?"
if File.exist? "#{WORKING_DIR}/README.md"
  puts " #{checkmark}"
  @readme = File.read("#{WORKING_DIR}/README.md")
else
  puts " #{xmark}"
end

manifestparams = []

manifest_glob.each do |manifest|
  if manifest.include?(".pp")
    lexed = PuppetLint::Lexer.new.tokenise(File.read(manifest))
    params = PuppetLint::Data.param_tokens(lexed).select{ |token| token.next_token.next_token.value == "=" }.map{ |token| token.value } if PuppetLint::Data.param_tokens(lexed)
    manifestparams.push(params).flatten!
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
  if @readme.include?("## #{section}")
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
    puts " missing!"
  end
end


print "Table of contents?"

if @readme.include?('#### Table of Contents')
  puts " #{checkmark}"
else
  puts " #{xmark}"
end

README_SECTIONS.each { |section| section_present?(section) }

puts "====MAINTENANCE & LIFECYCLE".color(:cyan)


puts "====METADATA".color(:cyan)
print "metadata.json exists?"
if File.exist? "#{WORKING_DIR}/metadata.json"
  puts " #{checkmark}"
  @metadata = JSON.parse(File.read("#{WORKING_DIR}/metadata.json"))
else
  puts " #{xmark}"
end

METADATA_FIELDS.each { |field| field_present?(field) }

if @metadata['requirements'][0]['name'] == 'puppet'
  puts " ⌙ puppet requirement #{checkmark}"
end

puts "====LICENSE".color(:cyan)
print "LICENSE exists?"
if File.exist? "#{WORKING_DIR}/LICENSE"
  puts " #{checkmark}"
  @license = "#{WORKING_DIR}/LICENSE"
else
  puts " #{xmark}"
end

puts "License type: #{@metadata['license']}"

license_verified = false

if @metadata['license'] == 'Apache-2.0' and @license
  license_verified = File.read("#{WORKING_DIR}/LICENSE").match /Apache/
  puts "License type verified #{checkmark}" if license_verified
end

puts "====SEMVER".color(:cyan)
if @metadata['version'] =~ /\d.\d?\d.\d/
  puts "#{@metadata['version']} #{checkmark}"
else
  puts "nope!"
end

puts "====TESTING".color(:cyan)

print "Acceptance tests"

def acceptance_tests?
  File.exist?(WORKING_DIR + 'spec/acceptance')
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

FileUtils.rm_rf(WORKING_DIR)