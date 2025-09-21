#!/bin/bash

# Pomodoro Timer Build and Run Script
# Usage: ./build_and_run.sh [clean|release|run]

set -e  # Exit on any error

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_NAME="Pomodoro Screen Timer"
SCHEME_NAME="Pomodoro Screen Timer"
BUILD_DIR="$PROJECT_DIR/build"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🍅 Pomodoro Timer Build Script${NC}"
echo "Project: $PROJECT_NAME"
echo "Build Directory: $BUILD_DIR"
echo ""

# Function to clean problematic files
clean_problematic_files() {
    echo -e "${YELLOW}🧹 Cleaning problematic files...${NC}"
    
    # Remove .DS_Store files that can cause code signing issues
    find "$PROJECT_DIR" -name ".DS_Store" -delete 2>/dev/null || true
    
    # Remove any extended attributes that might cause issues
    xattr -cr "$PROJECT_DIR" 2>/dev/null || true
    
    # Clean any existing build artifacts
    if [ -d "$BUILD_DIR" ]; then
        \rm -rf "$BUILD_DIR"
    fi
}

# Function to build the project
build_project() {
    local config=$1
    echo -e "${YELLOW}Building $PROJECT_NAME ($config configuration)...${NC}"
    
    # Clean problematic files first
    clean_problematic_files
    
    # Build with additional flags to handle code signing issues
    xcodebuild \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration "$config" \
        -derivedDataPath "$BUILD_DIR" \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO \
        build
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Build successful!${NC}"
        return 0
    else
        echo -e "${RED}❌ Build failed! Trying with development signing...${NC}"
        
        # Try again with development signing
        xcodebuild \
            -project "$PROJECT_NAME.xcodeproj" \
            -scheme "$SCHEME_NAME" \
            -configuration "$config" \
            -derivedDataPath "$BUILD_DIR" \
            CODE_SIGN_IDENTITY="Apple Development" \
            build
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ Build successful with development signing!${NC}"
            return 0
        else
            echo -e "${RED}❌ Build failed even with development signing!${NC}"
            echo -e "${YELLOW}💡 Try opening Xcode and checking your signing settings.${NC}"
            return 1
        fi
    fi
}

# Function to run the app
run_app() {
    local config=$1
    local app_path="$BUILD_DIR/Build/Products/$config/$PROJECT_NAME.app"
    
    if [ -d "$app_path" ]; then
        echo -e "${BLUE}🚀 Launching $PROJECT_NAME...${NC}"
        open "$app_path"
    else
        echo -e "${RED}❌ App not found at: $app_path${NC}"
        echo "Make sure to build the project first."
        return 1
    fi
}

# Function to clean build directory
clean_build() {
    echo -e "${YELLOW}🧹 Cleaning build directory...${NC}"
    
    xcodebuild \
        -project "$PROJECT_NAME.xcodeproj" \
        -scheme "$SCHEME_NAME" \
        -configuration Debug \
        -derivedDataPath "$BUILD_DIR" \
        clean
    
    # Also remove the build directory
    if [ -d "$BUILD_DIR" ]; then
        \rm -rf "$BUILD_DIR"
        echo -e "${GREEN}✅ Clean completed!${NC}"
    fi
}

# Parse command line arguments
case "${1:-build}" in
    "clean")
        clean_build
        ;;
    "clean-files")
        clean_problematic_files
        ;;
    "release")
        build_project "Release"
        ;;
    "run")
        run_app "Debug"
        ;;
    "build-and-run"|"")
        build_project "Debug" && run_app "Debug"
        ;;
    "release-and-run")
        build_project "Release" && run_app "Release"
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [command]"
        echo ""
        echo "Commands:"
        echo "  build-and-run  Build (Debug) and run the app (default)"
        echo "  build          Build the app (Debug configuration)"
        echo "  release        Build the app (Release configuration)"
        echo "  run            Run the previously built app"
        echo "  clean          Clean the build directory"
        echo "  clean-files    Clean problematic files (.DS_Store, extended attributes)"
        echo "  release-and-run Build (Release) and run the app"
        echo "  help           Show this help message"
        ;;
    *)
        build_project "Debug" && run_app "Debug"
        ;;
esac
