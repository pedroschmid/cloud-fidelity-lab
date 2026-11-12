from contextlib import ExitStack, closing
from uuid import uuid4

import pytest


@pytest.mark.contract
def test_artifacts_bucket_exists(s3_client, bucket_name):
    response = s3_client.head_bucket(Bucket=bucket_name)

    assert response["ResponseMetadata"]["HTTPStatusCode"] == 200


@pytest.mark.contract
def test_artifacts_bucket_is_discoverable(s3_client, bucket_name):
    response = s3_client.list_buckets()

    bucket_names = {bucket["Name"] for bucket in response["Buckets"]}

    assert bucket_name in bucket_names


@pytest.mark.contract
def test_bucket_name_follows_naming_convention(bucket_name):
    assert bucket_name.startswith("cloud-fidelity-lab-")
    assert bucket_name.endswith("-artifacts")


@pytest.mark.contract
def test_artifacts_bucket_blocks_public_access(s3_client, bucket_name):
    response = s3_client.get_public_access_block(Bucket=bucket_name)

    configuration = response["PublicAccessBlockConfiguration"]

    assert configuration == {
        "BlockPublicAcls": True,
        "IgnorePublicAcls": True,
        "BlockPublicPolicy": True,
        "RestrictPublicBuckets": True,
    }


@pytest.mark.contract
def test_artifacts_bucket_uses_sse_s3_default_encryption(s3_client, bucket_name):
    response = s3_client.get_bucket_encryption(Bucket=bucket_name)

    rules = response["ServerSideEncryptionConfiguration"]["Rules"]

    assert len(rules) == 1
    encryption = rules[0]["ApplyServerSideEncryptionByDefault"]
    assert encryption["SSEAlgorithm"] == "AES256"
    assert not encryption.get("KMSMasterKeyID")


@pytest.mark.contract
def test_artifacts_bucket_has_versioning_enabled(s3_client, bucket_name):
    response = s3_client.get_bucket_versioning(Bucket=bucket_name)

    assert response.get("Status") == "Enabled"


@pytest.mark.contract
def test_artifacts_bucket_preserves_object_versions(s3_client, bucket_name):
    key = f"contract-tests/versioning/{uuid4().hex}.txt"
    versions = []

    with ExitStack() as cleanup:
        for content in (b"first version", b"second version"):
            response = s3_client.put_object(
                Bucket=bucket_name,
                Key=key,
                Body=content,
            )
            version_id = response.get("VersionId")

            cleanup.callback(
                s3_client.delete_object,
                Bucket=bucket_name,
                Key=key,
                VersionId=version_id or "null",
            )

            assert version_id and version_id != "null", response
            versions.append((version_id, content))

        assert versions[0][0] != versions[1][0]

        for version_id, expected_content in versions:
            response = s3_client.get_object(
                Bucket=bucket_name,
                Key=key,
                VersionId=version_id,
            )

            with closing(response["Body"]) as body:
                assert response.get("VersionId") == version_id
                assert body.read() == expected_content

        response = s3_client.get_object(Bucket=bucket_name, Key=key)

        with closing(response["Body"]) as body:
            assert response.get("VersionId") == versions[-1][0]
            assert body.read() == versions[-1][1]
