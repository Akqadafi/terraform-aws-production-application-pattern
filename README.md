# terraform-aws-production-application-pattern
Production-style AWS application stack built with Terraform, demonstrating secure EC2–RDS trust, private networking, managed ingress (ALB/TLS/WAF), observability, and structured incident response

This repo evolves through three phases:

- **Phase 1 — Verified Foundations:** EC2 → RDS connectivity with Secrets Manager + least-privilege IAM and CLI proof.  
- **Phase 2 — Exposure & Enforcement:** Public ingress via ALB + TLS, WAF, alarms, and logging/observability. 
- **Phase 3 — Constraints & Response:** Automated incident evidence collection and report generation (Bedrock-style Auto-IR) plus human verification runbooks.   

---

## What This Demonstrates 

- **Infrastructure-as-Code discipline** (repeatable builds, versioned change)
- **Secure app-to-database trust** (SG-to-SG rules, no public RDS, secrets not in code)  
- **Private compute patterns** (SSM Session Manager, VPC endpoints, optional NAT tradeoffs)  
- **Production ingress** (ALB, TLS via ACM, DNS, WAF) :contentReference[oaicite:8]{index=8} 
- **Observability + verification** (CloudWatch alarms/dashboards, WAF logs, ALB access logs) 
- **Incident response mindset** (evidence bundles, structured reports, runbooks) 

## Architecture Summary

**Core request flow (baseline):**
1. Client requests the app
2. App runs on EC2
3. EC2 retrieves DB credentials from Secrets Manager (via IAM role)
4. EC2 connects privately to RDS MySQL
5. App reads/writes records and returns responses 

**Security model:**
- RDS is **not publicly accessible**
- RDS inbound allows **TCP 3306 only from the EC2 security group** (not `0.0.0.0/0`)
- EC2 uses **IAM role** to retrieve secrets; no static creds   

---

## Repository Layout

├── terraform/ # Terraform root 
├── modules/ # Reusable Terraform modules 
├── docs/
│ ├── PHASE_1_foundation.md
│ ├── PHASE_2_ingress_observability.md
│ ├── PHASE_3_incident_response.md
│ ├── TROUBLESHOOTING.md
│ ├── incidents/
│ └── runbooks/
├── scripts/
│ ├── collect_evidence.sh # plan/apply evidence capture
│ └── verify.sh # optional verification helpers
├── artifacts/ # timestamped evidence bundles 
├── CHANGELOG.md
└── README.md

This repository treats verification as a deliverable, not an
afterthought.\
Every major component is validated via AWS CLI to confirm actual system
state.

------------------------------------------------------------------------

## EC2 Exists and Is Running

``` bash
aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=lab-ec2-app" \
  --query "Reservations[].Instances[].State.Name"
```

**Expected:** `"running"`

------------------------------------------------------------------------

## RDS Is Available and Has an Endpoint

``` bash
aws rds describe-db-instances \
  --db-instance-identifier lab-mysql \
  --query "DBInstances[0].DBInstanceStatus"

aws rds describe-db-instances \
  --db-instance-identifier lab-mysql \
  --query "DBInstances[0].Endpoint"
```

**Expected:**\
- `available`\
- Endpoint address\
- Port `3306`

------------------------------------------------------------------------

## RDS Security Group Restricts Access Properly

``` bash
aws ec2 describe-security-groups \
  --group-names sg-rds-lab \
  --query "SecurityGroups[0].IpPermissions"
```

**Expected:**\
- TCP port `3306`\
- Source references EC2 security group ID\
- No open CIDR ranges (no `0.0.0.0/0`)

------------------------------------------------------------------------

## Secrets Manager Access Works from EC2 (via SSM)

``` bash
aws secretsmanager get-secret-value --secret-id lab/rds/mysql
```

**Expected:**\
- JSON response containing:\
- `username`\
- `password`\
- `host`\
- `port`\
- No IAM access errors

------------------------------------------------------------------------

# Automated Evidence Capture (Plan → JSON)

Terraform does not emit JSON directly from `plan`. The workflow is:

``` bash
terraform plan -out=tfplan
terraform show -json tfplan > plan.json
terraform output -json > outputs.json
```

Recommended practice:

Store artifacts in:

    artifacts/<timestamp>/

These files serve as:

-   Infrastructure intent (`plan.json`)\
-   Deployed outputs (`outputs.json`)\
-   Inputs for structured troubleshooting and incident documentation

------------------------------------------------------------------------

# Incident & Troubleshooting Documentation

-   `docs/TROUBLESHOOTING.md` --- indexed summary of failures and
    resolutions\
-   `docs/incidents/YYYY-MM-DD-<slug>.md` --- full structured incident
    reports

Phase 3 introduces an automated evidence bundle + Markdown report
pattern.

**Core principle:**

> LLMs accelerate analysis. Humans own correctness.

------------------------------------------------------------------------

# Change Log

`CHANGELOG.md` tracks meaningful system changes, including:

-   What changed\
-   Why it changed\
-   Impact\
-   Risk

Commit messages follow a structured style:

-   `feat:`\
-   `fix:`\
-   `security:`\
-   `docs:`

This enables clean changelog automation.

------------------------------------------------------------------------

# Roadmap

-   [ ] Make Phase 1 fully private-by-default (SSM + VPC endpoints; NAT
    optional tradeoffs)\
-   [ ] Add ALB access logs and correlate with WAF + app error spikes\
-   [ ] Add automated "Auto-IR" evidence bundle + report artifacts to S3
