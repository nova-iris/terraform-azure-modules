## 📋 Pull Request Description

### What does this PR do?
<!-- Provide a clear and concise description of the changes -->

### Type of Change
<!-- Mark the relevant option with an "x" -->
- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] 💥 Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] 📚 Documentation update
- [ ] 🔧 Configuration change
- [ ] ♻️ Code refactoring (no functional changes)
- [ ] 🧪 Test additions or modifications
- [ ] 🎨 Style changes (formatting, missing semi-colons, etc.)

### Modules Affected
<!-- List the modules that are modified in this PR -->
- [ ] azure-firewall
- [ ] azure-load-balancer
- [ ] azure-private-dns
- [ ] azure-storage
- [ ] azure-vm
- [ ] azure-vnet
- [ ] azure-vwan
- [ ] azure-vwan-dns
- [ ] azure-vwan-hub
- [ ] Other: _______________

## 🧪 Testing

### Testing Performed
<!-- Describe the testing you've performed -->
- [ ] Terraform validation (`terraform validate`)
- [ ] Terraform format check (`terraform fmt`)
- [ ] TFLint validation
- [ ] Security scanning (Checkov)
- [ ] Example deployments tested
- [ ] Manual testing performed

### Test Results
<!-- Include relevant test outputs or results -->
```
# Add any relevant test output here
```

## 📖 Documentation

### Documentation Updates
- [ ] README.md updated (if applicable)
- [ ] Variables documented
- [ ] Outputs documented
- [ ] Examples updated
- [ ] CHANGELOG.md updated (for releases)

### Breaking Changes
<!-- If this is a breaking change, describe the impact and migration path -->
- [ ] N/A - No breaking changes
- [ ] Breaking changes documented below:

**Breaking Changes Description:**
<!-- Describe what breaks and how users should migrate -->

**Migration Path:**
<!-- Provide clear instructions for users to migrate -->

## 🔒 Security Considerations

- [ ] No secrets or sensitive information included
- [ ] Security best practices followed
- [ ] IAM permissions follow least privilege principle
- [ ] Network security properly configured

## ✅ Checklist

### Code Quality
- [ ] Code follows the project's style guidelines
- [ ] Self-review of my own code completed
- [ ] Code is properly commented, particularly in hard-to-understand areas
- [ ] No debugging code or commented-out code left in
- [ ] Variable names are descriptive and follow naming conventions

### Module Standards
- [ ] Module follows standard structure (main.tf, variables.tf, outputs.tf, versions.tf, README.md)
- [ ] All variables have descriptions and appropriate types
- [ ] All outputs have descriptions
- [ ] Required providers and versions are specified
- [ ] Tags are properly implemented

### Examples
- [ ] At least one working example provided
- [ ] Examples follow best practices
- [ ] Examples are documented
- [ ] Examples have been tested

### Terraform Best Practices
- [ ] Resources use appropriate naming conventions
- [ ] No hardcoded values (use variables instead)
- [ ] Terraform state is not included
- [ ] Provider configurations are appropriate
- [ ] Resource dependencies are properly handled

## 📋 Additional Notes

### Related Issues
<!-- Link any related issues -->
Fixes #(issue number)
Closes #(issue number)
Related to #(issue number)

### Additional Context
<!-- Add any other context about the pull request here -->

### Screenshots (if applicable)
<!-- Add screenshots to help explain your changes -->

---

## 🔍 Review Checklist for Maintainers

- [ ] PR title follows conventional commit format
- [ ] All checks pass (CI, linting, security)
- [ ] Code review completed
- [ ] Documentation is adequate
- [ ] Examples work as expected
- [ ] Breaking changes are properly documented
- [ ] Version bump requirements identified
