.PHONY: test check security-scan

test:
	@echo "Checking MiniStack is reachable..."
	@curl -sf http://localhost:4566/_ministack/health > /dev/null || (echo "MiniStack not reachable on :4566 — run: docker start ministack" && exit 1)
	@echo "MiniStack is up. Running Terratest..."
	@cd tests/terratest && go test -v -timeout 10m

check: security-scan test
	@echo "All checks passed."

security-scan:
	@echo "Running Checkov against terraform/..."
	@docker run --rm -v "$(PWD)/terraform:/tf" bridgecrewio/checkov:3.3.9 \
		-d /tf --quiet \
		--skip-check CKV_AWS_144,CKV_AWS_145,CKV_AWS_119,CKV_AWS_18,CKV2_AWS_61,CKV2_AWS_62,CKV2_AWS_11,CKV_AWS_130,CKV2_AWS_30,CKV_AWS_157,CKV_AWS_353,CKV_AWS_118,CKV_AWS_293