# ===========================================
# Makefile content for Packages
# ===========================================

# You must define PROJECT_NAME in the Makefile that imports this file
# This is imported by the Makefile in the Xcode project

# Auto‑generated scheme when a Swift‑PM package is opened in Xcode
PACKAGE_SCHEME  = $(PROJECT_NAME)-Package

# Include common configuration
include $(MK_DIR)/config.mk
include $(MK_DIR)/help.mk

# ===========================================
# Default target - replaced by auto-generated help
# ===========================================

# ===========================================
# Simulator Utilities
# ===========================================
# @help:list-simulators: List available iOS simulators
.PHONY: list-simulators
list-simulators:
	@echo "$(BLUE)Available simulators:$(RESET)"
	xcrun simctl list devices

# ===========================================
# Build / Clean
# ===========================================
# @help:build: Build the project with Swift Package Manager
.PHONY: build
build:
	@echo "$(BLUE)Building $(PROJECT_NAME)...$(RESET)"
	swift build $(SWIFT_BUILD_FLAGS)

# @help:clean: Clean build artifacts and cached files
.PHONY: clean
clean:
	@echo "$(BLUE)Cleaning $(PROJECT_NAME)...$(RESET)"
	rm -rf .build
	rm -rf .docc-build
	swift package clean

# ===========================================
# Tests
# ===========================================
# @help:build-and-test: Build the project and run all tests
.PHONY: build-and-test
build-and-test: build test

# @help:test: Run all tests with code coverage enabled
.PHONY: test
test:
	@echo "$(BLUE)Running tests for $(PROJECT_NAME)...$(RESET)"
	[ -d "coverage" ] && rm -rf coverage || true
	swift test --enable-code-coverage $(SWIFT_BUILD_FLAGS) --enable-experimental-swift-testing --disable-sandbox

# @help:test-file: Run tests for a specific file (usage: make test-file TEST_FILE=YourTestFileName)
.PHONY: test-file
test-file: build
	@if [ -z "$(TEST_FILE)" ]; then \
		echo "Error: You must specify a file using TEST_FILE=YourTestFileName"; \
		exit 1; \
	fi
	@echo "$(BLUE)Running tests for file $(TEST_FILE) in $(PROJECT_NAME)...$(RESET)"
	@swift test --filter "$(TEST_FILE)" $(SWIFT_BUILD_FLAGS) --enable-code-coverage --disable-sandbox

# @help:test-method: Run a specific test method (usage: make test-method TEST_FILE=YourTestFileName METHOD=yourTestMethod)
.PHONY: test-method
test-method: build
	@if [ -z "$(TEST_FILE)" ] || [ -z "$(METHOD)" ]; then \
		echo "Error: You must specify both TEST_FILE and METHOD"; \
		exit 1; \
	fi
	@echo "$(BLUE)Running test method $(METHOD) in $(TEST_FILE)...$(RESET)"
	@if echo "$(TEST_FILE)" | grep -q "\." ; then \
		swift test --filter "$(TEST_FILE)/$(METHOD)" $(SWIFT_BUILD_FLAGS) --enable-code-coverage --disable-sandbox; \
	else \
		swift test --filter "$(PROJECT_NAME)Tests.$(TEST_FILE)/$(METHOD)" $(SWIFT_BUILD_FLAGS) --enable-code-coverage --disable-sandbox; \
	fi

# Include common testing utilities
include $(MK_DIR)/coverage.mk

# Include DocC commands
include $(MK_DIR)/docc-package.mk
