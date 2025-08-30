# Terraform Azure Modules

A collection of reusable Terraform modules for common Azure services and architectures. This repository provides production-ready, well-documented modules that follow Azure and Terraform best practices.

## Available Modules

### 🌐 Networking Modules
- **[azure-vnet](./azure-vnet/)** - Comprehensive Virtual Network module with subnets, NSGs, route tables, and advanced features
- **[azure-private-dns](./azure-private-dns/)** - Private DNS zones with DNS resolvers, Private Link integration, and custom DNS records
- **[azure-load-balancer](./azure-load-balancer/)** - Load balancers with health probes, backend pools, NAT rules, and outbound configuration
- **[azure-firewall](./azure-firewall/)** - Azure Firewall with policies, rule collections, threat intelligence, and Premium features

### 💻 Compute Modules
- **[azure-vm](./azure-vm/)** - Virtual Machines with comprehensive configuration for Linux/Windows, extensions, and managed identities

### Planned Modules
- **azure-aks** - Azure Kubernetes Service cluster with node pools and add-ons
- **azure-storage** - Storage accounts with containers, file shares, and advanced features
- **azure-vwan** - Virtual WAN with hubs and connections
- **azure-bastion** - Azure Bastion for secure VM access
- **azure-app-service** - App Service plans and web apps with deployment slots

## Module Standards

All modules in this repository follow these standards:

### Structure
```
module-name/
├── main.tf           # Main resource definitions
├── variables.tf      # Input variable definitions
├── outputs.tf        # Output value definitions
├── versions.tf       # Provider version constraints
├── README.md         # Module documentation
└── examples/         # Usage examples
    ├── basic/
    ├── advanced/
    └── specific-use-case/
```

### Best Practices
- **Modular Design**: Each module is self-contained and reusable
- **Comprehensive Documentation**: README with examples and API documentation
- **Input Validation**: Variables include validation rules where appropriate
- **Flexible Configuration**: Support for both simple and complex use cases
- **Security First**: Secure defaults with options for customization
- **Tagging Strategy**: Consistent tagging across all resources
- **Provider Compatibility**: Support for latest stable provider versions

### Code Quality
- **Terraform Standards**: Follow official Terraform style guidelines
- **Variable Naming**: Clear, descriptive variable names
- **Resource Naming**: Consistent naming patterns across modules
- **Comments**: Well-commented code for complex logic
- **Examples**: Multiple examples showing different use cases

## Usage

### Module Structure
Each module includes:
1. **Basic Example**: Simple, minimal configuration
2. **Advanced Example**: Full-featured configuration with all options
3. **Specific Use Cases**: Real-world scenarios (e.g., hub-spoke, multi-tier)

### General Pattern
```hcl
module "example" {
  source = "./module-name"

  # Required variables
  name     = "my-resource"
  location = "East US"
  
  # Optional configuration
  enable_advanced_features = true
  
  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

## Getting Started

1. **Choose a Module**: Browse available modules in their respective directories
2. **Review Examples**: Check the `examples/` directory in each module
3. **Customize Configuration**: Adapt examples to your requirements
4. **Deploy**: Run `terraform init`, `terraform plan`, and `terraform apply`

## Contributing

### Adding New Modules
1. Create module directory with standard structure
2. Implement main.tf, variables.tf, outputs.tf, versions.tf
3. Write comprehensive README with examples
4. Add multiple examples showing different use cases
5. Test thoroughly with different configurations

### Module Guidelines
- Follow existing patterns and naming conventions
- Include input validation where appropriate
- Provide sensible defaults
- Support both simple and complex scenarios
- Include comprehensive tagging
- Document all variables and outputs

### Quality Standards
- All modules must include examples
- Documentation must be complete and accurate
- Variables must have descriptions and types
- Outputs must have descriptions
- Code must be properly formatted (`terraform fmt`)

## Repository Structure

```
terraform-azure-modules/
├── azure-vnet/              # Virtual Network module
├── azure-private-dns/       # Private DNS zones module
├── azure-vm/                # Virtual Machines module
├── azure-load-balancer/     # Load Balancer module
├── azure-firewall/          # Azure Firewall module
├── azure-aks/               # Azure Kubernetes Service (planned)
├── azure-storage/           # Storage Account module (planned)
├── azure-vwan/              # Virtual WAN module (planned)
├── azure-bastion/           # Azure Bastion module (planned)
├── README.md                # This file
└── .gitignore              # Git ignore patterns
```

## Requirements

- **Terraform**: >= 1.0
- **Azure Provider**: >= 3.0
- **Azure CLI**: For authentication and subscription access

## Authentication

Configure Azure authentication using one of these methods:

### Azure CLI (Recommended for development)
```bash
az login
az account set --subscription "your-subscription-id"
```

### Service Principal (Recommended for CI/CD)
```bash
export ARM_CLIENT_ID="your-client-id"
export ARM_CLIENT_SECRET="your-client-secret"
export ARM_SUBSCRIPTION_ID="your-subscription-id"
export ARM_TENANT_ID="your-tenant-id"
```

### Managed Identity (For Azure resources)
Automatically configured when running on Azure resources with managed identity enabled.

## Examples Repository

Each module includes comprehensive examples:
- **Basic**: Minimal viable configuration
- **Advanced**: Full-featured setup with all options
- **Real-world**: Specific architectures (hub-spoke, multi-tier, etc.)

## Support

- **Documentation**: Each module has detailed README and examples
- **Issues**: Use GitHub issues for bugs and feature requests
- **Discussions**: Use GitHub discussions for questions and ideas

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Inspired by [terraform-aws-modules](https://github.com/terraform-aws-modules)
- Follows HashiCorp's Terraform module best practices
- Incorporates Azure Well-Architected Framework principles
