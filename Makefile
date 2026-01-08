# Kyverno sandbox
CLI_VER=v1.16.1
KIND_VER=v0.31.0

.PHONY: all
all: test integration-test

.PHONY: clean
clean:
	kind delete cluster

# https://medium.com/@john-tucker/kyverno-policy-testing-part-1-6922201eb3eb
# Unit tests
# doesn't need a Kubernetes cluster

.PHONY: test
test: /usr/local/bin/kyverno
	@for dir in test/*/; do \
		echo "Testing $$dir"; \
		(cd "$$dir" && kyverno test .); \
	done
	#
# Binary installation
/usr/local/bin/kyverno:
	curl -LO https://github.com/kyverno/kyverno/releases/download/${CLI_VER}/kyverno-cli_${CLI_VER}_linux_x86_64.tar.gz
	tar -xvf kyverno-cli_${CLI_VER}_linux_x86_64.tar.gz && rm kyverno-cli_${CLI_VER}_linux_x86_64.tar.gz
	sudo mv kyverno /usr/local/bin/ && rm LICENSE

.PHONY: kyverno-cli
kyverno-cli: /usr/local/bin/kyverno

# https://medium.com/@john-tucker/kyverno-policy-testing-part-2-c8f0a4aa1d16
# Integration tests

.PHONY: integration-test
integration-test: /usr/local/bin/chainsaw cluster kyverno
	$(shell cd chainsaw && chainsaw test)

/usr/local/bin/chainsaw:
	@echo 'First run chainsaw/install.sh'

.PHONY: cluster
cluster: /usr/local/bin/kind
	@kind get clusters | grep -q kind || kind create cluster --config kind-cluster.yaml

/usr/local/bin/kind:
	[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VER}/kind-$(uname)-amd64
	chmod +x kind
	sudo mv kind /usr/local/bin

# helm installation
.PHONY: kyverno
kyverno: update-repo
	$(eval KYVERSION := $(shell helm search repo kyverno/kyverno --versions | head -2 | tail -1 | awk '{print $$2}'))
	@echo "Installing Kyverno version: $(KYVERSION)"
	helm upgrade --install kyverno kyverno/kyverno --version $(KYVERSION) --namespace kyverno --create-namespace

.PHONY: update-repo
update-repo: repo
	helm repo update

# ${HOME}/.config/helm/repositories.yaml
.PHONY: repo
repo:
	@helm repo list | grep -q kyverno || helm repo add kyverno https://kyverno.github.io/kyverno/

