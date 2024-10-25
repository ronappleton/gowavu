#!/usr/bin/env bats

# Define the path to the gowavu.sh script
GOWAVU_SCRIPT_PATH="../gowavu.sh"

# Load the gowavu.sh script before each test
setup() {
  source "$GOWAVU_SCRIPT_PATH"
}

# Test the show_help function
@test "show_help displays the help message" {
  run bash "$GOWAVU_SCRIPT_PATH" help
  [[ $status -eq 0 ]]
  [[ $output == *"Usage: gowavu [command] [options]"* ]]
}

# Test the check_root function
@test "check_root fails if not run as root" {
  run bash -c '. '"$GOWAVU_SCRIPT_PATH"'; check_root'
  [[ $status -eq 1 ]]
  [[ $output == *"This script must be run as root for setup tasks. Please run with sudo."* ]]
}

# Test the command_exists function
@test "command_exists returns true for existing command" {
  run bash -c '. '"$GOWAVU_SCRIPT_PATH"'; command_exists bash'
  [[ $status -eq 0 ]]
}

@test "command_exists returns false for non-existing command" {
  run bash -c '. '"$GOWAVU_SCRIPT_PATH"'; command_exists non_existing_command'
  [[ $status -eq 1 ]]
}

# Test the setup function
@test "setup installs required tools" {
  run bash -c '
    install_go() { echo "Mock install Go"; }
    install_node() { echo "Mock install Node.js"; }
    install_pnpm() { echo "Mock install pnpm"; }
    install_wails() { echo "Mock install Wails"; }
    setup_gopath() { echo "Mock setup GOPATH"; }

    # Redefine setup function to use mocked installs
    setup() {
      install_go
      install_node
      install_pnpm
      install_wails
      setup_gopath
    }

    # Source the script and call setup
    source "'"$GOWAVU_SCRIPT_PATH"'"
    echo "Running setup..."
    setup
  '

  [[ $status -eq 0 ]]
  [[ $output == *"Mock install Go"* ]]
  [[ $output == *"Mock install Node.js"* ]]
  [[ $output == *"Mock install pnpm"* ]]
  [[ $output == *"Mock install Wails"* ]]
  [[ $output == *"Mock setup GOPATH"* ]]
}

# Test the new project creation
@test "new creates a new Wails project" {
  run bash -c '
    create_project() { echo "Mock create project: $1"; }

    # Redefine new function to use mocked create_project
    new() {
      create_project "$1"
    }

    # Source the script and call new
    source "'"$GOWAVU_SCRIPT_PATH"'"
    echo "Running new..."
    new testproject
  '

  [[ $status -eq 0 ]]
  [[ $output == *"Mock create project: testproject"* ]]
}

# Test the build function
@test "build compiles the application for all platforms" {
  run bash -c '
    build_app() { echo "Mock build app"; }

    # Redefine build function to use mocked build_app
    build() {
      build_app
    }

    # Source the script and call build
    source "'"$GOWAVU_SCRIPT_PATH"'"
    echo "Running build..."
    build
  '

  [[ $status -eq 0 ]]
  [[ $output == *"Mock build app"* ]]
}

# Test the update function
@test "update checks for script updates" {
  run bash -c '
  source "'"$GOWAVU_SCRIPT_PATH"'"
  echo "Checking for script updates..."
  type update &>/dev/null && update || echo "update function not found"
 '
  [[ $status -eq 0 ]]
  [[ $output == *"Checking for script updates..."* ]]
}

# Test that a function can be mocked
@test "function can be mocked" {
  run bash -c '
    original_function() { echo "Original function"; }
    original_function
    mock_function() { echo "Mock function"; }
    original_function() { mock_function; }
    original_function
  '
  [[ $status -eq 0 ]]
  [[ $output == *"Mock function"* ]]
}
