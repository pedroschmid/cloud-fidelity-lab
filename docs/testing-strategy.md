# Testing Strategy

## Goal

Check that the declared infrastructure can be provisioned from scratch, exposes the expected API contracts, and converges to a Terraform plan with no changes.

## Implemented validation layers

| Layer | Tool | Evidence |
| --- | --- | --- |
| Python quality | Ruff | Lint and formatting checks pass |
| Terraform formatting | Terraform | `fmt -check -recursive` passes |
| Terraform configuration | Terraform | `validate` succeeds |
| Provisioning | Terraform + AWS Emulator | Four resources created from a fresh environment |
| Configuration contracts | Boto3 + Pytest | Bucket discovery, naming, public access flags, encryption, versioning |
| Behavioral contract | Boto3 + Pytest | Historical versions and latest object content can be retrieved |
| Idempotence | Terraform | Post-apply plan exits with code `0` |

Terraform security scanning is not currently implemented in CI.

## Contract suite

`make test-contracts` invokes `scripts/test-contracts.sh`.

The runner checks emulator health over HTTPS and executes `tests/test_infrastructure.py`. The current suite contains seven tests.

The bucket-name test validates the fixture's naming convention. Bucket existence and discovery are checked separately against the API.

The object-version test:

1. Generates a unique key.
2. Writes two different payloads to that key.
3. Requires non-null, distinct version IDs.
4. Retrieves each version and compares its content.
5. Retrieves the key without a version ID and checks the latest content.
6. Attempts deletion of the specific versions through cleanup callbacks, including when assertions fail.

A successful delete response is not an independent assertion that no object versions remain. Cleanup verification can be added as a separate improvement.

## Running checks locally

With the emulator running and infrastructure applied:

```bash
make lint-python
terraform fmt -check -recursive infra/
make tf-validate
make test-contracts
./scripts/terraform.sh plan -detailed-exitcode
```

A completed run should show seven passing tests and no Terraform changes.

## Failure handling

- Health-check failures stop execution before tests run.
- API errors and failed assertions fail the suite.
- Unsupported emulator operations must be reported as compatibility limitations.
- Do not turn an unsupported operation into a passing result through unconditional skips or expected failures.
- The idempotence stage fails when Terraform returns either an error or proposed changes.

## Interpretation

Passing tests demonstrate the selected contracts in the emulator environment.

Reading encryption and public access settings does not prove physical encryption or rejection of anonymous requests. Those require different evidence.

Real-AWS validation requires a separate environment, credentials, cost controls, and an explicitly defined scope.
