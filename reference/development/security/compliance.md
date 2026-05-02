# Compliance & Government Security

*Security considerations for government contracts at Friends Innovation Lab.*

---

## Overview

Government projects have additional security requirements beyond standard web development. This guide covers common compliance frameworks we encounter.

**Note:** We're not compliance experts. For official guidance, work with the contracting agency and consider engaging a compliance specialist for larger contracts.

---

## Common Frameworks

### FedRAMP (Federal Risk and Authorization Management Program)

**What:** Standardized security assessment for cloud services used by federal agencies.

**When it applies:** If we're building something that will be hosted as a cloud service for federal use.

**Key points:**
- Three impact levels: Low, Moderate, High
- Most SaaS products need FedRAMP authorization
- Using FedRAMP-authorized services (like AWS GovCloud) simplifies compliance

### FISMA (Federal Information Security Management Act)

**What:** Framework for protecting government information systems.

**When it applies:** Systems that process federal data.

**Key points:**
- Requires documented security controls
- Annual security assessments
- Continuous monitoring

### ATO (Authority to Operate)

**What:** Formal authorization that a system meets security requirements.

**When it applies:** Before any federal system goes live.

**Key points:**
- Requires security documentation
- Risk assessment
- Usually granted for 3 years, then renewed

### Section 508

**What:** Accessibility requirements for federal technology.

**When it applies:** All technology developed for federal agencies.

**Key points:**
- Must meet WCAG 2.0 AA (often 2.1 AA)
- See our [Accessibility Standards](../frontend/accessibility.md)
- Document accessibility testing

---

## Practical Security Controls

Even if full compliance isn't required, these practices help:

### Authentication & Access

```typescript
// Strong session configuration
const sessionConfig = {
  maxAge: 8 * 60 * 60,      // 8 hours max
  rolling: true,             // Reset on activity
  secure: true,              // HTTPS only
  httpOnly: true,            // No JS access
  sameSite: 'strict',        // CSRF protection
}
```

- [ ] Multi-factor authentication (MFA) available
- [ ] Session timeout after inactivity
- [ ] Failed login attempt limiting
- [ ] Secure password requirements
- [ ] Role-based access control

### Data Protection

```typescript
// Example: Encrypt sensitive data at rest
import { createCipheriv, createDecipheriv, randomBytes } from 'crypto'

const ALGORITHM = 'aes-256-gcm'

export function encrypt(text: string, key: Buffer): string {
  const iv = randomBytes(16)
  const cipher = createCipheriv(ALGORITHM, key, iv)
  const encrypted = Buffer.concat([cipher.update(text, 'utf8'), cipher.final()])
  const tag = cipher.getAuthTag()
  return Buffer.concat([iv, tag, encrypted]).toString('base64')
}

export function decrypt(encryptedData: string, key: Buffer): string {
  const data = Buffer.from(encryptedData, 'base64')
  const iv = data.subarray(0, 16)
  const tag = data.subarray(16, 32)
  const encrypted = data.subarray(32)
  const decipher = createDecipheriv(ALGORITHM, key, iv)
  decipher.setAuthTag(tag)
  return decipher.update(encrypted) + decipher.final('utf8')
}
```

- [ ] Data encrypted in transit (HTTPS)
- [ ] Sensitive data encrypted at rest
- [ ] PII handled according to privacy requirements
- [ ] Data retention policies defined
- [ ] Secure data disposal procedures

### Audit Logging

```typescript
// Example: Audit log entry
interface AuditLog {
  timestamp: string
  userId: string
  action: string
  resource: string
  resourceId: string
  ipAddress: string
  userAgent: string
  details?: Record<string, unknown>
}

async function logAuditEvent(event: AuditLog) {
  await supabase.from('audit_logs').insert({
    ...event,
    timestamp: new Date().toISOString(),
  })
}

// Usage
await logAuditEvent({
  userId: user.id,
  action: 'UPDATE',
  resource: 'user_profile',
  resourceId: profileId,
  ipAddress: request.headers.get('x-forwarded-for') || 'unknown',
  userAgent: request.headers.get('user-agent') || 'unknown',
  details: { fieldsChanged: ['email', 'phone'] },
})
```

- [ ] Log authentication events (login, logout, failed attempts)
- [ ] Log data access and modifications
- [ ] Log administrative actions
- [ ] Protect logs from tampering
- [ ] Retain logs per policy requirements

### Infrastructure

- [ ] Use FedRAMP-authorized cloud providers when required
- [ ] Keep systems patched and updated
- [ ] Network segmentation where appropriate
- [ ] Regular vulnerability scanning
- [ ] Incident response plan documented

---

## Using Compliant Services

### Supabase

Supabase offers SOC 2 Type II compliance. For government work:

- Use Supabase Pro or Enterprise for SLA
- Enable Point-in-Time Recovery
- Configure database backups
- Review their security documentation

**Note:** Supabase is not FedRAMP authorized. For FedRAMP requirements, consider AWS GovCloud with self-hosted PostgreSQL.

### Vercel

Vercel offers SOC 2 Type II and can work for many government projects:

- Enterprise plan offers additional security features
- HIPAA BAA available on Enterprise
- Review their compliance documentation

**Note:** For FedRAMP High, consider AWS GovCloud alternatives.

### Alternative: AWS GovCloud

For strict federal requirements:

- FedRAMP High authorized
- Isolated from commercial AWS
- Requires separate account
- More operational overhead

---

## Documentation Requirements

Government contracts often require security documentation:

### System Security Plan (SSP)

Documents how the system implements security controls:

```markdown
# System Security Plan

## System Description
- Purpose and scope
- System boundaries
- Data flows

## Security Controls
- Access control (AC)
- Audit and accountability (AU)
- Security assessment (CA)
- Configuration management (CM)
- Identification and authentication (IA)
- Incident response (IR)
- Maintenance (MA)
- Media protection (MP)
- Physical protection (PE)
- Planning (PL)
- Personnel security (PS)
- Risk assessment (RA)
- System and services acquisition (SA)
- System and communications protection (SC)
- System and information integrity (SI)

## Control Implementation
[For each control, describe how it's implemented]
```

### Privacy Impact Assessment (PIA)

Required when handling PII:

```markdown
# Privacy Impact Assessment

## Data Collection
- What PII is collected?
- Why is it needed?
- How is it collected?

## Data Use
- How is PII used?
- Who has access?
- What are the business processes?

## Data Sharing
- Is PII shared externally?
- With whom and why?
- What agreements are in place?

## Data Protection
- How is PII protected?
- What access controls exist?
- How long is data retained?

## Individual Rights
- How can individuals access their data?
- How can they request corrections?
- How can they request deletion?
```

### Incident Response Plan

```markdown
# Incident Response Plan

## Roles and Responsibilities
- Incident Response Lead: [Name]
- Technical Lead: [Name]
- Communications: [Name]

## Incident Classification
- Critical: Data breach, system compromise
- High: Service outage, vulnerability exploited
- Medium: Attempted breach, degraded service
- Low: Minor security event

## Response Procedures

### Detection
1. Monitor alerts and logs
2. Review user reports
3. Automated security scanning

### Analysis
1. Determine scope and impact
2. Identify affected systems
3. Preserve evidence

### Containment
1. Isolate affected systems
2. Block attack vectors
3. Prevent further damage

### Eradication
1. Remove malicious code/access
2. Patch vulnerabilities
3. Reset compromised credentials

### Recovery
1. Restore from clean backups
2. Verify system integrity
3. Return to normal operations

### Post-Incident
1. Document lessons learned
2. Update procedures
3. Report as required

## Reporting Requirements
- Agency notification: Within [X] hours
- User notification: Within [X] days (if PII affected)
```

---

## Security Checklist for Government Projects

### Before Development

- [ ] Understand contract security requirements
- [ ] Identify applicable compliance frameworks
- [ ] Choose compliant hosting/services
- [ ] Plan for security documentation

### During Development

- [ ] Follow secure coding practices
- [ ] Implement authentication/authorization
- [ ] Add audit logging
- [ ] Encrypt sensitive data
- [ ] Test for vulnerabilities

### Before Launch

- [ ] Conduct security assessment
- [ ] Complete required documentation
- [ ] Perform penetration testing (if required)
- [ ] Obtain ATO (if required)
- [ ] Train users on security procedures

### Ongoing

- [ ] Monitor security alerts
- [ ] Apply patches promptly
- [ ] Review access periodically
- [ ] Conduct regular assessments
- [ ] Update documentation

---

## Resources

### Government Resources

- [FedRAMP.gov](https://www.fedramp.gov/) — FedRAMP program information
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework) — Security guidelines
- [Section508.gov](https://www.section508.gov/) — Accessibility requirements
- [CISA](https://www.cisa.gov/) — Cybersecurity guidance

### Compliance Shortcuts

| Need | Approach |
|------|----------|
| FedRAMP Low/Moderate | Use FedRAMP-authorized services |
| Basic security | Follow NIST 800-53 controls |
| Accessibility | Meet WCAG 2.1 AA |
| Privacy | Conduct PIA, implement data protection |

---

## When to Get Help

Consider engaging specialists for:

- FedRAMP authorization process
- Penetration testing
- Compliance audits
- Security architecture review
- Large government contracts

---

*See also: [Secrets Management](secrets.md) · [Input Validation](input-validation.md) · [Accessibility](../frontend/accessibility.md)*
