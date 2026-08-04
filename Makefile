.PHONY: test
test:
	@echo "Checking MiniStack is reachable..."
	@curl -sf http://localhost:4566/_ministack/health > /dev/null || (echo "MiniStack not reachable on :4566 — run: docker start ministack" && exit 1)
	@echo "MiniStack is up. Running Terratest..."
	@cd tests/terratest && go test -v -timeout 10m