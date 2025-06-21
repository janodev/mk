# ===========================================
# Makefile content for Xcode projects
# ===========================================

# You must define PROJECT_NAME in the Makefile that imports this file
# This is imported by the Makefile in the Xcode project

# Auto‑generated scheme when a Swift‑PM package is opened in Xcode
PACKAGE_SCHEME = $(PROJECT_NAME)

# Default platform configuration (can be overridden in project Makefile)
PLATFORM ?= macOS
DEVICE_NAME ?= My Mac

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

# Target to build and test the project
# @help:build-and-test: Build and run tests
.PHONY: build-and-test
build-and-test: build-xcode test-xcode
	@echo ""

# Target to build the project in Debug configuration
# @help:build-xcode: Build using Xcode for the given PLATFORM variable
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
	@if [ "$(PLATFORM)" = "iOS Simulator" ]; then \
		xcodebuild test \
			-scheme $(PROJECT_NAME) \
			-destination 'platform=$(PLATFORM),name=$(DEVICE_NAME)' \
			-testPlan $(PROJECT_NAME) \
			2>&1 | xcbeautify || exit 1; \
	else \
		xcodebuild test \
			-scheme $(PROJECT_NAME) \
			-destination 'platform=$(PLATFORM)' \
			-testPlan $(PROJECT_NAME) \
			2>&1 | xcbeautify || exit 1; \
	fi
	@echo "$(GREEN)All tests completed successfully$(RESET)"

# @help:unit-test-xcode: Run only unit tests (excluding UI tests) using xcodebuild
.PHONY: unit-test-xcode
unit-test-xcode:
	@echo "$(BLUE)Running unit tests for $(PROJECT_NAME)...$(RESET)"
	@if [ "$(PLATFORM)" = "iOS Simulator" ]; then \
		xcodebuild test \
			-scheme $(PROJECT_NAME) \
			-destination 'platform=$(PLATFORM),name=$(DEVICE_NAME)' \
			-only-testing:$(PROJECT_NAME)Tests \
			2>&1 | xcbeautify || exit 1; \
	else \
		xcodebuild test \
			-scheme $(PROJECT_NAME) \
			-destination 'platform=$(PLATFORM)' \
			-only-testing:$(PROJECT_NAME)Tests \
			2>&1 | xcbeautify || exit 1; \
	fi
	@echo "$(GREEN)Unit tests completed successfully$(RESET)"

# @help:test-xcode-coverage: Run tests using xcodebuild with code coverage
.PHONY: test-xcode-coverage
test-xcode-coverage:
	@echo "$(BLUE)Testing $(PROJECT_NAME) with xcodebuild and generating coverage...$(RESET)"
	@mkdir -p coverage
	@rm -rf ./coverage/TestResults.xcresult
	@if [ "$(PLATFORM)" = "iOS Simulator" ]; then \
		xcodebuild test \
			-scheme $(PROJECT_NAME) \
			-destination 'platform=$(PLATFORM),name=$(DEVICE_NAME)' \
			-testPlan $(PROJECT_NAME) \
			-enableCodeCoverage YES \
			-resultBundlePath ./coverage/TestResults.xcresult \
			2>&1 | xcbeautify || exit 1; \
	else \
		xcodebuild test \
			-scheme $(PROJECT_NAME) \
			-destination 'platform=$(PLATFORM)' \
			-testPlan $(PROJECT_NAME) \
			-enableCodeCoverage YES \
			-resultBundlePath ./coverage/TestResults.xcresult \
			2>&1 | xcbeautify || exit 1; \
	fi
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
	@if [ "$(PLATFORM)" = "iOS Simulator" ]; then \
		xcodebuild test \
			-scheme $(PROJECT_NAME) \
			-destination 'platform=$(PLATFORM),name=$(DEVICE_NAME)' \
			-only-testing:$(PROJECT_NAME)Tests/$(FILE) \
			2>&1 | xcbeautify || exit 1; \
	else \
		xcodebuild test \
			-scheme $(PROJECT_NAME) \
			-destination 'platform=$(PLATFORM)' \
			-only-testing:$(PROJECT_NAME)Tests/$(FILE) \
			2>&1 | xcbeautify || exit 1; \
	fi
	@echo "$(GREEN)Test for $(FILE) completed successfully$(RESET)"

# @help:uitest-xcode-file: Run UI tests for a specific test file using xcodebuild (usage: make uitest-xcode-file FILE=SomeUITests)
.PHONY: uitest-xcode-file
uitest-xcode-file:
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: specify FILE=<TestClassName> (without the .swift extension)$(RESET)"; exit 1; fi
	@echo "$(BLUE)Testing UI file $(FILE) with xcodebuild...$(RESET)"
	@if [ "$(PLATFORM)" = "iOS Simulator" ]; then \
		xcodebuild test \
			-scheme $(PROJECT_NAME) \
			-destination 'platform=$(PLATFORM),name=$(DEVICE_NAME)' \
			-only-testing:$(PROJECT_NAME)UITests/$(FILE) \
			2>&1 | xcbeautify || exit 1; \
	else \
		xcodebuild test \
			-scheme $(PROJECT_NAME) \
			-destination 'platform=$(PLATFORM)' \
			-only-testing:$(PROJECT_NAME)UITests/$(FILE) \
			2>&1 | xcbeautify || exit 1; \
	fi
	@echo "$(GREEN)UI test for $(FILE) completed successfully$(RESET)"

# @help:run: Close Xcode, regenerate project, build and run
.PHONY: run
run:
	@echo "$(BLUE)Closing Xcode project $(PROJECT_NAME)...$(RESET)"
	@osascript -e 'tell application "Xcode" to close (every window whose name contains "$(PROJECT_NAME)")' 2>/dev/null || true
	@sleep 1
	@echo "$(BLUE)Regenerating Xcode project files...$(RESET)"
	@$(MAKE) generate
	@if [ "$(PLATFORM)" = "macOS" ]; then \
		echo "$(BLUE)Building and running macOS app...$(RESET)"; \
		set -o pipefail && xcodebuild -workspace $(PROJECT_NAME).xcworkspace \
			-scheme $(PROJECT_NAME) \
			-destination "platform=macOS,arch=arm64" \
			-configuration Debug \
			-derivedDataPath ./DerivedData \
			build 2>&1 | xcbeautify || exit 1; \
		echo "$(BLUE)Finding built app...$(RESET)"; \
		APP_PATH=$$(find ./DerivedData -name "$(PROJECT_NAME).app" -type d 2>/dev/null | head -1); \
		if [ -z "$$APP_PATH" ]; then \
			echo "$(RED)Error: Could not find built app$(RESET)"; \
			exit 1; \
		fi; \
		echo "$(BLUE)Found app at: $$APP_PATH$(RESET)"; \
		echo "$(BLUE)Launching macOS app...$(RESET)"; \
		open "$$APP_PATH"; \
		echo "$(GREEN)macOS app launched successfully$(RESET)"; \
	else \
		echo "$(BLUE)Building and running in iOS simulator...$(RESET)"; \
		SIMULATOR_ID=$$(xcrun simctl list devices available | grep "iPhone" | head -1 | awk -F'[()]' '{print $$2}'); \
		if [ -z "$$SIMULATOR_ID" ]; then \
			echo "$(RED)Error: No iPhone simulator found$(RESET)"; \
			exit 1; \
		fi; \
		echo "$(BLUE)Using simulator: $$SIMULATOR_ID$(RESET)"; \
		set -o pipefail && xcodebuild -workspace $(PROJECT_NAME).xcworkspace \
			-scheme $(PROJECT_NAME) \
			-destination "platform=iOS Simulator,id=$$SIMULATOR_ID" \
			-configuration Debug \
			-derivedDataPath ./DerivedData \
			build 2>&1 | xcbeautify || exit 1; \
		echo "$(BLUE)Finding built app...$(RESET)"; \
		APP_PATH=$$(find ./DerivedData -name "$(PROJECT_NAME).app" -type d 2>/dev/null | head -1); \
		if [ -z "$$APP_PATH" ]; then \
			echo "$(RED)Error: Could not find built app$(RESET)"; \
			exit 1; \
		fi; \
		echo "$(BLUE)Found app at: $$APP_PATH$(RESET)"; \
		echo "$(BLUE)Launching app in simulator...$(RESET)"; \
		xcrun simctl boot "$$SIMULATOR_ID" 2>/dev/null || true; \
		open -a Simulator; \
		sleep 3; \
		xcrun simctl install booted "$$APP_PATH"; \
		BUNDLE_ID=$$(plutil -p "$$APP_PATH/Info.plist" | grep CFBundleIdentifier | cut -d'"' -f4); \
		echo "$(BLUE)Launching app with bundle ID: $$BUNDLE_ID$(RESET)"; \
		xcrun simctl launch booted "$$BUNDLE_ID"; \
		echo "$(GREEN)App launched successfully in simulator$(RESET)"; \
	fi

# @help:run-xcode: Same as 'run' but also opens Xcode
.PHONY: run-xcode
run-xcode: run
	@echo "$(BLUE)Opening Xcode...$(RESET)"
	@open $(PROJECT_NAME).xcworkspace
	@echo "$(GREEN)Xcode opened successfully$(RESET)"

# @help:coverage-xcode: Generate and display code coverage summary for Xcode project
.PHONY: coverage-xcode
coverage-xcode: test-xcode-coverage
	@echo "$(BLUE)Generating coverage summary from Xcode results...$(RESET)"
	@xcrun xccov view --report --only-targets ./coverage/TestResults.xcresult | tee coverage-summary.txt
	@echo "$(GREEN)Coverage summary saved to coverage-summary.txt$(RESET)"

# @help:coverage-xcode-json: Generate JSON coverage report for Xcode project
.PHONY: coverage-xcode-json
coverage-xcode-json: test-xcode-coverage
	@echo "$(BLUE)Exporting JSON coverage report...$(RESET)"
	@mkdir -p coverage
	@xcrun xccov view --report --json ./coverage/TestResults.xcresult > coverage/coverage.json
	@echo "$(GREEN)Coverage report saved to coverage/coverage.json$(RESET)"

# @help:coverage-xcode-html: Generate HTML coverage report and open in browser (requires lcov)
.PHONY: coverage-xcode-html
coverage-xcode-html: test-xcode-coverage
	@echo "$(BLUE)Generating HTML coverage report...$(RESET)"
	@mkdir -p coverage
	# Extract coverage data and convert to lcov format
	@xcrun xccov view --report --json ./coverage/TestResults.xcresult > coverage/coverage.json
	@echo "$(BLUE)Converting to LCOV format...$(RESET)"
	# Use a Python script to convert JSON to LCOV
	@python3 -c 'import json, sys; \
	data = json.load(open("coverage/coverage.json")); \
	print("TN:"); \
	for target in data.get("targets", []): \
	    for file in target.get("files", []): \
	        print(f"SF:{file[\"path\"]}"); \
	        for line in file.get("functions", []): \
	            if line.get("executionCount") is not None: \
	                print(f"DA:{line[\"lineNumber\"]},{line[\"executionCount\"]}"); \
	        print("end_of_record")' > coverage/coverage.lcov || \
	(echo "$(YELLOW)Warning: Simple LCOV conversion failed. For better results, install xccov-to-lcov$(RESET)" && \
	 echo "$(YELLOW)Install with: brew install xccov-to-lcov$(RESET)" && exit 1)
	@genhtml coverage/coverage.lcov --output-directory coverage/html
	@echo "$(BLUE)Opening coverage/html/index.html$(RESET)"
	@open coverage/html/index.html

# @help:coverage-xcode-file: Show coverage for a specific file in Xcode project (usage: make coverage-xcode-file FILE=path/to/File.swift)
.PHONY: coverage-xcode-file
coverage-xcode-file: test-xcode-coverage
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: specify FILE=<path/to/File.swift>$(RESET)"; exit 1; fi
	@echo "$(BLUE)Coverage for $(FILE)...$(RESET)"
	@xcrun xccov view --file "$(FILE)" ./coverage/TestResults.xcresult || \
		(echo "$(RED)File not found in coverage report. Try the full path starting from project root.$(RESET)" && \
		 echo "$(YELLOW)Available files:$(RESET)" && \
		 xcrun xccov view --file-list ./coverage/TestResults.xcresult | grep -i swift | head -20)
