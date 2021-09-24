# Build configuration
# -------------------

APP_NAME = `node -p "require('./package.json').name"`
GIT_BRANCH=`git rev-parse --abbrev-ref HEAD`
GIT_REVISION = `git rev-parse HEAD`

# Introspection targets
# ---------------------

.PHONY: help
help: header targets

.PHONY: header
header:
	@echo "\033[34mEnvironment\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@printf "\033[33m%-23s\033[0m" "APP_NAME"
	@printf "\033[35m%s\033[0m" $(APP_NAME)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "GIT_BRANCH"
	@printf "\033[35m%s\033[0m" $(GIT_BRANCH)
	@echo ""
	@printf "\033[33m%-23s\033[0m" "GIT_REVISION"
	@printf "\033[35m%s\033[0m" $(GIT_REVISION)
	@echo "\n"

.PHONY: targets
targets:
	@echo "\033[34mTargets\033[0m"
	@echo "\033[34m---------------------------------------------------------------\033[0m"
	@perl -nle'print $& if m{^[a-zA-Z_-]+:.*?## .*$$}' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-22s\033[0m %s\n", $$1, $$2}'

# Development targets
# -------------------

.PHONY: clean
clean: ## Remove build artifacts
	rm -rf dist

.PHONY: build
build: ## Make a production build
	yarn vite build

.PHONY: deps
deps: ## Install all dependencies
	yarn install

.PHONY: format
format: format-elm ## Format everything

.PHONY: format-elm
format-elm: ## Format elm files
	elm-format src/ --yes

.PHONY: lint
lint: lint-elm ## Format everything

.PHONY: lint-elm
lint-elm: ## Lint elm files
	elm-review

.PHONY: preview
preview: build ## See what the production build will look like
	yarn vite preview --https

.PHONY: run
run: ## Run web app
	yarn vite --https
