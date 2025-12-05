# Engineering Deployment Guide

**Version:** 2.1.0
**Owner:** Platform Engineering Team

## Overview

This guide covers the standard deployment process for production applications.

## Prerequisites

- [ ] All tests pass in CI/CD pipeline
- [ ] Code review approved by 2+ engineers
- [ ] Security scan completed
- [ ] Rollback plan documented

## Deployment Process

### 1. Pre-Deployment

```bash
git checkout main
git pull origin main
npm test
npm run build
```

### 2. Create Release

```bash
git tag -a v1.2.3 -m "Release v1.2.3"
git push origin v1.2.3
```

### 3. Deploy to Production

Production requires manual approval via GitHub Actions.

## Rollback Procedure

```bash
kubectl rollout undo deployment/app -n production
```

## Contacts

- **On-Call:** #platform-oncall (Slack)
- **Emergency:** (555) 911-HELP
