# Portwood DocGen — Code Analyzer Security Report

**Package:** Portwood DocGen v1.12.0 (portwoodglobal namespace)
**Scan Date:** March 31, 2026
**Scanner:** Salesforce Code Analyzer v5.9.0 (sf code-analyzer run --rule-selector "Recommended")
**Engines:** pmd, eslint, retire-js, cpd, regex, flow
**Target:** force-app/ (all package source — Apex classes, LWC, custom objects, permission sets)

## Summary

| Severity | Count | Status |
|----------|-------|--------|
| **Critical** | **0** | Clean |
| **High** | **0** | Clean |
| Moderate | 392 | Code quality only (see below) |
| Low | 491 | Style/documentation (see below) |
| Info | 49 | Copy-paste detection |

**Zero security vulnerabilities found. All Critical and High severity violations are zero.**

## Security-Relevant Findings

None. The scan found zero violations in any security-relevant category:

- **No CRUD/FLS violations** — all SOQL queries use `WITH USER_MODE` or `AccessLevel.USER_MODE`
- **No sharing violations** — all classes declare `with sharing`
- **No SOQL injection** — all dynamic SOQL uses bind variables and `String.escapeSingleQuotes()`
- **No XSS vulnerabilities** — no unescaped user input in markup
- **No hardcoded credentials** — no API keys, passwords, or tokens in source
- **No SOQL/DML in loops** — all refactored to bulk operations
- **No external callouts** — zero HttpRequest usage in the distributed package
- **No Flow security issues** — Flow engine scan returned zero findings

## Moderate Violations (392) — Not Security Related

These are all **code quality metrics**, not security findings:

| Rule | Count | Category |
|------|-------|----------|
| CyclomaticComplexity | ~90 | Method branching complexity |
| CognitiveComplexity | ~65 | Method readability |
| AvoidDeeplyNestedIfStmts | ~60 | Nested if statements |
| NcssCount | ~45 | Method/class line count |
| ExcessiveParameterList | ~25 | Method parameter count |
| no-inline-disable (ESLint) | ~9 | Inline rule disablement in LWC |
| AvoidBooleanMethodParameters | ~8 | Boolean params |
| AvoidGlobalModifier | 2 | Required for @InvocableMethod |

**Why these are not security risks:** Cyclomatic/cognitive complexity, method length, and parameter counts are software engineering quality metrics. They indicate methods that could benefit from refactoring but do not represent security vulnerabilities. The `AvoidGlobalModifier` violations are intentional — `global` access is required for @InvocableMethod to be visible in Flow Builder across namespace boundaries. The `no-inline-disable` violations are intentional — `no-await-in-loop` is disabled in specific locations where sequential Apex calls are required for heap management (each call gets fresh 6 MB heap).

## Low Violations (491) — Documentation & Style

| Rule | Count | Category |
|------|-------|----------|
| ApexDoc | ~220 | Missing Javadoc comments |
| ApexUnitTestClassShouldHaveRunAs | ~100 | Test methods without System.runAs() |
| no-hardcoded-values-slds2 (ESLint) | ~25 | CSS values without SLDS tokens |
| no-slds-namespace-for-custom-hooks | ~50 | CSS custom property naming |
| AnnotationsNamingConventions | ~5 | @isTest vs @IsTest casing |
| AvoidNonRestrictiveQueries | ~2 | Queries with LIMIT but no WHERE |
| Other | ~10 | Minor style suggestions |

**Why these are not security risks:** Missing documentation, test patterns, CSS naming conventions, and annotation casing have no impact on application security.

## Info Violations (49)

All Info-level findings are from the **copy-paste detection (CPD)** engine, identifying similar code blocks. These are refactoring suggestions, not security findings.

## Detailed Report

The full violation-by-violation CSV report is attached as `code-analyzer-report.csv`.

## Scan Reproduction

To reproduce this scan:

```bash
sf plugins install @salesforce/plugin-code-analyzer
sf code-analyzer run --rule-selector "Recommended" --target force-app
```

## No DAST Scanner Required

This solution has no external web application, API, mobile application, or external component. All functionality runs within the Salesforce platform using standard Apex and LWC. No external endpoints are exposed or consumed. Therefore, no DAST scan (OWASP ZAP, Burp Suite, etc.) is applicable.
