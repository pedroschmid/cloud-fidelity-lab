# Architecture

## Execution model

The developer environment and GitHub Actions use the same repository scripts.

- Docker runs AWS Emulator.
- Terraform declares the S3 resources.
- Boto3/Pytest checks the provisioned configuration and selected object behavior.
- A second Terraform plan verifies that the applied configuration converges without further changes.

The emulator listens inside the container on port `9297`. Docker publishes it on host loopback only: `127.0.0.1:9297`.

The host directory `~/.aws/emulator` is mounted into the container. The scripts and fixtures read the generated credentials and CA certificate from the `9297` subdirectory.

## Terraform resources

| Resource | Responsibility |
| --- | --- |
| `aws_s3_bucket.artifacts` | Bucket named `cloud-fidelity-lab-${environment}-artifacts` |
| `aws_s3_bucket_public_access_block.artifacts` | Enable all four public-access restriction flags |
| `aws_s3_bucket_server_side_encryption_configuration.artifacts` | Set default encryption to SSE-S3 / `AES256` |
| `aws_s3_bucket_versioning.artifacts` | Enable bucket versioning |

The security resources reference the bucket ID, establishing their dependency on the bucket.

## Endpoint and credentials

The Terraform provider explicitly targets the local S3 endpoint. Variable validation restricts the configured endpoint to `https://127.0.0.1:9297`.

The Terraform wrapper clears selected AWS credential and role environment variables, points to the generated emulator configuration, and checks emulator health before invoking Terraform.

The Boto3 fixture creates its client with explicit emulator credentials, path-style addressing, and CA verification. It also asserts the expected endpoint.

These settings keep the supported execution path directed at the local emulator. They are configuration controls, not a network isolation boundary.

## Design decisions

### Dedicated S3 security resources

Encryption, versioning, and public access configuration are declared separately. This keeps each control visible in Terraform plans and maps directly to configuration contract tests.

### Flat Terraform structure

The current scope contains one bucket and its controls. Resources remain in the root configuration; a reusable module can be introduced when another actual consumer justifies it.

### Local state

Terraform uses a local backend. This keeps the demo self-contained. State locking and collaboration through a remote backend are outside the current scope.

CI starts on a fresh hosted runner and does not persist the Terraform state as an artifact.

### Shared scripts

Local execution and CI use the same Terraform wrapper and contract-test runner, reducing differences in endpoint and credential setup.

### Saved CI plan

CI saves the plan and applies that file. After testing, it runs another plan with `-detailed-exitcode`, so proposed changes fail the idempotence stage.

## Lifecycle

Locally, destroy Terraform-managed resources before removing the emulator container when a clean teardown is desired.

CI removes its emulator container in an `always()` step. It relies on the temporary runner for disposal of the remaining local files; it does not exercise Terraform destroy.
