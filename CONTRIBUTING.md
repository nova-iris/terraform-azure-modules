# Contributing to Terraform Azure Modules

Thank you for your interest in contributing to our Terraform Azure Modules! This guide will help you get started with contributing to the project.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Module Standards](#module-standards)
- [Testing](#testing)
- [Documentation](#documentation)
- [Pull Request Process](#pull-request-process)
- [Release Process](#release-process)

## 📜 Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## 🚀 Getting Started

### Prerequisites

- **Terraform**: >= 1.0
- **Azure CLI**: Latest version
- **Git**: For version control
- **Azure Subscription**: For testing

### Development Environment Setup

1. **Fork and Clone**
   ```bash
   git clone https://github.com/your-username/terraform-azure-modules.git
   cd terraform-azure-modules
   ```

2. **Install Dependencies**
   ```bash
   # Install Terraform
   wget https://releases.hashicorp.com/terraform/1.9.8/terraform_1.9.8_linux_amd64.zip
   unzip terraform_1.9.8_linux_amd64.zip
   sudo mv terraform /usr/local/bin/

   # Install Azure CLI
   curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

   # Install TFLint
   curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

   # Install Checkov
   pip3 install checkov
   ```

3. **Azure Authentication**
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

## 🔄 Development Workflow

### 1. Create a Feature Branch

```bash
git checkout -b feature/your-feature-name
```

### 2. Make Your Changes

Follow our [Module Standards](#module-standards) when making changes.

### 3. Test Your Changes

```bash
# Format code
terraform fmt -recursive

# Validate Terraform
terraform validate

# Run linting
tflint --recursive

# Run security scan
checkov -d . --framework terraform
```

### 4. Commit Your Changes

We use [Conventional Commits](https://www.conventionalcommits.org/) format:

```bash
git commit -m "feat(azure-vm): add support for custom data scripts"
git commit -m "fix(azure-vnet): resolve subnet delegation issue"
git commit -m "docs(azure-storage): update README with new examples"
```

**Commit Types:**
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation only changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request using our [PR template](.github/pull_request_template.md).

## 📐 Module Standards

### Directory Structure

Every module must follow this structure:

```
module-name/
├── main.tf              # Main resource definitions
├── variables.tf         # Input variable definitions
├── outputs.tf           # Output value definitions
├── versions.tf          # Provider version constraints
├── locals.tf            # Local values (optional)
├── data.tf              # Data sources (optional)
├── README.md            # Module documentation
└── examples/            # Usage examples
    ├── basic/           # Simple example
    ├── advanced/        # Complex example
    └── specific-case/   # Real-world scenarios
```

### File Standards

#### `main.tf`
- Contains primary resource definitions
- Use descriptive resource names
- Group related resources logically
- Include comments for complex logic

#### `variables.tf`
- All variables must have descriptions
- Use appropriate types and validation
- Provide sensible defaults where applicable
- Group related variables together

```hcl
variable "name" {
  description = "Name of the resource"
  type        = string
  
  validation {
    condition     = length(var.name) > 3
    error_message = "Name must be at least 4 characters long."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
```

#### `outputs.tf`
- All outputs must have descriptions
- Output sensitive values appropriately
- Use consistent naming patterns

```hcl
output "id" {
  description = "The ID of the created resource"
  value       = azurerm_resource.example.id
}

output "fqdn" {
  description = "The fully qualified domain name"
  value       = azurerm_resource.example.fqdn
  sensitive   = false
}
```

#### `versions.tf`
- Specify minimum Terraform version
- Pin provider versions appropriately
- Use optimistic version constraints

```hcl
terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.42.0"
    }
  }
}
```

### Naming Conventions

- **Resources**: Use descriptive names with underscores
- **Variables**: Use snake_case
- **Outputs**: Use snake_case
- **Tags**: Include standard tags (environment, project, etc.)

### Security Best Practices

- Enable diagnostic settings by default
- Use secure defaults (HTTPS only, latest TLS, etc.)
- Implement least-privilege access
- Support managed identities
- Enable monitoring and logging

## 🧪 Testing

### Local Testing

1. **Format Check**
   ```bash
   terraform fmt -check -recursive
   ```

2. **Validation**
   ```bash
   cd module-name
   terraform init
   terraform validate
   ```

3. **Linting**
   ```bash
   tflint --config=../.tflint.hcl
   ```

4. **Security Scan**
   ```bash
   checkov -d . --framework terraform
   ```

### Example Testing

Test all examples in your module:

```bash
cd module-name/examples/basic
terraform init
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve
```

### Integration Testing

For major changes, test deployment in a real Azure environment:

1. Create a test resource group
2. Deploy the module
3. Verify functionality
4. Clean up resources

## 📚 Documentation

### README Template

Each module must include a comprehensive README with:

1. **Description**: What the module does
2. **Usage**: Basic and advanced examples
3. **Requirements**: Terraform and provider versions
4. **Providers**: Required providers
5. **Modules**: Any sub-modules used
6. **Resources**: Resources created
7. **Inputs**: All input variables
8. **Outputs**: All output values

### Auto-Generated Documentation

We use [terraform-docs](https://terraform-docs.io/) to generate documentation:

```bash
terraform-docs markdown table --output-file README.md --output-mode inject .
```

### Examples

- **Basic Example**: Minimal viable configuration
- **Advanced Example**: Full-featured setup
- **Real-world Examples**: Specific use cases

## 🔄 Pull Request Process

### Before Submitting

- [ ] Code follows our style guidelines
- [ ] All tests pass locally
- [ ] Documentation is updated
- [ ] Examples are provided and tested
- [ ] Security scan passes
- [ ] Conventional commit format used

### PR Requirements

1. **Descriptive Title**: Use conventional commit format
2. **Detailed Description**: Explain what and why
3. **Testing Evidence**: Show test results
4. **Breaking Changes**: Document any breaking changes
5. **Examples**: Include working examples

### Review Process

1. **Automated Checks**: CI pipeline must pass
2. **Code Review**: At least one maintainer approval
3. **Testing**: Reviewers may test examples
4. **Documentation**: Verify docs are complete

### Merge Requirements

- ✅ All CI checks pass
- ✅ At least one maintainer approval
- ✅ No unresolved conversations
- ✅ Branch is up to date with main

## 🏷️ Release Process

Our release process is automated using semantic versioning:

### Automatic Releases

- Releases are triggered on merge to `main`
- Version is determined by conventional commit messages
- Changelog is automatically generated
- Release notes include changed modules

### Manual Releases

Maintainers can trigger manual releases for special cases:

1. Go to Actions → Release workflow
2. Click "Run workflow"
3. Select release type (patch/minor/major)
4. Optionally mark as prerelease

### Version Bumping

- `feat:` → Minor version bump
- `fix:` → Patch version bump
- `feat!:` or `BREAKING CHANGE:` → Major version bump

## 🤝 Community

### Getting Help

- **Discussions**: Use GitHub Discussions for questions
- **Issues**: Report bugs or request features
- **Discord/Slack**: Join our community chat (if available)

### Contributing Ideas

- **New Modules**: Suggest commonly used Azure services
- **Improvements**: Enhance existing modules
- **Documentation**: Improve guides and examples
- **Testing**: Add integration tests
- **CI/CD**: Improve automation

## 🏆 Recognition

Contributors will be acknowledged in:
- Release notes
- README contributors section
- GitHub contributors page

---

Thank you for contributing to Terraform Azure Modules! Your efforts help make infrastructure as code more accessible and reliable for everyone.
