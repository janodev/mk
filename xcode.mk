# ===========================================
# Makefile content for Xcode projects
# ===========================================

# You must define PROJECT_NAME in the Makefile that imports this file
# This is imported by the Makefile in the Xcode project

# Auto‑generated scheme when a Swift‑PM package is opened in Xcode
PACKAGE_SCHEME = $(PROJECT_NAME)

# Get all package directories
PACKAGE_DIRS := $(wildcard Packages/*)

# Include common configuration
include $(MK_DIR)/config.mk
include $(MK_DIR)/help.mk
include $(MK_DIR)/coverage.mk
include $(MK_DIR)/docc-xcode.mk
include $(MK_DIR)/tuist.mk

# Target to clean build artifacts and project files
# @help:clean: Clean all build products and derived data
.PHONY: clean
clean:
	@echo "$(BLUE)Cleaning build artifacts and project files...$(RESET)"
	@xcodebuild clean -workspace $(PROJECT_NAME).xcworkspace -scheme $(PROJECT_NAME) 2>/dev/null || true
	@rm -rf build
	@rm -rf .build
	@rm -rf DerivedData
	@rm -rf $(PROJECT_NAME).xcodeproj
	@rm -rf $(PROJECT_NAME).xcworkspace
	@echo "$(GREEN)Clean completed successfully$(RESET)"

# Target to build all Swift packages
# @help:build-packages: Build Swift package dependencies
.PHONY: build-packages
build-packages:
	@echo "$(BLUE)Building all Swift packages...$(RESET)"
	@for dir in $(PACKAGE_DIRS); do \
		echo "Building $$dir"; \
		(cd $$dir && make build) || exit 1; \
	done
	@echo "$(GREEN)All packages built successfully$(RESET)"

# Target to test all Swift packages
# @help:test-packages: Test all Swift package dependencies
.PHONY: test-packages
test-packages:
	@echo "$(BLUE)Testing all Swift packages...$(RESET)"
	@for dir in $(PACKAGE_DIRS); do \
		echo "Testing $$dir"; \
		(cd $$dir && make test) || exit 1; \
	done
	@echo "$(GREEN)All package tests completed$(RESET)"

# Target to build the project in Debug configuration
# @help:build: Build for iOS simulator
.PHONY: build-and-test
build-and-test: build test-xcode
	@echo ""

# Target to build the project in Debug configuration
# @help:build-xcode: Build using Xcode for iOS simulator
.PHONY: build-xcode
build-xcode:
	@echo "$(BLUE)Building project (Debug)...$(RESET)"
	@xcodebuild build -workspace $(PROJECT_NAME).xcworkspace -scheme $(PROJECT_NAME) -configuration Debug | xcbeautify -q
	@echo "$(GREEN)$(PROJECT_NAME) project built successfully (Debug)$(RESET)"

# Target to build the project in Release configuration
# @help:build-release: Build for iOS device (release configuration)
.PHONY: build-release
build-release:
	@echo "$(BLUE)Building $(PROJECT_NAME) project (Release)...$(RESET)"
	@xcodebuild build -workspace $(PROJECT_NAME).xcworkspace -scheme $(PROJECT_NAME) -configuration Release
	@echo "$(GREEN)$(PROJECT_NAME) project built successfully (Release)$(RESET)"

# @help:test-xcode: Run tests using xcodebuild (required for Core Data tests)
.PHONY: test-xcode
test-xcode:
	@echo "$(BLUE)Testing $(PROJECT_NAME) with xcodebuild...$(RESET)"
	# this fails when adding -testPlan TestPlan.xctestplan
	xcodebuild test \
		-scheme $(PROJECT_NAME) \
		-destination 'platform=macOS' \
		2>&1 | xcbeautify || exit 1
	@echo "$(GREEN)All tests completed successfully$(RESET)"

# @help:test-xcode-coverage: Run tests using xcodebuild with code coverage
.PHONY: test-xcode-coverage
test-xcode-coverage:
	@echo "$(BLUE)Testing $(PROJECT_NAME) with xcodebuild and generating coverage...$(RESET)"
	@mkdir -p coverage
	@rm -rf ./coverage/TestResults.xcresult
	# this fails when adding -testPlan TestPlan.xctestplan
	@xcodebuild test \
		-scheme $(PROJECT_NAME) \
		-destination 'platform=macOS' \
		-enableCodeCoverage YES \
		-resultBundlePath ./coverage/TestResults.xcresult \
		2>&1 | xcbeautify || exit 1
	@echo "$(GREEN)Tests and code coverage completed successfully$(RESET)"
	@echo "$(BLUE)Code coverage report available at ./coverage/TestResults.xcresult$(RESET)"
	@echo "$(BLUE)Open with: xcrun xcresulttool get test-results summary --path ./coverage/TestResults.xcresult | jq .$(RESET)"
	@echo "$(BLUE)For detailed results: xcrun xcresulttool get test-results tests --path ./coverage/TestResults.xcresult$(RESET)"

# @help:test-xcode-file: Run tests for a specific test file using xcodebuild (usage: make test-xcode-file FILE=SomeTests)
.PHONY: test-xcode-file
test-xcode-file:
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: specify FILE=<TestClassName> (without the .swift extension)$(RESET)"; exit 1; fi
	@echo "$(BLUE)Testing file $(FILE) with xcodebuild...$(RESET)"
	@xcodebuild test \
		-scheme $(PROJECT_NAME) \
		-destination 'platform=macOS' \
		-only-testing:$(PROJECT_NAME)Tests/$(FILE) \
		2>&1 | xcbeautify || exit 1
	@echo "$(GREEN)Test for $(FILE) completed successfully$(RESET)"
