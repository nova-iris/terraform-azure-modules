# Security Policy

## Supported Versions

We actively maintain and provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| latest  | ✅ Yes             |
| main    | ✅ Yes             |

## Reporting a Vulnerability

The security of our Terraform modules is important to us. If you discover a security vulnerability, please follow these steps:

### 🔒 Private Disclosure

**DO NOT** create a public GitHub issue for security vulnerabilities.

Instead, please:

1. **Use GitHub Security Advisories**: Go to the [Security tab](https://github.com/nova-iris/terraform-azure-modules/security/advisories) and click "Report a vulnerability"
2. **Email**: Send details to security@nova-iris.com (if available)

### 📋 What to Include

When reporting a vulnerability, please include:

- Description of the vulnerability
- Steps to reproduce the issue
- Affected modules and versions
- Potential impact assessment
- Suggested mitigation or fix (if available)

### 🕐 Response Timeline

- **Initial Response**: Within 48 hours of report
- **Assessment**: Within 5 business days
- **Fix Timeline**: Depends on severity
  - Critical: Within 7 days
  - High: Within 14 days
  - Medium: Within 30 days
  - Low: Next regular release cycle

### 🛡️ Security Best Practices

When using these modules, we recommend:

#### General Security
- Always use the latest version of modules
- Review and understand the resources being created
- Follow the principle of least privilege
- Use Azure Key Vault for secrets management
- Enable Azure Security Center recommendations

#### Network Security
- Use private endpoints where available
- Configure Network Security Groups (NSGs) appropriately
- Enable Azure Firewall or Web Application Firewall where needed
- Use private DNS zones for internal resolution

#### Identity and Access
- Use managed identities instead of service principals when possible
- Enable multi-factor authentication
- Regularly rotate access keys and secrets
- Use Azure RBAC for fine-grained access control

#### Monitoring and Logging
- Enable Azure Monitor and Application Insights
- Configure diagnostic settings for all resources
- Set up security alerts and notifications
- Regularly review access logs

### 🔍 Security Scanning

Our CI/CD pipeline includes:

- **Static Analysis**: Checkov security scanning
- **Secret Detection**: TruffleHog for credential scanning
- **Dependency Scanning**: Dependabot for vulnerable dependencies
- **Code Quality**: TFLint for Terraform best practices

### 📚 Security Resources

- [Azure Security Documentation](https://docs.microsoft.com/en-us/azure/security/)
- [Terraform Security Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/security.html)
- [Azure Well-Architected Framework - Security](https://docs.microsoft.com/en-us/azure/architecture/framework/security/)

### 🏆 Recognition

We appreciate security researchers and will acknowledge your contribution (with your permission) in our security advisories and release notes.

---

**Note**: This security policy applies to the Terraform modules in this repository. For Azure service-specific security issues, please refer to the [Azure Security Response Center](https://www.microsoft.com/en-us/msrc).
