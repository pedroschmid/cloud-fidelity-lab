# Limitations and Validation Boundaries

## Validated scope

The observed local and CI executions successfully provisioned the four S3 resources, passed seven contract tests, and produced a final Terraform plan with no changes.

No unsupported API error was observed in those executions. This does not imply support for all S3 APIs or production equivalence.

## Current boundaries

| Area | Boundary |
| --- | --- |
| AWS equivalence | Tests execute against AWS Emulator, not a real AWS account |
| Encryption | The suite reads default encryption configuration; it does not inspect physical storage encryption |
| Public access | The suite checks configuration flags; it does not attempt anonymous access |
| IAM | Authorization policies and enforcement are not tested |
| Versioning | Two-version retrieval and latest-version behavior are tested; delete-marker behavior is not |
| Cleanup | Callbacks attempt deletion of created versions; absence afterward is not independently checked |
| Durability and availability | No persistence, recovery, throughput, or availability guarantees are tested |
| Terraform state | Local backend; no remote collaboration or state recovery workflow |
| Platform | The Dockerfile downloads an x86_64 RPM |
| Emulator version | Downloaded from `LTS/latest`; exact version is not currently recorded in CI |
| Dependencies | Python versions are constrained by ranges; Actions use major-version tags |
| Static analysis | Dedicated Terraform security scanning is not enforced |
| Teardown | CI removes the container; Terraform destroy is not tested by the pipeline |

## Container lifecycle

Removing the container does not remove host Terraform state or the mounted emulator credential/configuration directory.

Resources may need to be recreated after container removal. A retained state file must not be treated as evidence that a new emulator contains those resources.

The bootstrap script does not automatically restart an existing stopped container.

## Observed installation warning

The successful CI build emitted:

```text
Header V4 RSA/SHA512 Signature, key ID d940f624: NOKEY
```

The image build completed, but package-signing-key verification was not established by that execution. Signature verification and package pinning remain follow-up work.

## Recording a compatibility issue

For each newly observed limitation, capture:

- Service and API operation.
- Expected behavior.
- Observed response or error.
- Exact emulator version, when available.
- Minimal reproduction.
- Impact on the contract suite.
- Validation status and any follow-up.

Do not include emulator credentials, private keys, or Terraform state in issue reports.
