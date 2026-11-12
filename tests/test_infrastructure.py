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
