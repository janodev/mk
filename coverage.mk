# ===========================================
# Coverage test
# ===========================================

# This is imported by xcode.mk, package.mk

# Helper shell fragment that reliably discovers the profile + binary even on older toolchains
# Must be executed inside a recipe (can't run before tests)
find-prof-and-bin = \
    prof=$$(find .build -type f -name default.profdata -print -quit); \
    bin=$$(find .build -type d -name '*.xctest' -print -quit); \
    exec=$${bin}/Contents/MacOS/$$(basename $$bin .xctest); \
    echo "$$prof $$exec"

# @help:results-bundle: Build tests and save results to TestRun.xcresult
.PHONY: results-bundle result-bundle
results-bundle result-bundle:
	@echo "$(BLUE)Building $(PROJECT_NAME) and producing $(RESULT_BUNDLE)…$(RESET)"
	@rm -rf $(RESULT_BUNDLE) || true
	@if [ -d "$(PROJECT_NAME).xcodeproj" ] || ls *.xcodeproj >/dev/null 2>&1; then \
		xcodebuild \
		-scheme $(PROJECT_NAME) \
		-destination 'platform=iOS Simulator,name=iPhone 16 18.4' \
		-only-testing:$(PROJECT_NAME)Tests \
		test \
		-resultBundlePath $(RESULT_BUNDLE); \
	else \
		xcodebuild \
		-scheme $(PACKAGE_SCHEME) \
		-destination 'platform=macOS' \
		test \
		-resultBundlePath $(RESULT_BUNDLE); \
	fi

# @help:results-summary: Build tests and print a JSON test summary
.PHONY: results-summary summary
results-summary summary: results-bundle
	@echo "$(BLUE)Executive summary for $(RESULT_BUNDLE)…$(RESET)"
	@xcrun xcresulttool get test-results summary \
	    --path $(RESULT_BUNDLE) | jq .

# @help:results-brief: Build tests and print brief pass/fail statistics
.PHONY: results-brief summary-brief
results-brief summary-brief: results-bundle
	@xcrun xcresulttool get test-results summary \
	    --path $(RESULT_BUNDLE) | \
	    jq -r '"Result: \(.result)  │  Total: \(.totalTestCount)  │  Passed: \(.passedTests)  │  Failed: \(.failedTests)  │  Skipped: \(.skippedTests)"'

# @help:results-file: Build tests and save a JSON summary to summary.json
.PHONY: results-file summary-file
results-file summary-file: results-bundle
	@echo "$(BLUE)Saving executive summary to summary.json…$(RESET)"
	@xcrun xcresulttool get test-results summary \
	    --path $(RESULT_BUNDLE) > summary.json
	@echo "$(BLUE)summary.json created$(RESET)"

# Coverage targets
# @help:coverage: Generate and display code coverage summary
.PHONY: coverage
coverage: build-and-test
	@echo "$(BLUE)Generating coverage summary...$(RESET)"
	@read prof exec <<< "$$( $(call find-prof-and-bin) )"; \
	llvm-cov report -instr-profile $$prof $$exec | tee coverage-summary.txt

# @help:coverage-lcov: Generate LCOV file at coverage/coverage.lcov
.PHONY: coverage-lcov lcov
coverage-lcov lcov: build-and-test
	@echo "$(BLUE)Exporting LCOV to coverage/coverage.lcov...$(RESET)"
	@mkdir -p coverage; \
	read prof exec <<< "$$( $(call find-prof-and-bin) )"; \
	llvm-cov export -format=lcov -instr-profile $$prof $$exec > coverage/coverage.lcov

# @help:coverage-html: Generate HTML coverage report and open in browser
.PHONY: coverage-html html
coverage-html html: coverage-lcov
	@echo "$(BLUE)Generating HTML report...$(RESET)"
	@genhtml coverage/coverage.lcov --output-directory coverage/html
	@echo "$(BLUE)Opening coverage/html/index.html$(RESET)"
	@open coverage/html/index.html

# @help:coverage-file: Show coverage for a specific file (usage: make coverage-file FILE=path/to/File.swift)
.PHONY: coverage-file file-coverage
coverage-file file-coverage:
	@if [ -z "$(FILE)" ]; then \
		echo "Error: specify FILE=<path/to/File.swift>"; exit 1; fi
	@echo "$(BLUE)Coverage for $(FILE)...$(RESET)"
	@read prof exec <<< "$$( $(call find-prof-and-bin) )"; \
	llvm-cov show -instr-profile $$prof $$exec --sources "$(FILE)"
	@echo "$(BLUE)Scroll up to see the execution count for each line in $(FILE)$(RESET)"
	@echo "$(BLUE)Lines without numbers represent non executable code, like declarations, parameter lists, whitespace, etc$(RESET)"
