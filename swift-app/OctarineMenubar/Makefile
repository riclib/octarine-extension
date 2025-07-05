# Makefile for OctarineMenubar
# Alternative build method when Swift Package Manager has issues

APP_NAME = OctarineMenubar
SOURCES = Sources/OctarineApp.swift \
          Sources/Models/ClipMetadata.swift \
          Sources/Managers/NativeMessagingHost.swift \
          Sources/Managers/ClippingManager.swift \
          Sources/Managers/PomodoroTimer.swift \
          Sources/Views/ContentView.swift

BUILD_DIR = .build
EXECUTABLE = $(BUILD_DIR)/$(APP_NAME)

# Swift compiler flags
SWIFTC = swiftc
SWIFT_FLAGS = -framework SwiftUI -framework Combine -target arm64-apple-macos11.0

.PHONY: all clean build run

all: build

build: $(EXECUTABLE)

$(EXECUTABLE): $(SOURCES)
	@mkdir -p $(BUILD_DIR)
	$(SWIFTC) $(SWIFT_FLAGS) $(SOURCES) -o $(EXECUTABLE)
	@echo "Built $(EXECUTABLE)"

run: build
	$(EXECUTABLE)

clean:
	rm -rf $(BUILD_DIR)

install: build
	@echo "Creating app bundle..."
	@mkdir -p /Applications/$(APP_NAME).app/Contents/MacOS
	@cp $(EXECUTABLE) /Applications/$(APP_NAME).app/Contents/MacOS/
	@echo "Installed to /Applications/$(APP_NAME).app"