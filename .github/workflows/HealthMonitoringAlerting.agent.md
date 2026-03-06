---
name: Azure Container Apps Health Check
description: Checks the health of specified Azure Container Apps and summarizes results.
# Schedule to run every morning at 8 AM EST (13:00 UTC)
on:
  schedule:
    - cron: '0 13 * * *'
  workflow_dispatch: {}

# Agentic Workflows are read-only by default, perfect for your "no new items" rule.
permissions:
  contents: read

network:
  allowed:
    - defaults
    - "*.azurecontainerapps.io"
---

Run a plain shell health check using `curl` only.

Execute exactly one bash script that:
1. Defines this list of health endpoints:
  - `https://customer-api.ambitioussea-f3f6277f.eastus2.azurecontainerapps.io/health`
  - `https://fundstransfermgt-api.ambitioussea-f3f6277f.eastus2.azurecontainerapps.io/health`
  - `https://policy-api.ambitioussea-f3f6277f.eastus2.azurecontainerapps.io/health`
  - `https://ratingandunderwriting-api.ambitioussea-f3f6277f.eastus2.azurecontainerapps.io/health`
2. For each endpoint, performs unauthenticated HTTP GET with timeout (`--connect-timeout 5 --max-time 15`).
3. Captures HTTP status code and total latency in milliseconds.
4. Marks status as:
  - `✅ Healthy` when HTTP code is `200`
  - `❌ Unhealthy` for all other codes or request failures/timeouts
5. Produces a Markdown table with this exact schema:

| App Name | Health Endpoint | Status | Latency (ms) |
|----------|-----------------|--------|--------------|

Output rules:
- Do NOT create issues, pull requests, comments, or commits.
- Write the markdown to `$GITHUB_STEP_SUMMARY` if that path is writable.
- If `$GITHUB_STEP_SUMMARY` is missing or not writable, print only the markdown table to stdout.
- Do not run any other tools if the shell script succeeds.
