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

# Target to regenerate Xcode project files using Tuist
# @help:generate: Generate Xcode project files
.PHONY: generate
generate:
	@echo "$(BLUE)Removing Xcode project files...$(RESET)"
	@rm -rf $(PROJECT_NAME).xcodeproj $(PROJECT_NAME).xcworkspace
	@echo "$(GREEN)Xcode project files removed successfully$(RESET)"
	@echo "$(BLUE)Generating new Xcode project files with Tuist...$(RESET)"
	@tuist generate --no-open
	@echo "$(GREEN)Xcode project files generated successfully$(RESET)"

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
.PHONY: build
build:
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

# Include common testing utilities
include $(MK_DIR)/coverage.mk

# Include DocC commands
include $(MK_DIR)/docc-xcode.mk
