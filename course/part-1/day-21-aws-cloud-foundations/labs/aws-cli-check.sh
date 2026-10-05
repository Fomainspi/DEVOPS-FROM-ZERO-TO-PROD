#!/usr/bin/env bash
set -euo pipefail

echo 'AWS identity:'
aws sts get-caller-identity

echo
echo 'Configured region:'
aws configure get region || true

echo
echo 'S3 buckets visible to this identity:'
aws s3 ls
