import configparser
from pathlib import Path

import boto3
import pytest
from botocore.config import Config

EMULATOR_ENDPOINT = "https://127.0.0.1:9297"
EMULATOR_DIR = Path.home() / ".aws" / "emulator" / "9297"


@pytest.fixture(scope="session")
def s3_client():
    credentials_path = EMULATOR_DIR / "emulator_credentials"
    certificate_path = EMULATOR_DIR / "ca.pem"

    if not credentials_path.is_file() or not certificate_path.is_file():
        pytest.fail("AWS Emulator is not initialized. Run 'make up' first.")

    credentials = configparser.ConfigParser()
    credentials.read(credentials_path)

    if "default" not in credentials:
        pytest.fail("AWS Emulator credentials are missing the default profile.")

    session = boto3.Session(
        aws_access_key_id=credentials["default"]["aws_access_key_id"],
        aws_secret_access_key=credentials["default"]["aws_secret_access_key"],
        region_name="us-east-1",
    )

    client = session.client(
        "s3",
        endpoint_url=EMULATOR_ENDPOINT,
        verify=str(certificate_path),
        config=Config(
            s3={"addressing_style": "path"},
            retries={"max_attempts": 1},
            connect_timeout=3,
            read_timeout=5,
        ),
    )

    assert client.meta.endpoint_url == EMULATOR_ENDPOINT

    return client


@pytest.fixture(scope="session")
def bucket_name():
    return "cloud-fidelity-lab-dev-artifacts"
