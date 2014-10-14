# What does it mean to be Puppet Approved?

The following criteria describe characteristics that any Puppet Approved module must adhere to. It's expected that your module operates as documented within the constraints described below. 

Puppet Approved criteria are still under development and aren't yet considered stable.

**Version 0.1.0.** 


## A. Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" in this document are to be
interpreted as described in [RFC 2119](http://www.faqs.org/rfcs/rfc2119.html).  

Failure to meet requirements that specify "MUST", "MUST NOT",  or "REQUIRED" will not be accepted into Puppet Approved. Failure to meet requirements that specify "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED",  "MAY", and "OPTIONAL" are acceptable but should be considered suggestions for improvement.  


## B. Format

The following documents the criteria used by Puppet Labs when reviewing modules for Puppet Approved. Each section is broken into three parts.   
**Requirements** describes  what a Puppet Approved module must and/or should comply to.   
**Resources** provides documentation and tools to help you improve your module.  
**Validation** provides specifics on how Puppet Labs validates Puppet Approved modules, if available. 

## 1. Style
Modules that are developed with a consistent style are much more approachable for users and contributors. They're easier to refactor and are often more future-proof. 

### Requirements

Puppet Approved modules **must not** produce warnings (exceptions noted in validation section).

### Resources
- [Puppet Labs Style Guide](https://docs.puppetlabs.com/guides/style_guide.html)
- [puppet-lint](http://puppet-lint.com/) cli tool
- [puppet-lint guide](http://puppet-lint.com/checks/) on resolving each check
- community [puppet linter](http://puppetlinter.com/) service

### Validation
Puppet Labs will run the puppet-lint cli tool on your modules manifests, using the following configuration. 

*   PuppetLint.configuration.fail_on_warnings
*   PuppetLint.configuration.send('relative')
*   PuppetLint.configuration.send('disable_80chars')
*   PuppetLint.configuration.send('disable_class_inherits_from_params_class')
*   PuppetLint.configuration.send('disable_class_parameter_defaults')
*   PuppetLint.configuration.send('disable_documentation')
*   PuppetLint.configuration.send('disable_single_quote_string_with_variables')
*   PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "pkg/**/*.pp"]


## 2. Documentation
Almost more critical than the module itself, thorough and readable documentation is the best way to ensure your module is used successfully and contributed to by others. Cutting corners here will limit usage. 

### Requirements

Puppet Approved modules **must** have a README and **should** conform to our documentation standards (following [this README template](https://docs.puppetlabs.com/puppet/latest/reference/modules_documentation.html) for example).

Example usage **must** be documented in the README and classes, defines, parameters, and resources  used in the example usage **should** be completely documented in the README. 

As Puppet Approved matures, we will be routinely raising the bar for module documentation. 

### Resources
- [Standard README template](https://docs.puppetlabs.com/puppet/latest/reference/modules_documentation.html) on the Puppet Labs docs site. 
- preview of the [puppet strings](https://github.com/puppetlabs/puppetlabs-strings) cli tool.


### Validation
Validation is based on a human review by the team at Puppet Labs.


## 3. Maintenance & Lifecycle

Ideal Puppet Approved modules are regularly maintained, by a diverse group of people and don't lag between development and released artifacts. 

### Requirements
Puppet Approved modules **should** be regularly maintained and have received updates in the last 6 months, where applicable. Modules **should not** have more than 1 month gap between Forge and VCS. They **should** be contributed to by more than one person or organization. 

### Resources
Include a contributing guide with your module to provide would-be contributors with some guidelines. See [puppetlabs-ntp](https://github.com/puppetlabs/puppetlabs-ntp/blob/master/CONTRIBUTING.md) for an example.

Publish to Forge quickly and easily with these tools.
- [puppet blacksmith]() cli publisher
- [ghpublisher](https://github.com/puppetlabs/ghpublisher) can help you build a travis.ci publishing workflow

### Validation
We'll take a look at the development history of the project as a well as a list of contributors by following the Project URL link on Forge. 


## 4. License

### Requirements
Puppet Approved modules **must** be licensed and **should** be licensed under Apache,  MIT, or BSD licenses.

### Resources
[choosealicense.com](http://choosealicense.com/) can help you pick between software licenses for your project.

### Validation
The team at Puppet Labs will examine any available license file in the root of your module. They will also query the [Forge API](https://forgeapi.puppetlabs.com/) for the modules [license metadata](https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html#fields-in-metadatajson). 

## 5. Originality

Puppet Approved modules are intended to make it simple to find a great module to solve a given automation task. Limiting the number of available choices for a given technology helps simplify the process. 

### Validation

The Puppet Labs team will attempt to limit duplicate modules for a given technology. Multiple modules are acceptable so long as they solve the problem in a sufficiently different way or offer functionality above and beyond existing Puppet Approved modules. The collection of modules will be regularly evaluated against other Forge modules.  


## 6. Metadata

Thorough and accurate module metadata helps users find your module on the Puppet Forge and ensures that it takes advantage of all the features Forge offers. The metadata is used throughout; in search filters, module pages and the API service. 

### Requirements

Puppet Approved modules **must**:

*   Accurately express every required metadata field.
*   Express compatibility metadata for Puppet/PE and OS versions module is compatible with.
*   Accurately express issues\_url and project_page metadata.

Approved modules **should** provide accurate information for every metadata field.

### Resources
- [Geppetto](http://puppetlabs.github.io/geppetto/download.html) has a built-in module metadata editor.
- [jsonlint.com](http://jsonlint.com/), [syntastic.vim](https://github.com/scrooloose/syntastic) and [jacinto.vim](https://github.com/alfredodeza/jacinto.vim) help you validate and write JSON.
- Lint module metadata with this [module metadata linter](https://github.com/nibalizer/metadata-json-lint).
- See our [module publishing documentation](https://docs.puppetlabs.com/puppet/latest/reference/modules_publishing.html) for more.

### Validation 
The Puppet Forge's [API service](https://forgeapi.puppetlabs.com) is considered authoritative for any modules metadata. We query the REST endpoint for a module and examine its metadata.   
Example: curl 'https://forgeapi.puppetlabs.com/v3/modules/puppetlabs-ntp'


## 7. SemVer
Versioning your module according to SemVer rules sets expectations for users upgrading their version of your module, keeping things predictable and consistent. 

### Requirements
Puppet Approved modules **must** be versioned according to SemVer v1 rules. Candidate releases must be >=1.x.

### Resources
You can learn more about SemVer v1 [at its website](http://semver.org/spec/v1.0.0.html).

### Validation
We evaluate a modules version against SemVer v1 rules and expect a version greater or equal to 1.0.0 to review for Puppet Approved. 


## 8. Testing

### Requirements
As with any module, it’s a universally accepted best practice to test and validate a module prior to deploying in production.  In that spirit, Puppet Approved modules:

*   **Should** have rspec-puppet tests for manifests.
*   **Should** have acceptance tests, preferably written with the [beaker](https://github.com/puppetlabs/beaker) framework.
*   Types, providers, facts, and functions **should** have at least 1 unit test each.

### Resources
- [rspec-puppet](http://rspec-puppet.com/) is a really good framework for unit testing Puppet modules.   
- [beaker](https://github.com/puppetlabs/beaker) is an acceptance framework for Puppet modules, capable of testing against Puppet Enterprise and the open-source Puppet projects. 

### Validation
We'll manually run your tests or inspect your public CI results.


## 9. Puppet Versions & Features
Though we like to move quickly with new Puppet features, Puppet Approved modules must be stable, reliable and ready for production use.  

### Requirements

Puppet Approved modules:
- **Must not** rely on experimental Puppet features (like the future parser or in-module hiera data)
- **Must** be compatible with the Puppet 3 and Puppet Enterprise 3 series.
- **Should not** directly call out to an [ENC](https://docs.puppetlabs.com/guides/external_nodes.html) like the hiera() function for example. 


### Resources

- `puppet --version` should return something in the 3.x series. 

- `puppet config print parser` will return `current` or `future`.
