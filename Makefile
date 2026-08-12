.PHONY: test check security-scan test-database-unsafe

test:
	@echo "Checking MiniStack is reachable..."
	@curl -sf http://localhost:4566/_ministack/health > /dev/null || (echo "MiniStack not reachable on :4566 — run: docker start ministack" && exit 1)
	@echo "MiniStack is up. Running Terratest..."
	@cd tests/terratest && go test -v -timeout 10m

check: security-scan test
	@echo "All checks passed."

test-database-unsafe:
	@echo "WARNING: creates a real RDS instance against MiniStack."
	@echo "Known to hang on destroy (ADR-0017), has caused a cross-instance"
	@echo "ID collision that destroyed a real dev database (ADR-0018), and"
	@echo "asserts on a field MiniStack does not populate (ADR-0019)."
	@echo "Run only when actively investigating those defects, and never"
	@echo "against a MiniStack instance holding anything you care about."
	@cd tests/terratest && go test -tags ministack_unsafe_rds -run TestDatabaseModule -v -timeout 10m

security-scan:
	@echo "Running Checkov against terraform/..."
	@docker run --rm -v "$(PWD)/terraform:/tf" ghcr.io/bridgecrewio/checkov:3.3.9 \
		-d /tf --quiet \
		--skip-check CKV_AWS_144,CKV_AWS_145,CKV_AWS_119,CKV_AWS_18,CKV2_AWS_61,CKV2_AWS_62,CKV2_AWS_11,CKV_AWS_130,CKV2_AWS_30,CKV_AWS_157,CKV_AWS_353,CKV_AWS_118,CKV_AWS_293