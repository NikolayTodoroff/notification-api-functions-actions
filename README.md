# notification-api-functions-actions-infra

Infrastructure as Code and CI/CD pipelines for a serverless Azure Functions API, with a versioned NuGet package consumed via GitHub Packages, CodeQL scanning, and automated release notes.

---

## Highlights

- Azure Functions (Consumption plan, zip deployment)
- Shared validation library published as a versioned NuGet package via GitHub Packages
- SemVer-based release workflow — tag push triggers package publish, independent of app deploys
- CodeQL static analysis integrated into the application pipeline
- Automated GitHub release notes generated from commit/PR history
- Azure App Configuration with Feature Manager — infrastructure and RBAC provisioned for feature flags

---

## Repository Structure

```
notification-api-functions-actions-infra/
├── .github/
│   ├── workflows/
│   │   ├── infrastructure.yml       
│   │   ├── reusable-terraform.yml   
│   │   ├── application.yml          
│   │   └── package-publish.yml      
│   ├── release.yml                  
│   └── dependabot.yml
├── src/
│   ├── NotificationValidation/      
│   └── NotificationApi/              
├── tests/
│   └── NotificationValidation.Tests/
├── infra/
│   ├── main/                        
│   ├── modules/
│   │   ├── function-app/             
│   │   ├── app-configuration/        
│   │   ├── key-vault/                
│   │   └── monitoring/               
│   └── env/
│       ├── dev.tfvars
│       └── prod.tfvars
├── scripts/
│   ├── bootstrap.sh
│   ├── assign-azure-roles.ps1
│   └── create-federated-credentials.ps1
├── nuget.config                     
└── README.md
```

---

## CI/CD Architecture

### Infrastructure Pipeline

```
Validate (dev) ──┐  parallel matrix
Validate (prod) ─┘
        ↓
Deploy — dev (terraform apply)
        ↓
Deploy — prod (terraform apply)
```

### Package Publish Pipeline

```
git tag v*.*.* pushed
        ↓
Extract version from tag
        ↓
Restore + Test (package project and its tests only — NOT the whole solution)
        ↓
dotnet pack with version from tag
        ↓
Publish to GitHub Packages (NuGet feed)
```

Triggered only by version tags, independent of `main` pushes. Scoped to the package project specifically — restoring the full solution here would create a circular dependency, since the consuming app references a package version this very workflow is responsible for publishing.

### Application Pipeline

```
Build, Test, and Scan
  ├── Restore (full solution, authenticated against GitHub Packages)
  ├── Build + Test
  └── CodeQL analysis (C#)
        ↓
Deploy — dev
  ├── dotnet publish + zip
  ├── OIDC login
  ├── Deploy via Azure/functions-action (zip deploy)
  ├── Retrieve host key (with retry loop)
  ├── Warm-up wait
  └── Smoke test (POST with function-level auth)
        ↓
Deploy — prod  ← manual approval gate
  └── (identical sequence against prod resources)
```

---

## Security

### Identity and Authentication

- OIDC federated credentials scoped to GitHub environments (`dev`, `prod`) — no client secrets for Azure
- System-assigned Managed Identity on the Function App
- Key Vault in RBAC mode
- App Configuration with `local_auth_enabled = false` — Microsoft Entra ID / RBAC only, no connection strings

### Security Tooling

| Tool | Purpose |
|---|---|
| CodeQL | Static application security testing (SAST) on C# source |
| Checkov | Terraform IaC security scanning → GitHub Security tab |
| TFLint | Terraform static analysis with Azure ruleset |
| GitHub Packages auth | `read:packages` / `write:packages` scoped tokens, no broader access |

---

## Monitoring

- Application Insights connected to the Function App via app setting
- Log Analytics Workspace

---

## Key Design Decisions

- **Zip deployment over containers** — Functions Consumption (`Y1`) on Linux doesn't support custom containers, so native Zip Deploy was used.

- **.NET 8 over .NET 10** — Azure Functions Linux Consumption currently supports .NET 8, making it the compatible target framework.

- **Package workflow restores only the package project** — Prevents a circular dependency between the package publisher and its consuming application.

- **Host key for smoke tests** — Function-specific keys were unreliable immediately after fresh deployments, so the host key was used for automated validation.

- **Feature flag infrastructure only** — App Configuration, feature flags, and RBAC are provisioned, while application-level flag consumption was intentionally deferred to keep the focus on infrastructure and CI/CD patterns.

---

## Technologies

- **Terraform** — IaC with modules pattern
- **GitHub Actions** — reusable workflows, tag-triggered publishing, OIDC
- **.NET 8** — class library and Azure Functions isolated worker model
- **Azure Functions** — Consumption plan, HTTP trigger, zip deployment
- **GitHub Packages** — NuGet feed, SemVer-based publishing
- **Azure App Configuration** — Feature Manager, RBAC-only access
- **Azure Key Vault** — RBAC mode
- **Azure Application Insights + Monitor**
- **CodeQL** — SAST for C#
- **Checkov / TFLint** — IaC scanning and linting
- **GitHub Releases** — automated release notes

---
